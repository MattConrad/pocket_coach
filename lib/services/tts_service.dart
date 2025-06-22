import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import '../models/coach_persona.dart';
import 'preferences_service.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (!Platform.isAndroid && !Platform.isIOS) {
      print('TTS is only supported on Android and iOS platforms.');
      return;
    }

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  static Future<void> speak(String text, {CoachPersonaId? coachPersona}) async {
    if (!PreferencesService.ttsEnabled) return;

    await initialize();

    // Try premium TTS first if API key is available
    final ttsApiKey = PreferencesService.ttsApiKey;
    if (ttsApiKey != null && ttsApiKey.isNotEmpty) {
      try {
        await _speakWithPremiumTTS(text, ttsApiKey, coachPersona);
        return;
      } catch (e) {
        // Fall back to system TTS if premium fails
        print('Premium TTS failed, falling back to system TTS: $e');
      }
    }

    // Use system TTS as fallback
    await _speakWithSystemTTS(text, coachPersona);
  }

  static Future<void> _speakWithPremiumTTS(
    String text,
    String apiKey,
    CoachPersonaId? coachPersona,
  ) async {
    // This is a placeholder for premium TTS integration
    // You would integrate with services like ElevenLabs, Azure Speech, etc.
    // For now, we'll just use the system TTS
    await _speakWithSystemTTS(text, coachPersona);
  }

  static Future<void> _speakWithSystemTTS(
    String text,
    CoachPersonaId? coachPersona,
  ) async {
    // Configure voice characteristics based on coach persona
    if (coachPersona != null) {
      switch (coachPersona) {
        case CoachPersonaId.sterling:
          await _flutterTts.setPitch(0.8); // Lower pitch for drill sergeant
          await _flutterTts.setSpeechRate(0.6); // Slightly faster
          break;
        case CoachPersonaId.willow:
          await _flutterTts.setPitch(1.2); // Higher pitch for nurturing
          await _flutterTts.setSpeechRate(0.4); // Slower, more gentle
          break;
        case CoachPersonaId.kai:
          await _flutterTts.setPitch(1.0); // Neutral pitch
          await _flutterTts.setSpeechRate(0.5); // Measured pace
          break;
        case CoachPersonaId.sparky:
          await _flutterTts.setPitch(1.3); // Higher pitch for energy
          await _flutterTts.setSpeechRate(0.7); // Faster for enthusiasm
          break;
      }
    }

    await _flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  static Future<void> pause() async {
    await _flutterTts.pause();
  }

  static Future<bool> get isPlaying async {
    final state = await _flutterTts.synthesizeToFile("test", "test.wav");
    return state == 1; // This is a simplified check
  }

  // Voice configuration for different personas
  static Map<CoachPersonaId, Map<String, dynamic>> get voiceConfigs => {
    CoachPersonaId.sterling: {'pitch': 0.8, 'rate': 0.6, 'volume': 1.0},
    CoachPersonaId.willow: {'pitch': 1.2, 'rate': 0.4, 'volume': 0.9},
    CoachPersonaId.kai: {'pitch': 1.0, 'rate': 0.5, 'volume': 0.95},
    CoachPersonaId.sparky: {'pitch': 1.3, 'rate': 0.7, 'volume': 1.0},
  };
}
