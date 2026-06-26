import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/// Calls the backend WaafiPay charge endpoint. The merchant credentials
/// live on the server — the app only sends the payer's number + amount.
class PaymentService {
  static String get _url => '${ApiConfig.apiBase}/payment/charge';

  /// Fee shown to the user and charged per assessment.
  static const double feeAmount = 0.1;
  static const String feeCurrency = 'USD';

  static Future<PaymentResult> charge({
    required String accountNo,
    double amount = feeAmount,
  }) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      final token = AuthService.authToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final res = await http
          .post(
            Uri.parse(_url),
            headers: headers,
            body: jsonEncode({
              'accountNo': accountNo,
              'amount': amount,
              'description': 'Anemia assessment result',
            }),
          )
          .timeout(const Duration(seconds: 90));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return PaymentResult.success(
            data['referenceId'] as String? ?? '');
      }
      return PaymentResult.failure(
          data['message'] as String? ?? 'Payment was not approved');
    } catch (e) {
      debugPrint('[Payment] error: $e');
      return PaymentResult.failure(
          'Lambarka lama gaarin ama waqtigii waa dhammaaday. Isku day mar kale.');
    }
  }
}

class PaymentResult {
  final bool ok;
  final String? message;
  final String? referenceId;

  PaymentResult._(this.ok, this.message, this.referenceId);
  factory PaymentResult.success(String ref) =>
      PaymentResult._(true, null, ref);
  factory PaymentResult.failure(String msg) =>
      PaymentResult._(false, msg, null);
}
