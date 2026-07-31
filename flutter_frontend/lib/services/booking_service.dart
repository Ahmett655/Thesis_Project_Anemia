import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/// Creates hospital appointment bookings via the Node backend (/api/booking).
/// The booking is a prototype/simulated referral — it is stored so the patient
/// receives a reference number and a receipt.
class BookingService {
  static String get _url => '${ApiConfig.apiBase}/booking';

  static Future<BookingResult> create({
    required String patientName,
    String? patientPhone,
    required String hospitalName,
    String? hospitalAddress,
    String? hospitalPhone,
    double? hospitalLat,
    double? hospitalLon,
    required String appointmentDate,
    required String appointmentTime,
    String? category,
    String? riskLabel,
    int? riskNumber,
    double? confidence,
    double? hemoglobin,
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
              'patientName': patientName,
              'patientPhone': patientPhone,
              'hospitalName': hospitalName,
              'hospitalAddress': hospitalAddress,
              'hospitalPhone': hospitalPhone,
              'hospitalLat': hospitalLat,
              'hospitalLon': hospitalLon,
              'appointmentDate': appointmentDate,
              'appointmentTime': appointmentTime,
              'category': category,
              'riskLabel': riskLabel,
              'riskNumber': riskNumber,
              'confidence': confidence,
              'hemoglobin': hemoglobin,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          data['success'] == true) {
        return BookingResult.success(
            Booking.fromJson(data['booking'] as Map<String, dynamic>));
      }
      return BookingResult.failure(
          data['message'] as String? ?? 'Booking-ku ma guulaysan.');
    } catch (e) {
      debugPrint('[Booking] error: $e');
      return BookingResult.failure(
          'Lama gaarin server-ka. Hubi internetka oo isku day mar kale.');
    }
  }
}

class Booking {
  final String referenceNumber;
  final String patientName;
  final String? patientPhone;
  final String hospitalName;
  final String? hospitalAddress;
  final String? hospitalPhone;
  final String appointmentDate;
  final String appointmentTime;
  final String? riskLabel;
  final double? confidence;
  final double? hemoglobin;
  final DateTime createdAt;

  Booking({
    required this.referenceNumber,
    required this.patientName,
    this.patientPhone,
    required this.hospitalName,
    this.hospitalAddress,
    this.hospitalPhone,
    required this.appointmentDate,
    required this.appointmentTime,
    this.riskLabel,
    this.confidence,
    this.hemoglobin,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        referenceNumber: (j['referenceNumber'] ?? '') as String,
        patientName: (j['patientName'] ?? '') as String,
        patientPhone: j['patientPhone'] as String?,
        hospitalName: (j['hospitalName'] ?? '') as String,
        hospitalAddress: j['hospitalAddress'] as String?,
        hospitalPhone: j['hospitalPhone'] as String?,
        appointmentDate: (j['appointmentDate'] ?? '') as String,
        appointmentTime: (j['appointmentTime'] ?? '') as String,
        riskLabel: j['riskLabel'] as String?,
        confidence: (j['confidence'] as num?)?.toDouble(),
        hemoglobin: (j['hemoglobin'] as num?)?.toDouble(),
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class BookingResult {
  final bool ok;
  final String? message;
  final Booking? booking;
  BookingResult._(this.ok, this.message, this.booking);
  factory BookingResult.success(Booking b) => BookingResult._(true, null, b);
  factory BookingResult.failure(String m) => BookingResult._(false, m, null);
}
