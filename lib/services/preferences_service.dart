import 'package:shared_preferences/shared_preferences.dart';
import '../models/coach_persona.dart';

class PreferencesService {
  static const String _llmApiKeyKey = 'llmApiKey';
  static const String _ttsApiKeyKey = 'ttsApiKey';
  static const String _defaultCoachPersonaIdKey = 'defaultCoachPersonaId';
  static const String _defaultCheckInMinutesKey = 'defaultCheckInMinutes';
  static const String _appThemeKey = 'appTheme';
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _ttsEnabledKey = 'ttsEnabled';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call PreferencesService.initialize() first.');
    }
    return _prefs!;
  }

  // LLM API Key
  static String? get llmApiKey => _preferences.getString(_llmApiKeyKey);
  static Future<void> setLlmApiKey(String key) async {
    await _preferences.setString(_llmApiKeyKey, key);
  }

  // TTS API Key
  static String? get ttsApiKey => _preferences.getString(_ttsApiKeyKey);
  static Future<void> setTtsApiKey(String key) async {
    await _preferences.setString(_ttsApiKeyKey, key);
  }

  // Default Coach Persona
  static CoachPersonaId get defaultCoachPersonaId {
    final savedId = _preferences.getString(_defaultCoachPersonaIdKey);
    if (savedId != null) {
      try {
        return CoachPersonaId.values.firstWhere((e) => e.name == savedId);
      } catch (e) {
        // If saved value is invalid, fall back to default
      }
    }
    return CoachPersonaId.willow; // Default coach
  }

  static Future<void> setDefaultCoachPersonaId(CoachPersonaId personaId) async {
    await _preferences.setString(_defaultCoachPersonaIdKey, personaId.name);
  }

  // Default Check-in Minutes
  static int get defaultCheckInMinutes => _preferences.getInt(_defaultCheckInMinutesKey) ?? 20;
  static Future<void> setDefaultCheckInMinutes(int minutes) async {
    await _preferences.setInt(_defaultCheckInMinutesKey, minutes);
  }

  // App Theme
  static String get appTheme => _preferences.getString(_appThemeKey) ?? 'system';
  static Future<void> setAppTheme(String theme) async {
    await _preferences.setString(_appThemeKey, theme);
  }

  // Notifications Enabled
  static bool get notificationsEnabled => _preferences.getBool(_notificationsEnabledKey) ?? true;
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _preferences.setBool(_notificationsEnabledKey, enabled);
  }

  // TTS Enabled
  static bool get ttsEnabled => _preferences.getBool(_ttsEnabledKey) ?? true;
  static Future<void> setTtsEnabled(bool enabled) async {
    await _preferences.setBool(_ttsEnabledKey, enabled);
  }

  // Clear all preferences (for testing/reset)
  static Future<void> clear() async {
    await _preferences.clear();
  }
}