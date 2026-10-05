import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState {
  final String languageCode; // 'en' or 'ta'
  final bool isLowLiteracyMode;

  const LocaleState({
    this.languageCode = 'en',
    this.isLowLiteracyMode = false,
  });

  bool get isTamil => languageCode == 'ta';

  LocaleState copyWith({
    String? languageCode,
    bool? isLowLiteracyMode,
  }) {
    return LocaleState(
      languageCode: languageCode ?? this.languageCode,
      isLowLiteracyMode: isLowLiteracyMode ?? this.isLowLiteracyMode,
    );
  }
}

class LocaleNotifier extends StateNotifier<LocaleState> {
  LocaleNotifier() : super(const LocaleState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('app_language') ?? 'en';
      final lowLit = prefs.getBool('low_literacy_mode') ?? false;
      state = LocaleState(languageCode: lang, isLowLiteracyMode: lowLit);
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', code);
    } catch (_) {}
  }

  Future<void> toggleLowLiteracyMode(bool enabled) async {
    state = state.copyWith(isLowLiteracyMode: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('low_literacy_mode', enabled);
    } catch (_) {}
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});
