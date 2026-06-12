import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/assessment_data.dart';
import 'auth_service.dart';

/// Generates and shares/downloads a styled PDF report of the latest
/// assessment, including visual charts (confidence gauge + risk scale).
///
/// NOTE: only ASCII text + drawn shapes are used — the built-in PDF fonts
/// do not support characters like bullets or em-dashes (they render as
/// empty boxes).
class PdfReportService {
  static const PdfColor _red = PdfColor.fromInt(0xFFE53935);
  static const PdfColor _teal = PdfColor.fromInt(0xFF26A69A);
  static const PdfColor _orange = PdfColor.fromInt(0xFFFFA726);
  static const PdfColor _navy = PdfColor.fromInt(0xFF1A1A2E);

  static Future<void> downloadReport() async {
    try {
      final doc = await _buildDocument();
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename:
            'anemia_report_${DateTime.now().toIso8601String().split('T').first}.pdf',
      );
    } catch (e) {
      debugPrint('[PDF] failed: $e');
      rethrow;
    }
  }

  static Future<pw.Document> _buildDocument() async {
    final int prediction = AssessmentData.predictionNumber;
    final double confidence = AssessmentData.confidence;
    final String method = AssessmentData.method;
    final double hb = AssessmentData.hemoglobinValue;
    final String category = AssessmentData.category;
    final String userName =
        (AuthService.currentUser?['name'] as String?) ?? 'Guest User';
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final (PdfColor riskColor, String riskEn, String riskSo) =
        switch (prediction) {
      0 => (_teal, 'MILD (Low Risk)', 'Khatar Hooseyso'),
      1 => (_orange, 'MODERATE RISK', 'Khatar Dhex Dhexaad'),
      2 => (_red, 'SEVERE (High Risk)', 'Khatar Sare'),
      _ => (PdfColors.grey, 'UNKNOWN', 'Lama Yaqaan'),
    };

    final recommendations = _recommendationsFor(prediction);

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header(dateStr),
            pw.SizedBox(height: 16),

            // Patient info card
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      child:
                          _infoCol('Name / Magaca', userName)),
                  pw.Expanded(
                      child: _infoCol('Date / Taariikhda', dateStr)),
                  pw.Expanded(
                      child: _infoCol(
                          'Category / Qaybta', _categoryLabel(category))),
                  pw.Expanded(
                      child: _infoCol('Method / Habka',
                          method.contains('WHO') ? 'WHO Clinical' : 'ML Model')),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Result hero box
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                  colors: [riskColor, riskColor.shade(0.25)],
                ),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                children: [
                  // Big result circle
                  pw.Container(
                    width: 64,
                    height: 64,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${confidence.toStringAsFixed(0)}%',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        riskEn,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        riskSo,
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.white),
                      ),
                      if (hb > 0) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Hemoglobin: ${hb.toStringAsFixed(1)} g/dL',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.white),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),

            // ===== CHART 1: Risk scale gauge =====
            pw.Text('Risk Scale / Heerka Khatarta',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _riskScaleChart(prediction),
            pw.SizedBox(height: 18),

            // ===== CHART 2: Confidence bar =====
            pw.Text('Confidence / Kalsoonida',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _confidenceChart(confidence, riskColor),
            pw.SizedBox(height: 18),

            // Recommendations
            pw.Text('Recommendations / Talooyinka',
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...recommendations.map((r) => _bulletRow(r, riskColor)),

            pw.Spacer(),

            // Disclaimer footer
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber50,
                border: pw.Border.all(color: PdfColors.amber200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'DISCLAIMER: This is a screening assessment and does not replace a clinical '
                'diagnosis. Please consult a healthcare professional. / Tani waa qiimeyn '
                'kaaliso ah oo aan beddeli karin baadhitaan dhakhtar. Fadlan la tasho '
                'xirfadle caafimaad.',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.brown800),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'Generated by Anemia Risk Assessment System - $dateStr',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );
    return doc;
  }

  // ---------- building blocks ----------

  static pw.Widget _header(String dateStr) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(18),
        decoration: pw.BoxDecoration(
          gradient: const pw.LinearGradient(
            begin: pw.Alignment.topLeft,
            end: pw.Alignment.bottomRight,
            colors: [_red, PdfColor.fromInt(0xFFB71C1C)],
          ),
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Row(
          children: [
            // Drawn "blood drop" circle logo
            pw.Container(
              width: 42,
              height: 42,
              decoration: const pw.BoxDecoration(
                color: PdfColors.white,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Container(
                  width: 16,
                  height: 16,
                  decoration: const pw.BoxDecoration(
                    color: _red,
                    shape: pw.BoxShape.circle,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 14),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ANEMIA RISK ASSESSMENT REPORT',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Warbixinta Qiimeynta Khatarta Yaraanta Dhiigga',
                  style: const pw.TextStyle(
                      color: PdfColor.fromInt(0xFFFFCDD2), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      );

  static pw.Widget _infoCol(String label, String value) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600)),
          pw.SizedBox(height: 3),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _navy)),
        ],
      );

  /// 3-segment colored risk scale with a triangle marker on current level.
  static pw.Widget _riskScaleChart(int prediction) {
    pw.Widget segment(PdfColor color, String en, String so, bool active) =>
        pw.Expanded(
          child: pw.Column(
            children: [
              pw.Container(
                height: active ? 22 : 14,
                margin: const pw.EdgeInsets.symmetric(horizontal: 2),
                decoration: pw.BoxDecoration(
                  color: active ? color : color.shade(-0.35),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: active
                      ? pw.Border.all(color: _navy, width: 1.2)
                      : null,
                ),
                child: active
                    ? pw.Center(
                        child: pw.Text('YOU ARE HERE',
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            )))
                    : null,
              ),
              pw.SizedBox(height: 4),
              pw.Text(en,
                  style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: active
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                      color: active ? color : PdfColors.grey600)),
              pw.Text(so,
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: active ? color : PdfColors.grey500)),
            ],
          ),
        );

    return pw.Row(
      children: [
        segment(_teal, 'MILD', 'Hooseyso', prediction == 0),
        segment(_orange, 'MODERATE', 'Dhexdhexaad', prediction == 1),
        segment(_red, 'SEVERE', 'Sare', prediction == 2),
      ],
    );
  }

  /// Horizontal confidence bar with percentage ticks.
  static pw.Widget _confidenceChart(double confidence, PdfColor color) {
    final pct = (confidence / 100).clamp(0.0, 1.0);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Stack(
          children: [
            pw.Container(
              height: 16,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
            ),
            pw.Container(
              height: 16,
              width: 530 * pct,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [color.shade(-0.15), color],
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  '${confidence.toStringAsFixed(1)}%',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            for (final t in ['0%', '25%', '50%', '75%', '100%'])
              pw.Text(t,
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }

  /// Bullet drawn as a colored circle (no glyph issues).
  static pw.Widget _bulletRow(String text, PdfColor color) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              margin: const pw.EdgeInsets.only(top: 3, right: 8),
              decoration: pw.BoxDecoration(
                color: color,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(text,
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 2)),
            ),
          ],
        ),
      );

  static String _categoryLabel(String c) {
    if (c == 'women') return 'Women / Haweenka';
    if (c == 'men') return 'Men / Ragga';
    if (c == 'children') return 'Children / Carruurta';
    return c.isEmpty ? '-' : c;
  }

  static List<String> _recommendationsFor(int prediction) {
    switch (prediction) {
      case 0:
        return [
          'Maintain a balanced diet rich in iron (meat, liver, beans, leafy greens). / Sii wad cunto birta leh.',
          'Drink vitamin C rich juices to improve iron absorption. / Cab casiir leh Vitamin C.',
          'Repeat the assessment periodically to monitor your status. / Dib u qiimee si joogto ah.',
        ];
      case 1:
        return [
          'Consult a doctor or health center for a blood test. / La tasho dhakhtar si dhiiga laguu baadho.',
          'Increase iron-rich foods: liver, red meat, beans, spinach. / Kordhi cuntada birta leh.',
          'Consider iron supplements if advised by a clinician. / Isticmaal kaniiniga birta haddii dhakhtar kugu taliyo.',
          'Avoid drinking tea with meals, it blocks iron absorption. / Ha cabbin shaah cuntada lala qaato.',
        ];
      case 2:
        return [
          'Seek medical care URGENTLY, visit the nearest health facility. / Si DEGDEG ah u aad xarunta caafimaadka.',
          'A blood transfusion or supervised treatment may be required. / Waxaa laga yaabaa in dhiig-gelin loo baahdo.',
          'Do not delay, severe anemia can be life-threatening. / Ha dib u dhigin, khatartu waa sare.',
        ];
      default:
        return [
          'Result unavailable. Please retake the assessment. / Natiijo lama helin, dib u qiimee.',
        ];
    }
  }
}
