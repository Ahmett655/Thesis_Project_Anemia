import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/admin_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/home_button.dart';
import '../../widgets/theme_toggle_button.dart';
import 'admin_assessments_screen.dart';
import 'admin_user_detail_screen.dart';

/// Admin control panel: system stats with charts + user management.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  AdminStats? _stats;
  List<AdminUser> _users = const [];
  final GlobalKey _usersSectionKey = GlobalKey();

  static const _mildColor = Color(0xFF26A69A);
  static const _moderateColor = Color(0xFFFFA726);
  static const _severeColor = Color(0xFFE53935);
  static const _adminPurple = Color(0xFF6A1B9A);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      AdminService.fetchStats(),
      AdminService.fetchUsers(),
    ]);
    if (!mounted) return;
    setState(() {
      _stats = results[0] as AdminStats?;
      _users = results[1] as List<AdminUser>;
      _loading = false;
    });
  }

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
                      const HomeButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              'System management',
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
                            border:
                                Border.all(color: context.borderSubtle),
                          ),
                          child: Icon(Icons.refresh,
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding:
                                const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            children: [
                              if (_stats != null) ...[
                                _statsGrid(_stats!),
                                const SizedBox(height: 16),
                                _riskPieCard(_stats!),
                                const SizedBox(height: 16),
                                _categoryBarCard(_stats!),
                                const SizedBox(height: 20),
                              ],
                              Text(
                                'Users (${_users.length})',
                                key: _usersSectionKey,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ..._users.map(_userTile),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAssessments(String title, String subtitle,
      {int? risk, bool guestOnly = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAssessmentsScreen(
          title: title,
          subtitle: subtitle,
          risk: risk,
          guestOnly: guestOnly,
        ),
      ),
    );
  }

  void _scrollToUsers() {
    final ctx = _usersSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _statsGrid(AdminStats s) {
    Widget card(IconData icon, String label, String value, Color color,
            VoidCallback onTap) =>
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(height: 6),
                    Text(value,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: color,
                        )),
                    const SizedBox(height: 2),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 9, color: context.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        );

    return Row(
      children: [
        card(Icons.people_outline, 'Users', '${s.totalUsers}',
            const Color(0xFF1565C0), _scrollToUsers),
        const SizedBox(width: 10),
        card(
            Icons.assignment_outlined,
            'Qiimeyno',
            '${s.totalResults}',
            _adminPurple,
            () => _openAssessments(
                'Dhammaan Qiimeynaha', 'All assessments')),
        const SizedBox(width: 10),
        card(
            Icons.person_off_outlined,
            'Guests',
            '${s.guestResults}',
            const Color(0xFF00838F),
            () => _openAssessments(
                'Qiimeynaha Guests-ka', 'Guest assessments',
                guestOnly: true)),
        const SizedBox(width: 10),
        card(
            Icons.priority_high,
            'Severe',
            '${s.severe}',
            _severeColor,
            () => _openAssessments('Khatarta Sare', 'Severe risk cases',
                risk: 2)),
      ],
    );
  }

  Widget _riskPieCard(AdminStats s) {
    final total = (s.mild + s.moderate + s.severe).clamp(1, 1 << 31);
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
          Text('Qaybinta Khatarta',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              )),
          Text('Risk distribution',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.textMuted,
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 28,
                    sections: [
                      PieChartSectionData(
                        value: s.mild.toDouble(),
                        color: _mildColor,
                        title:
                            '${(s.mild / total * 100).toStringAsFixed(0)}%',
                        radius: 40,
                        titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: s.moderate.toDouble(),
                        color: _moderateColor,
                        title:
                            '${(s.moderate / total * 100).toStringAsFixed(0)}%',
                        radius: 40,
                        titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: s.severe.toDouble(),
                        color: _severeColor,
                        title:
                            '${(s.severe / total * 100).toStringAsFixed(0)}%',
                        radius: 40,
                        titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legend(_mildColor, 'Mild / Hooseyso', s.mild),
                    const SizedBox(height: 8),
                    _legend(
                        _moderateColor, 'Moderate / Dhexe', s.moderate),
                    const SizedBox(height: 8),
                    _legend(_severeColor, 'Severe / Sare', s.severe),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label, int count) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 11, color: context.textSecondary)),
          ),
          Text('$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              )),
        ],
      );

  Widget _categoryBarCard(AdminStats s) {
    final maxVal =
        [s.men, s.women, s.children].reduce((a, b) => a > b ? a : b);
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
          Text('Qaybaha la qiimeeyay',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              )),
          Text('Assessments by category',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.textMuted,
              )),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: (maxVal * 1.25).clamp(1, double.infinity).toDouble(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        final label = switch (v.toInt()) {
                          0 => 'Ragga',
                          1 => 'Haweenka',
                          2 => 'Carruurta',
                          _ => '',
                        };
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) =>
                        BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                barGroups: [
                  _barGroup(0, s.men, const Color(0xFF1565C0)),
                  _barGroup(1, s.women, const Color(0xFFAD1457)),
                  _barGroup(2, s.children, const Color(0xFF00838F)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, int value, Color color) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: color,
            width: 34,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );

  Widget _userTile(AdminUser u) {
    final isAdmin = u.role == 'admin';
    final d = u.createdAt.toLocal();
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isAdmin
                ? _adminPurple.withOpacity(0.4)
                : context.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isAdmin
              ? null
              : () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminUserDetailScreen(userId: u.id),
                    ),
                  );
                  if (changed == true) _load();
                },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (isAdmin ? _adminPurple : const Color(0xFF1565C0))
                        .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color:
                            isAdmin ? _adminPurple : const Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              u.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _adminPurple.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: _adminPurple,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${u.email} · $dateStr',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: context.textMuted),
                      ),
                    ],
                  ),
                ),
                if (!isAdmin) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${u.assessmentCount}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      Text('qiimeyn',
                          style: TextStyle(
                              fontSize: 9, color: context.textMuted)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: context.textMuted, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
