import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/// Admin activity reports (/api/reports) — daily, weekly and monthly
/// summaries of everything that happened in the system.
class ReportService {
  static String get _base => '${ApiConfig.apiBase}/reports';

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.authToken ?? ''}',
      };

  /// [period] must be 'daily', 'weekly' or 'monthly'.
  static Future<ActivityReport?> fetch(String period) async {
    try {
      final res = await http
          .get(Uri.parse('$_base?period=$period'), headers: _headers())
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return ActivityReport.fromJson(
              data['report'] as Map<String, dynamic>);
        }
      }
      debugPrint('[Report] status ${res.statusCode}');
    } catch (e) {
      debugPrint('[Report] error: $e');
    }
    return null;
  }
}

class ActivityReport {
  final String period;
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;

  final int totalAssessments;
  final int guestAssessments;
  final int registeredAssessments;
  final int newUsers;
  final int totalBookings;
  final int hemoglobinProvided;
  final double averageConfidence;

  final int mild, moderate, severe;
  final int men, women, children;
  final int methodWho, methodMl;

  final List<TrendPoint> trend;
  final List<ReportAssessment> recentAssessments;
  final List<ReportBooking> recentBookings;

  ActivityReport({
    required this.period,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.totalAssessments,
    required this.guestAssessments,
    required this.registeredAssessments,
    required this.newUsers,
    required this.totalBookings,
    required this.hemoglobinProvided,
    required this.averageConfidence,
    required this.mild,
    required this.moderate,
    required this.severe,
    required this.men,
    required this.women,
    required this.children,
    required this.methodWho,
    required this.methodMl,
    required this.trend,
    required this.recentAssessments,
    required this.recentBookings,
  });

  factory ActivityReport.fromJson(Map<String, dynamic> j) {
    final s = (j['summary'] ?? {}) as Map<String, dynamic>;
    final r = (j['risk'] ?? {}) as Map<String, dynamic>;
    final c = (j['category'] ?? {}) as Map<String, dynamic>;
    final m = (j['method'] ?? {}) as Map<String, dynamic>;
    int i(dynamic v) => (v as num?)?.toInt() ?? 0;

    return ActivityReport(
      period: (j['period'] ?? '') as String,
      label: (j['label'] ?? 'Report') as String,
      startDate: DateTime.tryParse(j['startDate'] as String? ?? '') ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(j['endDate'] as String? ?? '') ?? DateTime.now(),
      generatedAt: DateTime.tryParse(j['generatedAt'] as String? ?? '') ??
          DateTime.now(),
      totalAssessments: i(s['totalAssessments']),
      guestAssessments: i(s['guestAssessments']),
      registeredAssessments: i(s['registeredAssessments']),
      newUsers: i(s['newUsers']),
      totalBookings: i(s['totalBookings']),
      hemoglobinProvided: i(s['hemoglobinProvided']),
      averageConfidence: ((s['averageConfidence'] as num?) ?? 0).toDouble(),
      mild: i(r['mild']),
      moderate: i(r['moderate']),
      severe: i(r['severe']),
      men: i(c['men']),
      women: i(c['women']),
      children: i(c['children']),
      methodWho: i(m['who']),
      methodMl: i(m['ml']),
      trend: ((j['trend'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(TrendPoint.fromJson)
          .toList(),
      recentAssessments: ((j['recentAssessments'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(ReportAssessment.fromJson)
          .toList(),
      recentBookings: ((j['recentBookings'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(ReportBooking.fromJson)
          .toList(),
    );
  }

  /// Percentage of [value] out of all assessments (0 when empty).
  double pct(int value) =>
      totalAssessments == 0 ? 0 : (value / totalAssessments) * 100;
}

class TrendPoint {
  final String date; // YYYY-MM-DD
  final int count;
  TrendPoint(this.date, this.count);

  factory TrendPoint.fromJson(Map<String, dynamic> j) =>
      TrendPoint((j['date'] ?? '') as String, (j['count'] as num?)?.toInt() ?? 0);

  /// Short label for chart axes, e.g. "08-13".
  String get shortLabel => date.length >= 10 ? date.substring(5) : date;
}

class ReportAssessment {
  final String category;
  final String predictionLabel;
  final double confidence;
  final String method;
  final DateTime createdAt;

  ReportAssessment({
    required this.category,
    required this.predictionLabel,
    required this.confidence,
    required this.method,
    required this.createdAt,
  });

  factory ReportAssessment.fromJson(Map<String, dynamic> j) =>
      ReportAssessment(
        category: (j['category'] ?? '') as String,
        predictionLabel: (j['prediction_label'] ?? '') as String,
        confidence: ((j['confidence'] as num?) ?? 0).toDouble(),
        method: (j['method'] ?? '') as String,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class ReportBooking {
  final String referenceNumber;
  final String patientName;
  final String hospitalName;
  final String appointmentDate;
  final String appointmentTime;
  final String? riskLabel;

  ReportBooking({
    required this.referenceNumber,
    required this.patientName,
    required this.hospitalName,
    required this.appointmentDate,
    required this.appointmentTime,
    this.riskLabel,
  });

  factory ReportBooking.fromJson(Map<String, dynamic> j) => ReportBooking(
        referenceNumber: (j['referenceNumber'] ?? '') as String,
        patientName: (j['patientName'] ?? '') as String,
        hospitalName: (j['hospitalName'] ?? '') as String,
        appointmentDate: (j['appointmentDate'] ?? '') as String,
        appointmentTime: (j['appointmentTime'] ?? '') as String,
        riskLabel: j['riskLabel'] as String?,
      );
}
