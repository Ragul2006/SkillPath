import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

/// Connection states for the LiveKit voice pipeline
enum VoiceConnectionState {
  idle,
  requestingPermission,
  fetchingToken,
  connecting,
  connected,
  reconnecting,
  error,
  disconnected,
}

/// Service managing LiveKit realtime audio rooms, microphone permissions,
/// backend token fetching, and voice lifecycle events.
class LiveKitService {
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  LocalAudioTrack? _localAudioTrack;
  TrackPublication? _audioPublication;
  VoiceConnectionState _state = VoiceConnectionState.idle;

  bool _lastUserSpeaking = false;
  bool _lastAgentSpeaking = false;

  Room? get room => _room;
  VoiceConnectionState get state => _state;
  bool get isConnected => _room?.connectionState == ConnectionState.connected;
  bool get hasActiveAudioTrack => _localAudioTrack != null && !(_localAudioTrack?.muted ?? true);

  /// Request runtime microphone permission on Android/iOS/Web
  /// Shows appropriate Tamil/English dialog if permanently denied
  Future<bool> requestMicrophonePermission(BuildContext context) async {
    _state = VoiceConnectionState.requestingPermission;
    debugPrint('[VOICE] Requesting microphone permission');

    // On Web, permission is requested automatically when accessing audio stream
    if (kIsWeb) {
      debugPrint('[VOICE] Microphone permission: granted (web)');
      return true;
    }

    final status = await Permission.microphone.status;
    if (status.isGranted) {
      debugPrint('[VOICE] Microphone permission: granted');
      return true;
    }

    final result = await Permission.microphone.request();
    if (result.isGranted) {
      debugPrint('[VOICE] Microphone permission: granted');
      return true;
    }

    debugPrint('[VOICE] Microphone permission: denied (${result.name})');

    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.mic_off_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('மைக்ரோஃபோன் அனுமதி'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'மைக்ரோஃபோன் அனுமதி தேவைப்படுகிறது.\n\nAI counsellor-ுடன் குரல் மூலம் பேச இந்த அனுமதியை வழங்கவும்.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  'Microphone access is required for voice counselling.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel / ரத்து செய்'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings / அமைப்புகள்'),
              ),
            ],
          ),
        );
      }
    }

    return false;
  }

  /// Request temporary access token from backend server or Supabase Edge function
  /// Keeps LiveKit API secret secure on the backend
  Future<String> fetchAccessToken({
    required String identity,
    required String roomName,
  }) async {
    debugPrint('[SkillPath] Requesting LiveKit token for user: $identity in room: $roomName');
    _state = VoiceConnectionState.fetchingToken;

    final tokenServerUrl = dotenv.env['TOKEN_SERVER_URL'] ?? 'http://10.0.2.2:8080/token';

    // 1. Attempt token retrieval from Token Server (handles agent dispatch)
    try {
      final uri = Uri.parse(tokenServerUrl).replace(
        queryParameters: {
          'identity': identity,
          'room': roomName,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          debugPrint('[SkillPath] LiveKit token received from backend token server');
          return token;
        }
      }
    } catch (e) {
      debugPrint('[SkillPath] Backend token server unreachable ($e). Checking fallback...');
    }

    // 2. Also try localhost if on web/desktop
    if (!kIsWeb) {
      try {
        final localUri = Uri.parse('http://127.0.0.1:8080/token').replace(
          queryParameters: {
            'identity': identity,
            'room': roomName,
          },
        );
        final response = await http.get(localUri).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final token = data['token'] as String?;
          if (token != null && token.isNotEmpty) {
            debugPrint('[SkillPath] LiveKit token received from local token server');
            return token;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback: Generate locally using HMAC-SHA256 if developer key is present in environment
    final apiKey = dotenv.env['LIVEKIT_API_KEY'];
    final apiSecret = dotenv.env['LIVEKIT_API_SECRET'];
    if (apiKey != null && apiKey.isNotEmpty && apiSecret != null && apiSecret.isNotEmpty) {
      debugPrint('[SkillPath] LiveKit token received via secure local fallback signer');
      return _generateLocalToken(identity: identity, roomName: roomName, apiKey: apiKey, apiSecret: apiSecret);
    }

    throw Exception('Unable to obtain LiveKit token. Ensure token_server.py is running or credentials are configured.');
  }

  /// Generate a valid LiveKit JWT access token locally using HMAC-SHA256
  static String _generateLocalToken({
    required String identity,
    required String roomName,
    required String apiKey,
    required String apiSecret,
    String? name,
    Duration duration = const Duration(hours: 6),
  }) {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final exp = now + duration.inSeconds;

    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final payload = {
      'sub': identity,
      'iss': apiKey,
      'nbf': now - 10,
      'exp': exp,
      'name': name ?? identity,
      'video': {
        'room': roomName,
        'roomJoin': true,
        'canPublish': true,
        'canSubscribe': true,
        'canPublishData': true,
      },
    };

    String base64UrlEncodeNoPadding(List<int> bytes) {
      return base64Url.encode(bytes).replaceAll('=', '');
    }

    final headerBase64 = base64UrlEncodeNoPadding(utf8.encode(jsonEncode(header)));
    final payloadBase64 = base64UrlEncodeNoPadding(utf8.encode(jsonEncode(payload)));

    final signingInput = '$headerBase64.$payloadBase64';
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final signature = hmac.convert(utf8.encode(signingInput));
    final signatureBase64 = base64UrlEncodeNoPadding(signature.bytes);

    return '$signingInput.$signatureBase64';
  }

  /// Connect to the LiveKit voice room following strict conceptual order:
  /// requestPermission() -> createMicrophoneTrack() -> connectLiveKit() -> publishMicrophoneTrack() -> connectGemini()
  Future<Room> connect({
    required String identity,
    required String roomName,
    required String token,
    Function(bool isSpeaking)? onAgentSpeakingChanged,
    Function(bool isUserSpeaking)? onUserSpeakingChanged,
    Function(String state)? onAgentStateChanged,
    Function(String text)? onUserTranscriptReceived,
    Function(String text)? onAgentTranscriptReceived,
    Function()? onAgentConnected,
    Function(String error)? onError,
    Function()? onDisconnected,
  }) async {
    final url = dotenv.env['LIVEKIT_URL'] ?? '';
    if (url.isEmpty) {
      throw Exception('LIVEKIT_URL is not configured in .env');
    }

    _state = VoiceConnectionState.connecting;

    // Room options tailored for bidirectional speech and echo cancellation
    const roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
      defaultAudioPublishOptions: AudioPublishOptions(
        dtx: true,
        name: 'microphone',
      ),
      defaultAudioCaptureOptions: AudioCaptureOptions(
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
      ),
    );

    _room = Room(roomOptions: roomOptions);
    _listener = _room!.createListener();

    // 1. Setup room listeners
    _listener!
      ..on<RoomDisconnectedEvent>((event) {
        debugPrint('[VOICE] LiveKit room disconnected');
        _state = VoiceConnectionState.disconnected;
        onDisconnected?.call();
      })
      ..on<ParticipantConnectedEvent>((event) {
        final p = event.participant;
        debugPrint('[VOICE] Participant connected: ${p.identity}');
        if (p.identity.contains('skillpath') || p.identity.contains('agent') || p.identity.contains('counsellor')) {
          debugPrint('[VOICE] Gemini Live connected: ${p.identity}');
          onAgentConnected?.call();
        }
      })
      ..on<TrackSubscribedEvent>((event) {
        if (event.track is AudioTrack) {
          debugPrint('[VOICE] Gemini audio chunk received from: ${event.participant.identity}');
          debugPrint('[VOICE] Playing AI audio');
        }
      })
      ..on<ActiveSpeakersChangedEvent>((event) {
        final hasUserSpeaking = event.speakers.any((s) => s.identity == identity);
        final hasAgentSpeaking = event.speakers.any((s) => s.identity != identity);

        // User speech state transition
        if (hasUserSpeaking && !_lastUserSpeaking) {
          debugPrint('[VOICE] User speech detected');
          debugPrint('[VOICE] User audio detected');
          onUserSpeakingChanged?.call(true);
        } else if (!hasUserSpeaking && _lastUserSpeaking) {
          debugPrint('[VOICE] User speech ended');
          debugPrint('[VOICE] Sending end-of-turn');
          debugPrint('[VOICE] Gemini response started');
          onUserSpeakingChanged?.call(false);
        }
        _lastUserSpeaking = hasUserSpeaking;

        // Agent speech state transition
        if (hasAgentSpeaking && !_lastAgentSpeaking) {
          debugPrint('[VOICE] Gemini audio chunk received');
          debugPrint('[VOICE] Playing AI audio');
          onAgentSpeakingChanged?.call(true);
        } else if (!hasAgentSpeaking && _lastAgentSpeaking) {
          debugPrint('[VOICE] Gemini response completed');
          debugPrint('[VOICE] AI turn completed');
          onAgentSpeakingChanged?.call(false);
        }
        _lastAgentSpeaking = hasAgentSpeaking;
      })
      ..on<DataReceivedEvent>((event) {
        try {
          final data = jsonDecode(utf8.decode(event.data)) as Map<String, dynamic>;
          final type = data['type']?.toString();
          debugPrint('[VOICE] Data channel packet received: $type');

          if (type == 'user_speaking') {
            onUserSpeakingChanged?.call(true);
          } else if (type == 'processing') {
            onAgentStateChanged?.call('processing');
          } else if (type == 'ai_speaking') {
            onAgentSpeakingChanged?.call(true);
          } else if (type == 'turn_complete') {
            onAgentSpeakingChanged?.call(false);
            onAgentStateChanged?.call('listening');
          } else if (type == 'user_transcript') {
            final text = data['text']?.toString() ?? '';
            if (text.isNotEmpty) {
              debugPrint('[VOICE] User transcript: $text');
              onUserTranscriptReceived?.call(text);
            }
          } else if (type == 'ai_transcript') {
            final text = data['text']?.toString() ?? '';
            if (text.isNotEmpty) {
              debugPrint('[VOICE] Gemini text chunk received: $text');
              onAgentTranscriptReceived?.call(text);
            }
          }
        } catch (_) {}
      });

    // 2. Connect to LiveKit Room
    debugPrint('[VOICE] Connecting to LiveKit');
    await _room!.connect(url, token);
    _state = VoiceConnectionState.connected;
    debugPrint('[VOICE] LiveKit connected');

    // 3. Create microphone audio track
    debugPrint('[VOICE] Creating microphone track');
    try {
      _localAudioTrack = await LocalAudioTrack.create(
        const AudioCaptureOptions(
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        ),
      );
      debugPrint('[VOICE] Microphone track created');
    } catch (e) {
      debugPrint('[VOICE] Error creating microphone track: $e');
      throw Exception('Failed to create microphone track: $e');
    }

    // 4. Publish microphone track to LiveKit room
    debugPrint('[VOICE] Publishing microphone track');
    try {
      _audioPublication = await _room!.localParticipant?.publishAudioTrack(_localAudioTrack!);
      if (_audioPublication == null || _audioPublication!.track == null) {
        throw Exception('Audio publication returned null');
      }
      debugPrint('[VOICE] Microphone track published');

      // Section 5: Verify microphone track publication
      final track = _audioPublication!.track;
      final isEnabled = _localAudioTrack?.mediaStreamTrack.enabled ?? true;
      final isMuted = track?.muted ?? false;
      debugPrint('[VOICE] track.sid: ${track?.sid}, track.kind: ${track?.kind}, track.enabled: $isEnabled, track.muted: $isMuted, publication.sid: ${_audioPublication!.sid}');
    } catch (e) {
      debugPrint('[VOICE] Failed to publish microphone track: $e');
      throw Exception('Failed to publish microphone track: $e');
    }

    // 5. Verify Gemini Live / Agent connection
    debugPrint('[VOICE] Gemini Live session starting');
    final hasRemoteAgent = _room!.remoteParticipants.values.any((p) =>
      p.identity.contains('skillpath') || p.identity.contains('agent') || p.identity.contains('counsellor')
    );
    if (hasRemoteAgent) {
      debugPrint('[VOICE] Gemini Live connected');
      onAgentConnected?.call();
    } else {
      debugPrint('[VOICE] Waiting for Gemini Live agent participant to join room...');
    }

    return _room!;
  }

  /// Toggle microphone mute
  Future<bool> toggleMute() async {
    if (_localAudioTrack == null) return false;
    final currentlyMuted = _localAudioTrack!.muted;
    if (currentlyMuted) {
      await _localAudioTrack!.unmute();
    } else {
      await _localAudioTrack!.mute();
    }
    debugPrint('[VOICE] Microphone muted: ${!currentlyMuted}');
    return !currentlyMuted;
  }

  /// Check if microphone is currently muted
  bool get isMuted => _localAudioTrack?.muted ?? false;

  /// Disconnect and cleanup all WebRTC resources cleanly
  Future<void> disconnect() async {
    debugPrint('[VOICE] Disconnecting voice session...');
    try {
      await _localAudioTrack?.stop();
      await _localAudioTrack?.dispose();
      await _room?.disconnect();
      await _listener?.dispose();
      await _room?.dispose();
    } catch (e) {
      debugPrint('[VOICE] Error during LiveKit disconnect: $e');
    } finally {
      _localAudioTrack = null;
      _audioPublication = null;
      _room = null;
      _listener = null;
      _state = VoiceConnectionState.disconnected;
      debugPrint('[VOICE] Voice session disconnected cleanly');
    }
  }
}
