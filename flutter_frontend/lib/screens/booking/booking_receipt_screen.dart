import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/booking_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_design.dart';

/// Confirmation receipt shown after a successful booking.
class BookingReceiptScreen extends StatelessWidget {
  final Booking booking;
  const BookingReceiptScreen({super.key, required this.booking});

  String get _bookedAt {
    final d = booking.createdAt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get _shareText =>
      'BALLAN HOSPITAL — RASIID / RECEIPT\n'
      '━━━━━━━━━━━━━━━━━━\n'
      'Reference: ${booking.referenceNumber}\n'
      'Bukaan / Patient: ${booking.patientName}\n'
      '${booking.patientPhone != null && booking.patientPhone!.isNotEmpty ? 'Telefoon: ${booking.patientPhone}\n' : ''}'
      'Hospital: ${booking.hospitalName}\n'
      'Taariikh / Date: ${booking.appointmentDate}\n'
      'Waqti / Time: ${booking.appointmentTime}\n'
      '${booking.riskLabel != null ? 'Natiijada / Result: ${booking.riskLabel}\n' : ''}'
      '${booking.confidence != null ? 'Kalsooni / Confidence: ${booking.confidence!.toStringAsFixed(0)}%\n' : ''}'
      '━━━━━━━━━━━━━━━━━━\n'
      'La sameeyay: $_bookedAt';

  Future<void> _downloadPdf() async {
    try {
      final doc = pw.Document();
      const red = PdfColor.fromInt(0xFFE11D48);
      const navy = PdfColor.fromInt(0xFF14122B);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(18),
                color: red,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ANEMIA RISK ASSESSMENT',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Hospital Appointment Receipt',
                        style: pw.TextStyle(
                            color: PdfColors.white, fontSize: 18)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: red, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(children: [
                  pw.Text('REFERENCE NUMBER',
                      style: pw.TextStyle(color: navy, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text(booking.referenceNumber,
                      style: pw.TextStyle(
                          color: red,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold)),
                ]),
              ),
              pw.SizedBox(height: 20),
              _pdfRow('Patient', booking.patientName),
              if ((booking.patientPhone ?? '').isNotEmpty)
                _pdfRow('Phone', booking.patientPhone!),
              _pdfRow('Hospital', booking.hospitalName),
              if ((booking.hospitalAddress ?? '').isNotEmpty)
                _pdfRow('Details', booking.hospitalAddress!),
              if ((booking.hospitalPhone ?? '').isNotEmpty)
                _pdfRow('Hospital phone', booking.hospitalPhone!),
              _pdfRow('Date', booking.appointmentDate),
              _pdfRow('Time', booking.appointmentTime),
              if (booking.riskLabel != null)
                _pdfRow('Assessment result', booking.riskLabel!),
              if (booking.confidence != null)
                _pdfRow('Confidence', '${booking.confidence!.toStringAsFixed(0)}%'),
              if (booking.hemoglobin != null && booking.hemoglobin! > 0)
                _pdfRow('Hemoglobin',
                    '${booking.hemoglobin!.toStringAsFixed(1)} g/dL'),
              _pdfRow('Booked at', _bookedAt),
              pw.SizedBox(height: 24),
              pw.Text(
                'Note: This is a system-generated referral receipt. Please bring '
                'it with you and consult the hospital staff on arrival.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      );
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'booking_${booking.referenceNumber}.pdf',
      );
    } catch (e) {
      debugPrint('[Receipt] PDF failed: $e');
    }
  }

  static pw.Widget _pdfRow(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
                width: 130,
                child: pw.Text(k,
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(child: pw.Text(v, style: const pw.TextStyle(fontSize: 11))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                // Success check
                FadeSlideIn(
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: AppDesign.emeraldGradient,
                          shape: BoxShape.circle,
                          boxShadow:
                              AppDesign.glow(AppDesign.emerald, opacity: 0.4),
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Ballanka waa la xaqiijiyay!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Appointment confirmed',
                        style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: context.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Reference number highlight
                FadeSlideIn(
                  delayMs: 120,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: AppDesign.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppDesign.glow(AppDesign.rose, opacity: 0.3),
                    ),
                    child: Column(
                      children: [
                        const Text('LAMBARKA RASIIDKA / REFERENCE',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Text(
                          booking.referenceNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Details card
                FadeSlideIn(
                  delayMs: 200,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderSubtle),
                      boxShadow: AppDesign.shadowSm,
                    ),
                    child: Column(
                      children: [
                        _row(context, Icons.local_hospital_outlined,
                            'Hospital', booking.hospitalName),
                        _row(context, Icons.person_outline, 'Bukaan',
                            booking.patientName),
                        if ((booking.patientPhone ?? '').isNotEmpty)
                          _row(context, Icons.phone_outlined, 'Telefoon',
                              booking.patientPhone!),
                        _row(context, Icons.calendar_today_outlined, 'Taariikh',
                            booking.appointmentDate),
                        _row(context, Icons.access_time, 'Waqti',
                            booking.appointmentTime),
                        if (booking.riskLabel != null)
                          _row(context, Icons.assessment_outlined, 'Natiijada',
                              booking.riskLabel!),
                        if (booking.confidence != null)
                          _row(context, Icons.verified_outlined, 'Kalsooni',
                              '${booking.confidence!.toStringAsFixed(0)}%'),
                        _row(context, Icons.schedule, 'La sameeyay', _bookedAt,
                            last: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _downloadPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined,
                            size: 18),
                        label: const Text('PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppDesign.rose,
                          side: const BorderSide(color: AppDesign.rose),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Share.share(_shareText,
                            subject: 'Hospital Booking Receipt'),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('La wadaag'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppDesign.indigo,
                          side: const BorderSide(color: AppDesign.indigo),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Pressable(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (r) => false),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppDesign.brandGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Guriga ku laabo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFFFD54F).withOpacity(0.5)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: Color(0xFFFF8F00)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kala tag rasiidkan markaad hospitalka tagto. Kala '
                          'xaajood shaqaalaha caafimaadka markaad gaadho.',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF7C5800), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String k, String v,
      {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: context.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppDesign.rose),
          const SizedBox(width: 12),
          SizedBox(
            width: 78,
            child: Text(k,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.textMuted)),
          ),
          Expanded(
            child: Text(v,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary)),
          ),
        ],
      ),
    );
  }
}
