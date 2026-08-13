import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'report_service.dart';

/// Builds and downloads a PDF of an [ActivityReport].
///
/// NOTE: only ASCII text is used — the built-in PDF fonts do not support
/// characters like bullets or em-dashes (they render as empty boxes).
class ReportPdfService {
  static const PdfColor _rose = PdfColor.fromInt(0xFFE11D48);
  static const PdfColor _navy = PdfColor.fromInt(0xFF14122B);
  static const PdfColor _teal = PdfColor.fromInt(0xFF26A69A);
  static const PdfColor _amber = PdfColor.fromInt(0xFFFFA726);
  static const PdfColor _indigo = PdfColor.fromInt(0xFF6366F1);

  static Future<void> download(ActivityReport r) async {
    try {
      final doc = await _build(r);
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename:
            'anemia_${r.period}_report_${_d(r.generatedAt)}.pdf',
      );
    } catch (e) {
      debugPrint('[ReportPDF] failed: $e');
      rethrow;
    }
  }

  static String _d(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _dt(DateTime d) =>
      '${_d(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static Future<pw.Document> _build(ActivityReport r) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          // ---------------- Header ----------------
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(18),
            color: _rose,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ANEMIA RISK ASSESSMENT SYSTEM',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1)),
                pw.SizedBox(height: 6),
                pw.Text(r.label.toUpperCase(),
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                    'Period: ${_d(r.startDate)}  to  ${_d(r.endDate)}',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Generated: ${_dt(r.generatedAt)}',
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 18),

          // ---------------- Summary ----------------
          _section('1. SUMMARY'),
          _kvTable([
            ['Total assessments', '${r.totalAssessments}'],
            ['Registered users', '${r.registeredAssessments}'],
            ['Guest (no account)', '${r.guestAssessments}'],
            ['New users registered', '${r.newUsers}'],
            ['Hospital bookings', '${r.totalBookings}'],
            ['Hemoglobin test provided', '${r.hemoglobinProvided}'],
            [
              'Average confidence',
              '${(r.averageConfidence * 100).toStringAsFixed(1)}%'
            ],
          ]),
          pw.SizedBox(height: 16),

          // ---------------- Risk ----------------
          _section('2. RISK LEVEL BREAKDOWN'),
          _barRow('Mild (low risk)', r.mild, r.totalAssessments, _teal),
          _barRow('Moderate', r.moderate, r.totalAssessments, _amber),
          _barRow('Severe (high risk)', r.severe, r.totalAssessments, _rose),
          pw.SizedBox(height: 16),

          // ---------------- Category ----------------
          _section('3. CATEGORY BREAKDOWN'),
          _barRow('Women', r.women, r.totalAssessments, _rose),
          _barRow('Men', r.men, r.totalAssessments, _indigo),
          _barRow('Children', r.children, r.totalAssessments, _teal),
          pw.SizedBox(height: 16),

          // ---------------- Method ----------------
          _section('4. PREDICTION METHOD USED'),
          _barRow('WHO Clinical Thresholds', r.methodWho, r.totalAssessments,
              _indigo),
          _barRow('Machine Learning (XGBoost)', r.methodMl,
              r.totalAssessments, _amber),
          pw.SizedBox(height: 16),

          // ---------------- Trend ----------------
          _section('5. DAILY ACTIVITY'),
          _trendTable(r),
          pw.SizedBox(height: 16),

          // ---------------- Recent assessments ----------------
          if (r.recentAssessments.isNotEmpty) ...[
            _section('6. RECENT ASSESSMENTS'),
            _table(
              ['Date', 'Category', 'Result', 'Confidence', 'Method'],
              r.recentAssessments
                  .map((a) => [
                        _d(a.createdAt),
                        a.category,
                        a.predictionLabel,
                        '${(a.confidence * 100).toStringAsFixed(0)}%',
                        a.method.contains('WHO') ? 'WHO' : 'ML',
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 16),
          ],

          // ---------------- Recent bookings ----------------
          if (r.recentBookings.isNotEmpty) ...[
            _section('7. HOSPITAL BOOKINGS'),
            _table(
              ['Reference', 'Patient', 'Hospital', 'Date', 'Time'],
              r.recentBookings
                  .map((b) => [
                        b.referenceNumber,
                        b.patientName,
                        b.hospitalName,
                        b.appointmentDate,
                        b.appointmentTime,
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 16),
          ],

          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey400),
          pw.Text(
            'This report was generated automatically by the Anemia Risk '
            'Assessment System. Figures cover the period stated above.',
            style:
                const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return doc;
  }

  // ---------------- helpers ----------------

  static pw.Widget _section(String title) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.only(bottom: 4),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _rose, width: 1.5)),
        ),
        child: pw.Text(title,
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: _navy)),
      );

  static pw.Widget _kvTable(List<List<String>> rows) => pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
          1: const pw.FlexColumnWidth(1),
        },
        children: rows
            .map((r) => pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(r[0],
                        style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(r[1],
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
                ]))
            .toList(),
      );

  /// A labelled horizontal bar: name, count, percentage.
  static pw.Widget _barRow(
      String label, int value, int total, PdfColor color) {
    final pct = total == 0 ? 0.0 : value / total;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 150,
              child:
                  pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
          pw.Expanded(
            child: pw.Stack(
              children: [
                pw.Container(height: 12, color: PdfColors.grey200),
                pw.Container(
                  height: 12,
                  width: (pct * 260).clamp(0, 260),
                  color: color,
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$value  (${(pct * 100).toStringAsFixed(1)}%)',
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _trendTable(ActivityReport r) {
    final rows = r.trend.map((t) => [t.shortLabel, '${t.count}']).toList();
    if (rows.isEmpty) {
      return pw.Text('No activity in this period.',
          style: const pw.TextStyle(fontSize: 10));
    }
    // Show as a compact multi-column layout (date : count)
    final cells = rows
        .map((r0) => pw.Container(
              width: 78,
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text('${r0[0]}:  ${r0[1]}',
                  style: const pw.TextStyle(fontSize: 9)),
            ))
        .toList();
    return pw.Wrap(children: cells);
  }

  static pw.Widget _table(List<String> headers, List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: .5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ))
              .toList(),
        ),
        ...rows.map((r) => pw.TableRow(
              children: r
                  .map((c) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(c,
                            style: const pw.TextStyle(fontSize: 9)),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}
