import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_config.dart';

/// Service for prediction + history API calls.
class AssessmentService {
  // Platform-aware base URL (web -> localhost, phone -> LAN IP).
  // Change the IP in api_config.dart if needed.
  static String get baseUrl => '${ApiConfig.apiBase}/predict';

  static Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = AuthService.authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET /api/predict/history (requires auth)
  static Future<HistoryResult> fetchHistory() async {
    if (AuthService.authToken == null || AuthService.authToken!.isEmpty) {
      return HistoryResult.failure('Not logged in');
    }
    try {
      final url = Uri.parse('$baseUrl/history');
      debugPrint('[AssessmentService] GET $url');
      final response = await http
          .get(url, headers: _headers())
          .timeout(const Duration(seconds: 15));

      debugPrint('[AssessmentService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final list =
              (data['assessments'] as List?)?.cast<Map<String, dynamic>>() ??
                  [];
          return HistoryResult.success(
            list.map(AssessmentRecord.fromJson).toList(),
          );
        }
        return HistoryResult.failure(
            data['message'] as String? ?? 'Failed to fetch history');
      } else if (response.statusCode == 401) {
        return HistoryResult.failure('Session expired. Please login again.');
      }
      return HistoryResult.failure(
          'Server error (${response.statusCode})');
    } catch (e) {
      debugPrint('[AssessmentService] exception: $e');
      return HistoryResult.failure('Connection error: $e');
    }
  }

  static Map<String, String> get headersForPredict => _headers();
}

class AssessmentRecord {
  final String id;
  final String category;
  final int predictionNumber;
  final String predictionLabel;
  final double confidence;
  final String method;
  final double hemoglobinValue;
  final DateTime createdAt;

  AssessmentRecord({
    required this.id,
    required this.category,
    required this.predictionNumber,
    required this.predictionLabel,
    required this.confidence,
    required this.method,
    required this.hemoglobinValue,
    required this.createdAt,
  });

  factory AssessmentRecord.fromJson(Map<String, dynamic> j) =>
      AssessmentRecord(
        id: (j['id'] ?? '').toString(),
        category: (j['category'] ?? '') as String,
        predictionNumber:
            (j['prediction_number'] as num?)?.toInt() ?? 0,
        predictionLabel:
            (j['prediction_label'] ?? '') as String,
        confidence: ((j['confidence'] as num?) ?? 0).toDouble(),
        method: (j['method'] ?? '') as String,
        hemoglobinValue:
            ((j['hemoglobin_value'] as num?) ?? 0).toDouble(),
        createdAt:
            DateTime.tryParse(j['createdAt'] as String? ?? '') ??
                DateTime.now(),
      );
}

class HistoryResult {
  final bool ok;
  final String? message;
  final List<AssessmentRecord> records;

  HistoryResult._(this.ok, this.message, this.records);

  factory HistoryResult.success(List<AssessmentRecord> records) =>
      HistoryResult._(true, null, records);
  factory HistoryResult.failure(String message) =>
      HistoryResult._(false, message, const []);
}
