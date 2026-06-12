import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Admin-only API calls (/api/admin/*). All require an admin token.
class AdminService {
  static const String _host = '192.168.8.70:3000';
  static String get _base => 'http://$_host/api/admin';
  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.authToken ?? ''}',
      };

  static bool get isAdmin =>
      (AuthService.currentUser?['role'] as String?) == 'admin';

  // ---------- Stats ----------
  static Future<AdminStats?> fetchStats() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/stats'), headers: _headers())
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return AdminStats.fromJson(data['stats'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[Admin] stats error: $e');
    }
    return null;
  }

  // ---------- Users ----------
  static Future<List<AdminUser>> fetchUsers() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/users'), headers: _headers())
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return ((data['users'] as List?) ?? [])
              .cast<Map<String, dynamic>>()
              .map(AdminUser.fromJson)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[Admin] users error: $e');
    }
    return const [];
  }

  static Future<AdminUserDetail?> fetchUserDetail(String id) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/users/$id'), headers: _headers())
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return AdminUserDetail.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('[Admin] user detail error: $e');
    }
    return null;
  }

  // ---------- Assessments ----------
  /// All assessments, optionally filtered by risk level (0/1/2) or
  /// guest-only (no account).
  static Future<List<AdminAssessment>> fetchAssessments(
      {int? risk, bool guestOnly = false}) async {
    try {
      final params = <String, String>{};
      if (risk != null) params['risk'] = '$risk';
      if (guestOnly) params['guest'] = 'true';
      final uri = Uri.http(_host, '/api/admin/assessments', params);
      final res =
          await http.get(uri, headers: _headers()).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return ((data['assessments'] as List?) ?? [])
              .cast<Map<String, dynamic>>()
              .map(AdminAssessment.fromJson)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[Admin] assessments error: $e');
    }
    return const [];
  }

  static Future<bool> deleteUser(String id) async {
    try {
      final res = await http
          .delete(Uri.parse('$_base/users/$id'), headers: _headers())
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[Admin] delete user error: $e');
      return false;
    }
  }

  static Future<bool> deleteAssessment(String id) async {
    try {
      final res = await http
          .delete(Uri.parse('$_base/assessments/$id'), headers: _headers())
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[Admin] delete assessment error: $e');
      return false;
    }
  }

  static Future<bool> resetUserPassword(String id, String newPassword) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/users/$id/reset-password'),
            headers: _headers(),
            body: jsonEncode({'newPassword': newPassword}),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[Admin] reset password error: $e');
      return false;
    }
  }
}

// ---------- Models ----------

class AdminStats {
  final int totalUsers;
  final int totalResults;
  final int guestResults;
  final int mild;
  final int moderate;
  final int severe;
  final int men;
  final int women;
  final int children;

  AdminStats({
    required this.totalUsers,
    required this.totalResults,
    required this.guestResults,
    required this.mild,
    required this.moderate,
    required this.severe,
    required this.men,
    required this.women,
    required this.children,
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) {
    final risk = (j['risk'] ?? {}) as Map<String, dynamic>;
    final cat = (j['category'] ?? {}) as Map<String, dynamic>;
    return AdminStats(
      totalUsers: (j['totalUsers'] as num?)?.toInt() ?? 0,
      totalResults: (j['totalResults'] as num?)?.toInt() ?? 0,
      guestResults: (j['guestResults'] as num?)?.toInt() ?? 0,
      mild: (risk['mild'] as num?)?.toInt() ?? 0,
      moderate: (risk['moderate'] as num?)?.toInt() ?? 0,
      severe: (risk['severe'] as num?)?.toInt() ?? 0,
      men: (cat['men'] as num?)?.toInt() ?? 0,
      women: (cat['women'] as num?)?.toInt() ?? 0,
      children: (cat['children'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final int assessmentCount;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.assessmentCount,
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) => AdminUser(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        role: (j['role'] ?? 'user') as String,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
        assessmentCount: (j['assessmentCount'] as num?)?.toInt() ?? 0,
      );
}

class AdminAssessment {
  final String id;
  final String category;
  final int predictionNumber;
  final String predictionLabel;
  final double confidence;
  final String method;
  final double hemoglobinValue;
  final DateTime createdAt;
  final String? userName; // null = guest
  final String? userEmail;

  AdminAssessment({
    required this.id,
    required this.category,
    required this.predictionNumber,
    required this.predictionLabel,
    required this.confidence,
    required this.method,
    required this.hemoglobinValue,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory AdminAssessment.fromJson(Map<String, dynamic> j) =>
      AdminAssessment(
        id: (j['id'] ?? '').toString(),
        category: (j['category'] ?? '') as String,
        predictionNumber: (j['prediction_number'] as num?)?.toInt() ?? 0,
        predictionLabel: (j['prediction_label'] ?? '') as String,
        confidence: ((j['confidence'] as num?) ?? 0).toDouble(),
        method: (j['method'] ?? '') as String,
        hemoglobinValue:
            ((j['hemoglobin_value'] as num?) ?? 0).toDouble(),
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
        userName: j['userName'] as String?,
        userEmail: j['userEmail'] as String?,
      );
}

class AdminUserDetail {
  final AdminUser user;
  final List<AdminAssessment> assessments;

  AdminUserDetail({required this.user, required this.assessments});

  factory AdminUserDetail.fromJson(Map<String, dynamic> j) {
    final u = (j['user'] ?? {}) as Map<String, dynamic>;
    return AdminUserDetail(
      user: AdminUser.fromJson({...u, 'assessmentCount': 0}),
      assessments: ((j['assessments'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(AdminAssessment.fromJson)
          .toList(),
    );
  }
}
