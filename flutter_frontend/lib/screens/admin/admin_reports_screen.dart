import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/report_service.dart';
import '../../services/report_pdf_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_design.dart';
import '../../widgets/home_button.dart';

/// Admin activity reports — daily, weekly and monthly summaries of all
/// work done in the system, exportable as PDF.
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  static const List<(String, String, String)> _periods = [
    ('daily', 'Maalinle', 'Daily'),
    ('weekly', 'Toddobaadle', 'Weekly'),
    ('monthly', 'Bille', 'Monthly'),
  ];

  String _period = 'weekly';
  bool _loading = true;
  ActivityReport? _report;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ReportService.fetch(_period);
    if (!mounted) return;
    setState(() {
      _report = r;
      _loading = false;
    });
  }

  Future<void> _exportPdf() async {
    final r = _report;
    if (r == null) return;
    setState(() => _exporting = true);
    try {
      await ReportPdfService.download(r);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF lama sameyn karin.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                _header(context),
                _periodSelector(context),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _report == null
                          ? _errorState(context)
                          : _body(context, _report!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- header ----------------
  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderSubtle),
                ),
                child: Icon(Icons.arrow_back_ios_new,
                    color: context.textPrimary, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            const HomeButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Warbixinada',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary)),
                  Text('Activity Reports',
                      style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: context.textMuted)),
                ],
              ),
            ),
            IconButton(
              onPressed: _loading ? null : _load,
              icon: Icon(Icons.refresh, color: context.textPrimary),
              tooltip: 'Cusboonaysii',
            ),
          ],
        ),
      );

  // ---------------- period selector ----------------
  Widget _periodSelector(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderSubtle),
          ),
          child: Row(
            children: _periods.map((p) {
              final selected = _period == p.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_period == p.$1) return;
                    setState(() => _period = p.$1);
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: selected ? AppDesign.brandGradient : null,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Column(
                      children: [
                        Text(p.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? Colors.white
                                  : context.textPrimary,
                            )),
                        Text(p.$3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: selected
                                  ? Colors.white70
                                  : context.textMuted,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );

  Widget _errorState(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: context.textMuted),
            const SizedBox(height: 12),
            Text('Warbixinta lama soo qaadi karin.',
                style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Isku day mar kale'),
            ),
          ],
        ),
      );

  // ---------------- body ----------------
  Widget _body(BuildContext context, ActivityReport r) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        // date range banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppDesign.brandGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppDesign.glow(AppDesign.rose, opacity: 0.25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.label.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${_d(r.startDate)}  -  ${_d(r.endDate)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // summary cards
        _grid([
          _stat(context, Icons.assignment_outlined, 'Qiimeyno',
              '${r.totalAssessments}', AppDesign.rose),
          _stat(context, Icons.person_add_outlined, 'Users cusub',
              '${r.newUsers}', AppDesign.indigo),
          _stat(context, Icons.event_available_outlined, 'Ballamo',
              '${r.totalBookings}', AppDesign.emerald),
          _stat(context, Icons.bloodtype_outlined, 'Hb la bixiyay',
              '${r.hemoglobinProvided}', AppDesign.amber),
          _stat(context, Icons.person_outline, 'Diiwaangashan',
              '${r.registeredAssessments}', AppDesign.teal),
          _stat(context, Icons.no_accounts_outlined, 'Marti (guest)',
              '${r.guestAssessments}', AppDesign.mist),
        ]),
        const SizedBox(height: 8),
        _card(
          context,
          'Celceliska Kalsoonida',
          'Average confidence',
          child: Row(
            children: [
              Text('${(r.averageConfidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppDesign.indigo)),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: r.averageConfidence.clamp(0, 1),
                    minHeight: 10,
                    backgroundColor: const Color(0xFFEDEFF3),
                    valueColor:
                        const AlwaysStoppedAnimation(AppDesign.indigo),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // risk breakdown
        _card(context, 'Heerarka Khatarta', 'Risk breakdown',
            child: Column(children: [
              _bar(context, 'Mild', r.mild, r.pct(r.mild), AppDesign.emerald),
              _bar(context, 'Moderate', r.moderate, r.pct(r.moderate),
                  AppDesign.amber),
              _bar(context, 'Severe', r.severe, r.pct(r.severe),
                  AppDesign.rose),
            ])),
        const SizedBox(height: 12),

        // category
        _card(context, 'Qaybaha', 'By category',
            child: Column(children: [
              _bar(context, 'Haween', r.women, r.pct(r.women), AppDesign.rose),
              _bar(context, 'Rag', r.men, r.pct(r.men), AppDesign.indigo),
              _bar(context, 'Carruur', r.children, r.pct(r.children),
                  AppDesign.teal),
            ])),
        const SizedBox(height: 12),

        // method
        _card(context, 'Habka Saadaasha', 'Prediction method',
            child: Column(children: [
              _bar(context, 'WHO Clinical', r.methodWho, r.pct(r.methodWho),
                  AppDesign.indigo),
              _bar(context, 'ML (XGBoost)', r.methodMl, r.pct(r.methodMl),
                  AppDesign.amber),
            ])),
        const SizedBox(height: 12),

        // trend chart
        if (r.trend.isNotEmpty)
          _card(context, 'Firfircoonida Maalinlaha', 'Daily activity',
              child: SizedBox(height: 170, child: _trendChart(context, r))),
        const SizedBox(height: 12),

        // recent assessments
        if (r.recentAssessments.isNotEmpty)
          _card(context, 'Qiimeynaha Dhawaan', 'Recent assessments',
              child: Column(
                children: r.recentAssessments
                    .map((a) => _recentRow(context, a))
                    .toList(),
              )),
        if (r.recentAssessments.isNotEmpty) const SizedBox(height: 12),

        // recent bookings
        if (r.recentBookings.isNotEmpty)
          _card(context, 'Ballamaha Hospitalka', 'Hospital bookings',
              child: Column(
                children:
                    r.recentBookings.map((b) => _bookingRow(context, b)).toList(),
              )),
        const SizedBox(height: 18),

        // PDF export
        Pressable(
          onTap: _exporting ? null : _exportPdf,
          child: Opacity(
            opacity: _exporting ? 0.6 : 1,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppDesign.brandGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppDesign.glow(AppDesign.rose, opacity: 0.3),
              ),
              child: Center(
                child: _exporting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf_outlined,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Soo Dejiso PDF',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- pieces ----------------

  Widget _grid(List<Widget> items) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items,
      );

  Widget _stat(BuildContext context, IconData icon, String label,
          String value, Color color) =>
      Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderSubtle),
          boxShadow: AppDesign.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.textMuted)),
                  Text(value,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _card(BuildContext context, String title, String subtitle,
          {required Widget child}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderSubtle),
          boxShadow: AppDesign.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: context.textMuted)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );

  Widget _bar(BuildContext context, String label, int value, double pct,
          Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary)),
                ),
                Text('$value  (${pct.toStringAsFixed(1)}%)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (pct / 100).clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEDEFF3),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _trendChart(BuildContext context, ActivityReport r) {
    final maxY = r.trend.fold<int>(0, (m, t) => t.count > m ? t.count : m);
    // Show at most ~15 labels so the axis stays readable
    final step = (r.trend.length / 7).ceil().clamp(1, 99);
    return BarChart(
      BarChartData(
        maxY: (maxY == 0 ? 1 : maxY).toDouble() * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= r.trend.length) return const SizedBox();
                if (i % step != 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(r.trend[i].shortLabel,
                      style: TextStyle(
                          fontSize: 8, color: context.textMuted)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < r.trend.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: r.trend[i].count.toDouble(),
                color: AppDesign.rose,
                width: r.trend.length > 15 ? 5 : 12,
                borderRadius: BorderRadius.circular(3),
              )
            ]),
        ],
      ),
    );
  }

  Widget _recentRow(BuildContext context, ReportAssessment a) {
    final color = switch (a.predictionLabel) {
      'Mild' => AppDesign.emerald,
      'Moderate' => AppDesign.amber,
      'Severe' => AppDesign.rose,
      _ => AppDesign.mist,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${a.category} - ${a.predictionLabel}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary),
            ),
          ),
          Text('${(a.confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(width: 10),
          Text(_d(a.createdAt),
              style: TextStyle(fontSize: 10, color: context.textMuted)),
        ],
      ),
    );
  }

  Widget _bookingRow(BuildContext context, ReportBooking b) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.event_available_outlined,
                size: 16, color: AppDesign.emerald),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.referenceNumber,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary)),
                  Text('${b.patientName} - ${b.hospitalName}',
                      style: TextStyle(
                          fontSize: 11, color: context.textSecondary)),
                ],
              ),
            ),
            Text('${b.appointmentDate}\n${b.appointmentTime}',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10, color: context.textMuted)),
          ],
        ),
      );
}
