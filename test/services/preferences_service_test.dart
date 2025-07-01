import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_coach/models/coach_persona.dart';
import 'package:pocket_coach/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    setUp(() async {
      // Clear any existing preferences and initialize fresh for each test
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.initialize();
      await PreferencesService.clear();
    });

    group('Initialization', () {
      test('should initialize without error', () async {
        // Clear and re-initialize to test initialization
        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();
        
        // Should not throw when accessing preferences after initialization
        expect(() => PreferencesService.appTheme, isNot(throwsException));
      });

      test('should throw exception when not initialized', () async {
        // Create a fresh service instance that hasn't been initialized
        // This is hard to test with the current static implementation
        // TODO: Consider making PreferencesService non-static for better testability
        // For now, we document that initialization is required
      });
    });

    group('LLM API Key', () {
      test('should return null when no API key is set', () {
        expect(PreferencesService.llmApiKey, null);
      });

      test('should store and retrieve LLM API key', () async {
        const testKey = 'test-llm-api-key-12345';
        
        await PreferencesService.setLlmApiKey(testKey);
        expect(PreferencesService.llmApiKey, testKey);
      });

      test('should handle empty LLM API key', () async {
        await PreferencesService.setLlmApiKey('');
        expect(PreferencesService.llmApiKey, '');
      });

      test('should handle very long LLM API key', () async {
        final longKey = 'a' * 1000;
        await PreferencesService.setLlmApiKey(longKey);
        expect(PreferencesService.llmApiKey, longKey);
      });
    });

    group('TTS API Key', () {
      test('should return null when no TTS API key is set', () {
        expect(PreferencesService.ttsApiKey, null);
      });

      test('should store and retrieve TTS API key', () async {
        const testKey = 'test-tts-api-key-67890';
        
        await PreferencesService.setTtsApiKey(testKey);
        expect(PreferencesService.ttsApiKey, testKey);
      });

      test('should handle empty TTS API key', () async {
        await PreferencesService.setTtsApiKey('');
        expect(PreferencesService.ttsApiKey, '');
      });
    });

    group('Default Coach Persona', () {
      test('should return Willow as default when no persona is set', () {
        expect(PreferencesService.defaultCoachPersonaId, CoachPersonaId.willow);
      });

      test('should store and retrieve coach persona', () async {
        await PreferencesService.setDefaultCoachPersonaId(CoachPersonaId.sterling);
        expect(PreferencesService.defaultCoachPersonaId, CoachPersonaId.sterling);
      });

      test('should handle all valid coach personas', () async {
        for (final persona in CoachPersonaId.values) {
          await PreferencesService.setDefaultCoachPersonaId(persona);
          expect(PreferencesService.defaultCoachPersonaId, persona);
        }
      });

      test('should fall back to default for invalid stored persona', () async {
        // Directly set an invalid value in SharedPreferences to test error handling
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('defaultCoachPersonaId', 'invalid_persona');
        
        expect(PreferencesService.defaultCoachPersonaId, CoachPersonaId.willow);
      });
    });

    group('Default Check-in Minutes', () {
      test('should return 20 as default when no value is set', () {
        expect(PreferencesService.defaultCheckInMinutes, 20);
      });

      test('should store and retrieve check-in minutes', () async {
        await PreferencesService.setDefaultCheckInMinutes(45);
        expect(PreferencesService.defaultCheckInMinutes, 45);
      });

      test('should handle minimum value', () async {
        await PreferencesService.setDefaultCheckInMinutes(1);
        expect(PreferencesService.defaultCheckInMinutes, 1);
      });

      test('should handle large value', () async {
        await PreferencesService.setDefaultCheckInMinutes(999);
        expect(PreferencesService.defaultCheckInMinutes, 999);
      });

      test('should handle zero value', () async {
        await PreferencesService.setDefaultCheckInMinutes(0);
        expect(PreferencesService.defaultCheckInMinutes, 0);
      });

      test('should handle negative value', () async {
        // Note: This may not make business sense, but tests the storage mechanism
        await PreferencesService.setDefaultCheckInMinutes(-5);
        expect(PreferencesService.defaultCheckInMinutes, -5);
      });
    });

    group('App Theme', () {
      test('should return "system" as default when no theme is set', () {
        expect(PreferencesService.appTheme, 'system');
      });

      test('should store and retrieve app theme', () async {
        await PreferencesService.setAppTheme('dark');
        expect(PreferencesService.appTheme, 'dark');
      });

      test('should handle all expected theme values', () async {
        final themes = ['light', 'dark', 'system'];
        
        for (final theme in themes) {
          await PreferencesService.setAppTheme(theme);
          expect(PreferencesService.appTheme, theme);
        }
      });

      test('should handle custom theme value', () async {
        await PreferencesService.setAppTheme('custom_theme');
        expect(PreferencesService.appTheme, 'custom_theme');
      });

      test('should handle empty theme value', () async {
        await PreferencesService.setAppTheme('');
        expect(PreferencesService.appTheme, '');
      });
    });

    group('Notifications Enabled', () {
      test('should return true as default when no value is set', () {
        expect(PreferencesService.notificationsEnabled, true);
      });

      test('should store and retrieve notifications enabled state', () async {
        await PreferencesService.setNotificationsEnabled(false);
        expect(PreferencesService.notificationsEnabled, false);
        
        await PreferencesService.setNotificationsEnabled(true);
        expect(PreferencesService.notificationsEnabled, true);
      });
    });

    group('TTS Enabled', () {
      test('should return true as default when no value is set', () {
        expect(PreferencesService.ttsEnabled, true);
      });

      test('should store and retrieve TTS enabled state', () async {
        await PreferencesService.setTtsEnabled(false);
        expect(PreferencesService.ttsEnabled, false);
        
        await PreferencesService.setTtsEnabled(true);
        expect(PreferencesService.ttsEnabled, true);
      });
    });

    group('Clear preferences', () {
      test('should clear all stored preferences', () async {
        // Set various preferences
        await PreferencesService.setLlmApiKey('test-key');
        await PreferencesService.setDefaultCoachPersonaId(CoachPersonaId.sterling);
        await PreferencesService.setDefaultCheckInMinutes(60);
        await PreferencesService.setAppTheme('dark');
        await PreferencesService.setNotificationsEnabled(false);
        await PreferencesService.setTtsEnabled(false);
        
        // Verify they are set
        expect(PreferencesService.llmApiKey, 'test-key');
        expect(PreferencesService.defaultCoachPersonaId, CoachPersonaId.sterling);
        expect(PreferencesService.defaultCheckInMinutes, 60);
        expect(PreferencesService.appTheme, 'dark');
        expect(PreferencesService.notificationsEnabled, false);
        expect(PreferencesService.ttsEnabled, false);
        
        // Clear all preferences
        await PreferencesService.clear();
        
        // Verify they return to defaults
        expect(PreferencesService.llmApiKey, null);
        expect(PreferencesService.defaultCoachPersonaId, CoachPersonaId.willow);
        expect(PreferencesService.defaultCheckInMinutes, 20);
        expect(PreferencesService.appTheme, 'system');
        expect(PreferencesService.notificationsEnabled, true);
        expect(PreferencesService.ttsEnabled, true);
      });
    });

    group('Persistence across service instances', () {
      test('should persist values across service re-initialization', () async {
        // Set a value
        await PreferencesService.setLlmApiKey('persistent-key');
        await PreferencesService.setDefaultCheckInMinutes(75);
        
        // Re-initialize the service (simulating app restart)
        await PreferencesService.initialize();
        
        // Values should still be there
        expect(PreferencesService.llmApiKey, 'persistent-key');
        expect(PreferencesService.defaultCheckInMinutes, 75);
      });
    });

    group('Integration tests', () {
      test('should handle multiple concurrent operations', () async {
        // Test that multiple async operations don't interfere with each other
        final futures = [
          PreferencesService.setLlmApiKey('concurrent-key-1'),
          PreferencesService.setTtsApiKey('concurrent-key-2'),
          PreferencesService.setDefaultCheckInMinutes(30),
          PreferencesService.setAppTheme('light'),
          PreferencesService.setNotificationsEnabled(false),
          PreferencesService.setTtsEnabled(true),
        ];
        
        await Future.wait(futures);
        
        // Verify all values were set correctly
        expect(PreferencesService.llmApiKey, 'concurrent-key-1');
        expect(PreferencesService.ttsApiKey, 'concurrent-key-2');
        expect(PreferencesService.defaultCheckInMinutes, 30);
        expect(PreferencesService.appTheme, 'light');
        expect(PreferencesService.notificationsEnabled, false);
        expect(PreferencesService.ttsEnabled, true);
      });

      test('should handle rapid successive updates to the same preference', () async {
        // Test rapid updates to ensure the last value wins
        for (int i = 0; i < 10; i++) {
          await PreferencesService.setDefaultCheckInMinutes(i);
        }
        
        expect(PreferencesService.defaultCheckInMinutes, 9);
      });
    });

    group('Edge cases and error handling', () {
      test('should handle null/empty string values appropriately', () async {
        // Empty strings should be stored as empty strings, not null
        await PreferencesService.setLlmApiKey('');
        expect(PreferencesService.llmApiKey, '');
        
        await PreferencesService.setAppTheme('');
        expect(PreferencesService.appTheme, '');
      });

      test('should handle special characters in string values', () async {
        const specialKey = 'key-with-special-chars-!@#\$%^&*()_+-=[]{}|;:,.<>?';
        await PreferencesService.setLlmApiKey(specialKey);
        expect(PreferencesService.llmApiKey, specialKey);
      });

      test('should handle unicode characters in string values', () async {
        const unicodeKey = 'test-key-🔑-测试-🚀';
        await PreferencesService.setLlmApiKey(unicodeKey);
        expect(PreferencesService.llmApiKey, unicodeKey);
      });
    });
  });
}