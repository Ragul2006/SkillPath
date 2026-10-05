import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/counselling_service.dart';
import '../../core/services/livekit_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Detailed voice conversation state for UI matching state machine
enum VoiceState {
  idle,
  connecting,
  listening,
  userSpeaking,
  processing,
  aiSpeaking,
  error,
  disconnected,
}

/// AI counsellor voice-first and text-fallback interface powered by LiveKit & Gemini Live
class AiCounsellorScreen extends StatefulWidget {
  const AiCounsellorScreen({super.key});

  @override
  State<AiCounsellorScreen> createState() => _AiCounsellorScreenState();
}

class _AiCounsellorScreenState extends State<AiCounsellorScreen>
    with SingleTickerProviderStateMixin {
  final LiveKitService _liveKitService = LiveKitService();
  VoiceState _voiceState = VoiceState.idle;
  String _selectedLanguage = 'ta'; // Default to Tamil
  bool _isMuted = false;
  String? _conversationId;
  String _errorMessage = '';

  final List<_TranscriptEntry> _transcript = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  Timer? _inactivityTimer;
  Timer? _agentTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Initialize initial greeting
    _initializeConversation();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_voiceState == VoiceState.listening) {
      _inactivityTimer = Timer(const Duration(seconds: 45), () {
        if (mounted && _voiceState == VoiceState.listening) {
          debugPrint('[VOICE] Inactivity timeout reached (45s silence). Returning to idle.');
          _endVoiceSession();
        }
      });
    }
  }

  Future<void> _initializeConversation() async {
    final userId = SupabaseService.currentUserId ?? 'guest_${DateTime.now().millisecondsSinceEpoch % 10000}';
    _conversationId = await CounsellingService.getOrCreateActiveConversation(
      userId: userId,
      language: _selectedLanguage,
    );

    // Retrieve existing conversation history from public.messages
    final existingMessages = await CounsellingService.getConversationHistory(_conversationId!);

    if (!mounted) return;

    if (existingMessages.isNotEmpty) {
      setState(() {
        _transcript.clear();
        for (final m in existingMessages) {
          final isUser = m['sender'] != 'ai';
          _transcript.add(
            _TranscriptEntry(
              sender: isUser ? 'You' : 'AI',
              message: m['message']?.toString() ?? '',
              time: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
            ),
          );
        }
      });
      _scrollToBottom();
    } else {
      // First message of a brand new session only
      final initialGreeting = _selectedLanguage == 'ta'
          ? 'வணக்கம்! நான் SkillPath AI தொழிற்கல்வி ஆலோசகர். உங்கள் குழந்தையின் career options பற்றி பேசலாம். எந்த career பற்றி தெரிந்துகொள்ள விரும்புகிறீர்கள்?'
          : 'Hello! I am the SkillPath AI Career Counsellor. I can help your family evaluate verified vocational trades, salaries, training providers, and career progression. Tap the microphone to talk or type below.';

      setState(() {
        _transcript.add(
          _TranscriptEntry(
            sender: 'AI',
            message: initialGreeting,
            time: DateTime.now(),
          ),
        );
      });

      await CounsellingService.saveMessage(
        conversationId: _conversationId!,
        sender: 'ai',
        message: initialGreeting,
      );
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _agentTimeoutTimer?.cancel();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _liveKitService.disconnect();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startVoiceSession() async {
    debugPrint('[VOICE] Voice button pressed');

    // 1. Microphone permission
    final hasPermission = await _liveKitService.requestMicrophonePermission(context);
    if (!hasPermission) {
      setState(() {
        _voiceState = VoiceState.error;
        _errorMessage = _selectedLanguage == 'ta'
            ? 'மைக்ரோஃபோன் அனுமதி தேவைப்படுகிறது. குரல் வழி பேச அமைப்புகளில் அனுமதியை வழங்கவும்.'
            : 'Microphone access is required for voice counselling.';
      });
      return;
    }

    setState(() {
      _voiceState = VoiceState.connecting;
      _errorMessage = '';
    });
    _pulseController.repeat(reverse: true);

    try {
      final userId = SupabaseService.currentUserId ?? 'user_${DateTime.now().millisecondsSinceEpoch % 10000}';
      const roomName = 'skillpath_counselling';

      // 2. Fetch backend token (keeps LiveKit secret safe on backend)
      final token = await _liveKitService.fetchAccessToken(
        identity: userId,
        roomName: roomName,
      );

      // Set timeout timer for agent connection (8 seconds)
      _agentTimeoutTimer?.cancel();
      _agentTimeoutTimer = Timer(const Duration(seconds: 10), () {
        if (mounted && _voiceState == VoiceState.connecting) {
          debugPrint('[VOICE] Gemini Live connection timeout: agent participant not in room');
          setState(() {
            _voiceState = VoiceState.error;
            _errorMessage = _selectedLanguage == 'ta'
                ? 'AI குரல் ஆலோசகர் இணைப்பு தோல்வியடைந்தது. Tap to retry அல்லது கீழே உரை மூலம் பேசவும்.'
                : 'Voice AI connection failed. Tap to retry, or continue with text chat.';
            _pulseController.stop();
          });
        }
      });

      // 3. Connect to LiveKit Room following strict pipeline order
      await _liveKitService.connect(
        identity: userId,
        roomName: roomName,
        token: token,
        onAgentSpeakingChanged: (isSpeaking) {
          if (!mounted) return;
          setState(() {
            if (isSpeaking) {
              _voiceState = VoiceState.aiSpeaking;
              _inactivityTimer?.cancel();
            } else {
              _voiceState = VoiceState.listening;
              _resetInactivityTimer();
            }
          });
        },
        onUserSpeakingChanged: (isSpeaking) {
          if (!mounted) return;
          setState(() {
            if (isSpeaking) {
              _voiceState = VoiceState.userSpeaking;
              _inactivityTimer?.cancel();
            } else {
              _voiceState = VoiceState.processing;
            }
          });
        },
        onAgentStateChanged: (state) {
          if (!mounted) return;
          setState(() {
            if (state == 'processing') {
              _voiceState = VoiceState.processing;
            } else if (state == 'listening') {
              _voiceState = VoiceState.listening;
              _resetInactivityTimer();
            }
          });
        },
        onUserTranscriptReceived: (text) {
          if (!mounted) return;
          setState(() {
            _transcript.add(
              _TranscriptEntry(
                sender: 'You',
                message: text,
                time: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
          if (_conversationId != null) {
            CounsellingService.saveMessage(
              conversationId: _conversationId!,
              sender: 'parent',
              message: text,
              intent: 'voice_counselling',
            );
          }
        },
        onAgentTranscriptReceived: (text) {
          if (!mounted) return;
          setState(() {
            _transcript.add(
              _TranscriptEntry(
                sender: 'AI',
                message: text,
                time: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
          if (_conversationId != null) {
            CounsellingService.saveMessage(
              conversationId: _conversationId!,
              sender: 'ai',
              message: text,
              intent: 'voice_counselling',
            );
          }
        },
        onAgentConnected: () {
          _agentTimeoutTimer?.cancel();
          if (!mounted) return;
          setState(() {
            _voiceState = VoiceState.listening;
          });
          _resetInactivityTimer();
        },
        onDisconnected: () {
          _inactivityTimer?.cancel();
          _agentTimeoutTimer?.cancel();
          if (!mounted) return;
          setState(() {
            _voiceState = VoiceState.disconnected;
            _pulseController.stop();
            _pulseController.reset();
          });
        },
        onError: (err) {
          _inactivityTimer?.cancel();
          _agentTimeoutTimer?.cancel();
          if (!mounted) return;
          setState(() {
            _voiceState = VoiceState.error;
            _errorMessage = err;
            _pulseController.stop();
          });
        },
      );

      // Verify track publication before entering listening
      if (_liveKitService.hasActiveAudioTrack) {
        setState(() {
          _voiceState = VoiceState.listening;
        });
        _resetInactivityTimer();
      }
    } catch (e) {
      _inactivityTimer?.cancel();
      _agentTimeoutTimer?.cancel();
      debugPrint('[VOICE] LiveKit connection error: $e');
      setState(() {
        _voiceState = VoiceState.error;
        _errorMessage = _selectedLanguage == 'ta'
            ? 'Voice connection failed. Tap to retry.'
            : 'Voice connection failed. Tap to retry.';
        _pulseController.stop();
      });
    }
  }

  Future<void> _endVoiceSession() async {
    _inactivityTimer?.cancel();
    _agentTimeoutTimer?.cancel();
    await _liveKitService.disconnect();
    setState(() {
      _voiceState = VoiceState.disconnected;
      _pulseController.stop();
      _pulseController.reset();
    });
  }

  Future<void> _toggleMute() async {
    final muted = await _liveKitService.toggleMute();
    setState(() {
      _isMuted = muted;
    });
  }

  void _sendTextMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final entryTime = DateTime.now();
    setState(() {
      _transcript.add(
        _TranscriptEntry(
          sender: 'You',
          message: text,
          time: entryTime,
        ),
      );
      _textController.clear();
      if (_voiceState == VoiceState.idle || _voiceState == VoiceState.disconnected) {
        _voiceState = VoiceState.processing;
      }
    });
    _scrollToBottom();

    // 1. Generate response via CounsellingService with full conversation context and database grounding
    final reply = await CounsellingService.sendMessage(
      conversationId: _conversationId!,
      userMessage: text,
      userRole: 'parent',
      language: _selectedLanguage,
    );

    if (!mounted) return;
    setState(() {
      _transcript.add(
        _TranscriptEntry(
          sender: 'AI',
          message: reply,
          time: DateTime.now(),
        ),
      );
      if (_voiceState == VoiceState.processing) {
        _voiceState = VoiceState.idle;
      }
    });
    _scrollToBottom();
  }

  void _showEscalationDialog() {
    final reasonController = TextEditingController();
    String selectedPriority = 'Medium';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                _selectedLanguage == 'ta' ? 'மனித ஆலோசகர் உதவி' : 'Connect with Counsellor',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedLanguage == 'ta'
                    ? 'உங்கள் கேள்விகளுக்கு கூடுதல் தெளிவு பெற ஒரு அங்கீகரிக்கப்பட்ட மனித தொழிற்கல்வி ஆலோசகரிடம் 1-on-1 வழிகாட்டுதலை கோரலாம்.'
                    : 'Request 1-on-1 human counselling from an accredited MSDE vocational guidance expert.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: _selectedLanguage == 'ta'
                      ? 'உங்கள் கேள்வி அல்லது கவலையை குறிப்பிடவும்...'
                      : 'Describe your question or concern (e.g. salary vs degree)...',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: InputDecoration(
                  labelText: _selectedLanguage == 'ta' ? 'முன்னுரிமை (Priority)' : 'Priority',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low / குறைவு')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium / நடுத்தரம்')),
                  DropdownMenuItem(value: 'High', child: Text('High / அதிகம்')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedPriority = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(_selectedLanguage == 'ta' ? 'ரத்து செய்' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                final userId = SupabaseService.currentUserId ?? 'guest';
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogCtx);

                if (_conversationId != null) {
                  await CounsellingService.createEscalation(
                    userId: userId,
                    conversationId: _conversationId!,
                    reason: reason.isNotEmpty ? reason : 'Requested human guidance via counselling screen',
                    priority: selectedPriority,
                  );
                }

                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedLanguage == 'ta'
                            ? 'ஆலோசகர் கோரிக்கை வெற்றிகரமாக பதிவு செய்யப்பட்டது! விரைவில் உங்களை தொடர்புகொள்வார்கள்.'
                            : 'Counsellor request submitted successfully! An expert will follow up.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(
                _selectedLanguage == 'ta' ? 'கோரிக்கையை அனுப்பு' : 'Submit Request',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusHeader() {
    switch (_voiceState) {
      case VoiceState.idle:
        return _selectedLanguage == 'ta' ? '🎤 பேசத் தொடங்குங்கள்' : '🎤 Tap to Talk';
      case VoiceState.connecting:
        return _selectedLanguage == 'ta' ? 'SkillPath உடன் இணைகிறது...' : 'Connecting to SkillPath...';
      case VoiceState.listening:
        return _selectedLanguage == 'ta' ? 'SkillPath கேட்கிறது...' : 'SkillPath is listening...';
      case VoiceState.userSpeaking:
        return _selectedLanguage == 'ta' ? 'உங்கள் பேச்சைக் கேட்கிறது...' : 'Listening to you...';
      case VoiceState.processing:
        return _selectedLanguage == 'ta' ? 'SkillPath சிந்திக்கிறது...' : 'SkillPath is thinking...';
      case VoiceState.aiSpeaking:
        return _selectedLanguage == 'ta' ? '🔊 SkillPath பதிலளிக்கிறது...' : '🔊 SkillPath is responding...';
      case VoiceState.error:
        return _selectedLanguage == 'ta' ? 'குரல் இணைப்பு தோல்வி' : 'Voice connection failed. Tap to retry.';
      case VoiceState.disconnected:
        return _selectedLanguage == 'ta' ? 'அமர்வு முடிந்தது' : 'Session ended';
    }
  }

  String _getMicSubtitle() {
    switch (_voiceState) {
      case VoiceState.idle:
        return _selectedLanguage == 'ta'
            ? 'குரல் வழி பேச மைக்ரோஃபோனைத் தொடவும் அல்லது கீழே தட்டச்சு செய்யவும்'
            : 'Tap mic to talk, or type below';
      case VoiceState.connecting:
        return _selectedLanguage == 'ta'
            ? 'SkillPath உடன் இணைகிறது...'
            : 'Connecting to SkillPath...';
      case VoiceState.listening:
        return _selectedLanguage == 'ta'
            ? 'SkillPath கேட்கிறது... பேசுங்கள்'
            : 'SkillPath is listening... Speak freely';
      case VoiceState.userSpeaking:
        return _selectedLanguage == 'ta'
            ? 'உங்கள் குரலைக் கேட்கிறது...'
            : 'Listening to you...';
      case VoiceState.processing:
        return _selectedLanguage == 'ta'
            ? 'SkillPath சிந்திக்கிறது...'
            : 'SkillPath is thinking...';
      case VoiceState.aiSpeaking:
        return _selectedLanguage == 'ta'
            ? 'SkillPath பதிலளிக்கிறது... (இடைமறிக்க பேசவும்)'
            : 'SkillPath is responding... (speak to interrupt)';
      case VoiceState.error:
        return _selectedLanguage == 'ta'
            ? 'குரல் இணைப்பு தோல்வி. மீண்டும் முயல தட்டவும்.'
            : 'Voice connection failed. Tap to retry.';
      case VoiceState.disconnected:
        return _selectedLanguage == 'ta'
            ? 'குரல் அமர்வு முடிந்தது. மீண்டும் பேச தட்டவும்.'
            : 'Voice session ended. Tap mic to restart.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVoiceActive = _voiceState == VoiceState.connecting ||
        _voiceState == VoiceState.listening ||
        _voiceState == VoiceState.userSpeaking ||
        _voiceState == VoiceState.processing ||
        _voiceState == VoiceState.aiSpeaking;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SkillPath AI Counsellor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isVoiceActive
                        ? AppColors.success
                        : (_voiceState == VoiceState.error ? AppColors.error : AppColors.textTertiary),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _getStatusHeader(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isVoiceActive ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Human Escalation CTA
          IconButton(
            tooltip: _selectedLanguage == 'ta' ? 'மனித ஆலோசகர்' : 'Human Counsellor',
            icon: const Icon(Icons.support_agent_rounded),
            onPressed: _showEscalationDialog,
          ),
          // Language selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.language_rounded),
            tooltip: 'Language / மொழி',
            initialValue: _selectedLanguage,
            onSelected: (lang) {
              setState(() {
                _selectedLanguage = lang;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ta', child: Text('தமிழ் (Tamil)')),
              const PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ⓘ Demo Data Warning Banner (Section 30)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.infoSurface,
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLanguage == 'ta'
                        ? 'ⓘ மாதிரி தரவு: இங்கு காட்டப்படும் தொழில் புள்ளிவிவரங்கள் SkillPath முன்மாதிரிக்காக உருவாக்கப்பட்ட மாதிரித் தரவு.'
                        : 'ⓘ Demo Data: Career outcomes shown here are synthetic data created for the SkillPath prototype.',
                    style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Error / Fallback Banner if voice fails (Section 9 & 11)
          if (_voiceState == VoiceState.error)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.errorSurface,
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage.isNotEmpty
                          ? _errorMessage
                          : (_selectedLanguage == 'ta'
                              ? 'AI குரல் இணைப்பு தோல்வியடைந்தது. உரை மூலம் பேசவும்.'
                              : 'Voice unavailable. Continue with text chat.'),
                      style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: _startVoiceSession,
                    child: Text(_selectedLanguage == 'ta' ? 'மீண்டும் முயல்' : 'Retry'),
                  ),
                ],
              ),
            ),

          // Conversation Transcript Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _transcript.length,
              itemBuilder: (context, index) {
                final entry = _transcript[index];
                final isUser = entry.sender == 'You';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUser ? Icons.person_outline_rounded : Icons.auto_awesome_rounded,
                              size: 14,
                              color: isUser ? Colors.white70 : AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isUser ? (_selectedLanguage == 'ta' ? 'நீங்கள்' : 'You') : 'SkillPath AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isUser ? Colors.white70 : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isUser ? Colors.white : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Interactive Voice & Text Control Dock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Voice Interaction Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mute button if connected
                      if (isVoiceActive) ...[
                        IconButton.filledTonal(
                          onPressed: _toggleMute,
                          icon: Icon(_isMuted ? Icons.mic_off_rounded : Icons.mic_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: _isMuted ? AppColors.errorSurface : AppColors.surfaceVariant,
                            foregroundColor: _isMuted ? AppColors.error : AppColors.textPrimary,
                          ),
                          tooltip: _isMuted ? 'Unmute' : 'Mute',
                        ),
                        const SizedBox(width: 20),
                      ],

                      // Central Pulse Mic Button
                      GestureDetector(
                        onTap: () {
                          if (isVoiceActive) {
                            _endVoiceSession();
                          } else {
                            _startVoiceSession();
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = isVoiceActive
                                ? 1.0 + (_pulseController.value * (_voiceState == VoiceState.aiSpeaking ? 0.16 : 0.08))
                                : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isVoiceActive
                                      ? (_voiceState == VoiceState.aiSpeaking
                                          ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF0D9488)])
                                          : (_voiceState == VoiceState.userSpeaking
                                              ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
                                              : const LinearGradient(colors: [AppColors.secondary, Color(0xFF2563EB)])))
                                      : (_voiceState == VoiceState.error
                                          ? const LinearGradient(colors: [AppColors.warning, AppColors.error])
                                          : AppColors.primaryGradient),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isVoiceActive ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      spreadRadius: isVoiceActive ? 3 : 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isVoiceActive
                                      ? (_voiceState == VoiceState.aiSpeaking
                                          ? Icons.volume_up_rounded
                                          : (_voiceState == VoiceState.userSpeaking
                                              ? Icons.mic_rounded
                                              : Icons.graphic_eq_rounded))
                                      : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // End session button if connected
                      if (isVoiceActive) ...[
                        const SizedBox(width: 20),
                        IconButton.filledTonal(
                          onPressed: _endVoiceSession,
                          icon: const Icon(Icons.call_end_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.errorSurface,
                            foregroundColor: AppColors.error,
                          ),
                          tooltip: _selectedLanguage == 'ta' ? 'அமர்வை முடி' : 'End Call',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Mic Status Subtitle (Section 18)
                  Text(
                    _getMicSubtitle(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isVoiceActive ? AppColors.secondary : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Integrated Text Chat Row (Seamless Fallback)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: _selectedLanguage == 'ta'
                                ? 'கேள்வியை தட்டச்சு செய்யவும்...'
                                : 'Type career questions (e.g. CNC, salary, degree)...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          onSubmitted: (_) => _sendTextMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sendTextMessage,
                        icon: const Icon(Icons.send_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: 'Send',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranscriptEntry {
  final String sender;
  final String message;
  final DateTime time;

  const _TranscriptEntry({
    required this.sender,
    required this.message,
    required this.time,
  });
}
