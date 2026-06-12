import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/assessment_service.dart';
import '../services/theme_service.dart';
import '../widgets/home_button.dart';
import '../widgets/theme_toggle_button.dart';

/// Dashboard showing past assessments with a risk-trend chart.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  String? _error;
  List<AssessmentRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AssessmentService.fetchHistory();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.ok) {
        // Oldest first so the chart reads left -> right in time.
        _records = result.records.reversed.toList();
      } else {
        _error = result.message;
      }
    });
  }

  Color _riskColor(int p) => switch (p) {
        0 => const Color(0xFF26A69A),
        1 => const Color(0xFFFFA726),
        2 => const Color(0xFFE53935),
        _ => const Color(0xFF9E9E9E),
      };

  String _riskLabel(int p) => switch (p) {
        0 => 'Hooseyso',
        1 => 'Dhexdhexaad',
        2 => 'Sare',
        _ => '—',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const HomeButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Taariikhda Qiimeynta',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              'Assessment History',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: context.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const ThemeToggleButton(),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _load,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderSubtle),
                          ),
                          child: Icon(Icons.refresh,
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(child: _body(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 48, color: context.textMuted),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Isku day mar kale'),
              ),
            ],
          ),
        ),
      );
    }
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: context.textMuted),
            const SizedBox(height: 12),
            Text(
              'Weli qiimeyn lama sameyn.\nNo assessments yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _summaryRow(context),
          const SizedBox(height: 16),
          if (_records.length >= 2) ...[
            _chartCard(context),
            const SizedBox(height: 16),
          ],
          Text(
            'Dhammaan Qiimeynaha (${_records.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Newest first in the list.
          ..._records.reversed.map((r) => _recordTile(context, r)),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context) {
    final latest = _records.last;
    final avgConf = _records.isEmpty
        ? 0.0
        : _records.map((r) => r.confidence).reduce((a, b) => a + b) /
            _records.length;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            icon: Icons.assignment_turned_in_outlined,
            label: 'Tirada',
            value: '${_records.length}',
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            context,
            icon: Icons.speed,
            label: 'Celcelis Kalsooni',
            value: '${avgConf.toStringAsFixed(0)}%',
            color: const Color(0xFF7B1FA2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            context,
            icon: Icons.monitor_heart_outlined,
            label: 'Ugu Dambeysay',
            value: _riskLabel(latest.predictionNumber),
            color: _riskColor(latest.predictionNumber),
          ),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: context.textMuted),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context) {
    // Risk level (0=Mild, 1=Moderate, 2=Severe) over time.
    final spots = <FlSpot>[
      for (var i = 0; i < _records.length; i++)
        FlSpot(i.toDouble(), _records[i].predictionNumber.toDouble()),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Isbeddelka Khatarta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          Text(
            'Risk trend over time',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: context.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: -0.3,
                maxY: 2.3,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: context.borderSubtle,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 70,
                      getTitlesWidget: (v, meta) {
                        final label = switch (v.toInt()) {
                          0 => 'Hooseyso',
                          1 => 'Dhexdhexaad',
                          2 => 'Sare',
                          _ => '',
                        };
                        if (v != v.toInt().toDouble()) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: _riskColor(v.toInt()),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    preventCurveOverShooting: true,
                    barWidth: 3,
                    color: const Color(0xFFE53935),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: _riskColor(spot.y.toInt()),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFE53935).withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordTile(BuildContext context, AssessmentRecord r) {
    final color = _riskColor(r.predictionNumber);
    final d = r.createdAt.toLocal();
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              r.predictionNumber == 2
                  ? Icons.priority_high
                  : r.predictionNumber == 1
                      ? Icons.warning_amber_rounded
                      : Icons.sentiment_satisfied_alt,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khatar ${_riskLabel(r.predictionNumber)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style:
                      TextStyle(fontSize: 11, color: context.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${r.confidence.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              Text(
                'kalsooni',
                style: TextStyle(fontSize: 9, color: context.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
