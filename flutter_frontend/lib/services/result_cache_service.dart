import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assessment_data.dart';

/// Caches the last assessment result locally so it survives app restarts
/// and is viewable without internet (offline mode).
class ResultCacheService {
  static const String _key = 'last_assessment_result';

  /// Save the current AssessmentData result.
  static Future<void> saveCurrentResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'category': AssessmentData.category,
          'prediction_number': AssessmentData.predictionNumber,
          'prediction_label': AssessmentData.predictionLabel,
          'confidence': AssessmentData.confidence,
          'method': AssessmentData.method,
          'hemoglobin_value': AssessmentData.hemoglobinValue,
          'saved_at': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      debugPrint('[ResultCache] save failed: $e');
    }
  }

  /// Load the last cached result, or null if none.
  static Future<CachedResult?> loadLastResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return CachedResult(
        category: (j['category'] ?? '') as String,
        predictionNumber: (j['prediction_number'] as num?)?.toInt() ?? 0,
        predictionLabel: (j['prediction_label'] ?? '') as String,
        confidence: ((j['confidence'] as num?) ?? 0).toDouble(),
        method: (j['method'] ?? '') as String,
        hemoglobinValue:
            ((j['hemoglobin_value'] as num?) ?? 0).toDouble(),
        savedAt: DateTime.tryParse(j['saved_at'] as String? ?? '') ??
            DateTime.now(),
      );
    } catch (e) {
      debugPrint('[ResultCache] load failed: $e');
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class CachedResult {
  final String category;
  final int predictionNumber;
  final String predictionLabel;
  final double confidence;
  final String method;
  final double hemoglobinValue;
  final DateTime savedAt;

  CachedResult({
    required this.category,
    required this.predictionNumber,
    required this.predictionLabel,
    required this.confidence,
    required this.method,
    required this.hemoglobinValue,
    required this.savedAt,
  });

  /// Restore this cached result back into AssessmentData (e.g. to re-open
  /// the result screen offline).
  void restore() {
    AssessmentData.category = category;
    AssessmentData.predictionNumber = predictionNumber;
    AssessmentData.predictionLabel = predictionLabel;
    AssessmentData.confidence = confidence;
    AssessmentData.method = method;
    AssessmentData.hemoglobinValue = hemoglobinValue;
  }
}
