import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:http/http.dart' as http;

/// Centralized auth service that handles all calls to /api/auth/*
class AuthService {
  // Platform-aware base URL
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/auth';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/auth';
    }
    return 'http://localhost:3000/api/auth';
  }

  // In-memory session (for demo / thesis use)
  static String? authToken;
  static Map<String, dynamic>? currentUser;
  static String? lastForgotEmail;

  static const Duration _timeout = Duration(seconds: 15);

  /// POST /api/auth/register
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      debugPrint('[AuthService] POST $url');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      debugPrint('[AuthService] Status: ${response.statusCode}');
      debugPrint('[AuthService] Body:   ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        authToken = data['token'] as String?;
        currentUser = data['user'] as Map<String, dynamic>?;
        return AuthResult.success(data['message'] as String? ?? 'Registered');
      }
      return AuthResult.failure(
          data['message'] as String? ?? 'Registration failed');
    } catch (e) {
      debugPrint('[AuthService] register exception: $e');
      return AuthResult.failure('Connection error: $e');
    }
  }

  /// POST /api/auth/login
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      debugPrint('[AuthService] POST $url');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      debugPrint('[AuthService] Status: ${response.statusCode}');
      debugPrint('[AuthService] Body:   ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        authToken = data['token'] as String?;
        currentUser = data['user'] as Map<String, dynamic>?;
        return AuthResult.success(data['message'] as String? ?? 'Logged in');
      }
      return AuthResult.failure(
          data['message'] as String? ?? 'Invalid credentials');
    } catch (e) {
      debugPrint('[AuthService] login exception: $e');
      return AuthResult.failure('Connection error: $e');
    }
  }

  /// POST /api/auth/forgot-password
  static Future<AuthResult> forgotPassword({required String email}) async {
    try {
      lastForgotEmail = email;
      final url = Uri.parse('$baseUrl/forgot-password');
      debugPrint('[AuthService] POST $url');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      debugPrint('[AuthService] Status: ${response.statusCode}');
      debugPrint('[AuthService] Body:   ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        // Include OTP in message for demo use
        final otp = data['otp'] as String?;
        return AuthResult.success(
          'OTP sent successfully' + (otp != null ? ' (demo OTP: $otp)' : ''),
          extra: {'otp': otp},
        );
      }
      return AuthResult.failure(
          data['message'] as String? ?? 'Failed to send OTP');
    } catch (e) {
      debugPrint('[AuthService] forgotPassword exception: $e');
      return AuthResult.failure('Connection error: $e');
    }
  }

  /// POST /api/auth/verify-otp
  static Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/verify-otp');
      debugPrint('[AuthService] POST $url');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(_timeout);

      debugPrint('[AuthService] Status: ${response.statusCode}');
      debugPrint('[AuthService] Body:   ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResult.success(
          data['message'] as String? ?? 'OTP verified',
          extra: {'resetToken': data['resetToken']},
        );
      }
      return AuthResult.failure(data['message'] as String? ?? 'Invalid OTP');
    } catch (e) {
      debugPrint('[AuthService] verifyOtp exception: $e');
      return AuthResult.failure('Connection error: $e');
    }
  }

  /// POST /api/auth/reset-password
  static Future<AuthResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/reset-password');
      debugPrint('[AuthService] POST $url');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'newPassword': newPassword,
            }),
          )
          .timeout(_timeout);

      debugPrint('[AuthService] Status: ${response.statusCode}');
      debugPrint('[AuthService] Body:   ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResult.success(
            data['message'] as String? ?? 'Password reset');
      }
      return AuthResult.failure(
          data['message'] as String? ?? 'Password reset failed');
    } catch (e) {
      debugPrint('[AuthService] resetPassword exception: $e');
      return AuthResult.failure('Connection error: $e');
    }
  }

  static void logout() {
    authToken = null;
    currentUser = null;
  }
}

/// Simple result wrapper for auth operations
class AuthResult {
  final bool ok;
  final String message;
  final Map<String, dynamic>? extra;

  AuthResult._(this.ok, this.message, [this.extra]);

  factory AuthResult.success(String message, {Map<String, dynamic>? extra}) =>
      AuthResult._(true, message, extra);
  factory AuthResult.failure(String message) => AuthResult._(false, message);
}
