import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/assessment_service.dart';
import '../services/theme_service.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/top_message_banner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  List<AssessmentRecord> _records = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final result = await AssessmentService.fetchHistory();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.ok) {
        _records = result.records;
        _error = null;
      } else {
        _error = result.message;
        _records = [];
      }
    });
  }

  void _onLogout() {
    AuthService.logout();
    TopMessageBanner.info(context, 'Waad ka baxday akoonkaaga');
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null || AuthService.authToken == null) {
      // Should not normally happen — guard
      return _GuestRedirect(onLogin: () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    final name = (user['name'] as String?) ?? 'User';
    final email = (user['email'] as String?) ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // ============ Gradient header with avatar ============
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withOpacity(0.30),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 26),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppBackButton(
                              onDarkBg: true,
                              onTap: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            const ThemeToggleButton(onDarkBg: true),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ============ Stats row ============
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            icon: Icons.assignment_outlined,
                            label: 'Total',
                            value: '${_records.length}',
                            color: const Color(0xFF1565C0))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.warning_amber_rounded,
                            label: 'Severe',
                            value:
                                '${_records.where((r) => r.predictionNumber == 2).length}',
                            color: const Color(0xFFE53935))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.check_circle_outline,
                            label: 'Mild',
                            value:
                                '${_records.where((r) => r.predictionNumber == 0).length}',
                            color: const Color(0xFF2E7D32))),
                  ],
                ),
              ),

              // ============ Section title ============
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.history,
                        size: 18, color: context.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Taariikhda Baadhitaanada',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _loadHistory,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.refresh,
                            size: 18, color: context.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              // ============ History list ============
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE53935),
                        ),
                      )
                    : _error != null
                        ? _ErrorView(
                            message: _error!,
                            onRetry: _loadHistory,
                          )
                        : _records.isEmpty
                            ? _EmptyView()
                            : RefreshIndicator(
                                color: const Color(0xFFE53935),
                                onRefresh: _loadHistory,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 4, 20, 12),
                                  itemCount: _records.length,
                                  itemBuilder: (context, index) =>
                                      Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: _HistoryCard(
                                        record: _records[index]),
                                  ),
                                ),
                              ),
              ),

              // ============ Logout button ============
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _onLogout,
                      icon: const Icon(Icons.logout,
                          color: Color(0xFFE53935), size: 16),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFE53935), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Helper widgets ============

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AssessmentRecord record;
  const _HistoryCard({required this.record});

  Color _colorForPrediction() {
    switch (record.predictionNumber) {
      case 0:
        return const Color(0xFF1565C0);
      case 1:
        return const Color(0xFFFF8F00);
      case 2:
      default:
        return const Color(0xFFE53935);
    }
  }

  IconData _iconForPrediction() {
    switch (record.predictionNumber) {
      case 0:
        return Icons.sentiment_satisfied_alt;
      case 1:
        return Icons.warning_amber_rounded;
      case 2:
      default:
        return Icons.warning_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final months = const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = months[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m ${dt.day}, ${dt.year}  •  $h:$min';
  }

  String _categoryLabel(String c) {
    switch (c) {
      case 'men':
        return 'Rag (Men)';
      case 'women':
        return 'Dumar (Women)';
      case 'children':
        return 'Ilmo Yar (Children)';
      default:
        return c;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForPrediction();
    final confidencePct = (record.confidence * 100).toStringAsFixed(0);
    return Container(
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconForPrediction(), color: color, size: 26),
            ),
            const SizedBox(width: 12),
            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.predictionLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$confidencePct%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _categoryLabel(record.category),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 12, color: context.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(record.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (record.hemoglobinValue > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bloodtype,
                            size: 12, color: context.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Hb: ${record.hemoglobinValue.toStringAsFixed(1)} g/dL',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.borderSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_toggle_off,
                  size: 38, color: context.textMuted),
            ),
            const SizedBox(height: 10),
            Text(
              'Wali baadhitaan ma sameen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Riix "Bilaaw Qiimeyn" si aad u bilowdo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(
                  context, '/start-assessment'),
              icon: const Icon(Icons.play_arrow,
                  color: Colors.white, size: 16),
              label: const Text(
                'Bilaaw Qiimeyn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: context.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestRedirect extends StatelessWidget {
  final VoidCallback onLogin;
  const _GuestRedirect({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline,
                    size: 60, color: context.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Login si aad u aragto profile-kaaga',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onLogin,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
