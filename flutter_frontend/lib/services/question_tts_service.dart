import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_tts/flutter_tts.dart';

/// Lightweight shared TTS used to read questions aloud, so users who cannot
/// read can still complete the assessment. Tries Somali first and silently
/// falls back to the device default voice.
class QuestionTtsService {
  QuestionTtsService._();

  static final FlutterTts _tts = FlutterTts();
  static bool _ready = false;

  static Future<void> _init() async {
    if (_ready) return;
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      try {
        await _tts.setLanguage('so-SO');
      } catch (_) {
        // Somali voice not installed — keep the device default.
      }
      _ready = true;
    } catch (e) {
      debugPrint('[QuestionTts] init failed: $e');
    }
  }

  static Future<void> speak(String text) async {
    try {
      await _init();
      await _tts.stop();
      await _tts.speak(text.replaceAll('\n', ' '));
    } catch (e) {
      debugPrint('[QuestionTts] speak failed: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
