import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/result_cache_service.dart';
import '../services/reminder_service.dart';
import '../theme/app_design.dart';
import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _float =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        AuthService.authToken != null && AuthService.authToken!.isNotEmpty;
    final isAdmin = (AuthService.currentUser?['role'] as String?) == 'admin';

    return Scaffold(
      backgroundColor: context.bgPage,
      floatingActionButton: FadeSlideIn(
        delayMs: 700,
        child: Pressable(
          onTap: () => Navigator.pushNamed(context, '/chat'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppDesign.indigoGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppDesign.glow(AppDesign.indigo, opacity: 0.4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Caawiye AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _hero(context, isLoggedIn),
                const SizedBox(height: 22),

                FadeSlideIn(delayMs: 150, child: _describeCard(context)),
                const SizedBox(height: 18),
                FadeSlideIn(delayMs: 250, child: _featureChips()),
                const SizedBox(height: 24),

                // Primary CTA
                FadeSlideIn(
                  delayMs: 350,
                  child: _GradientButton(
                    onTap: () =>
                        Navigator.pushNamed(context, '/start-assessment'),
                    gradient: AppDesign.brandGradient,
                    glow: AppDesign.rose,
                    icon: Icons.play_circle_fill_rounded,
                    title: 'Bilaaw Qiimeyn',
                    subtitle: 'Start Assessment',
                  ),
                ),
                const SizedBox(height: 12),

                // Nearby facilities
                FadeSlideIn(
                  delayMs: 430,
                  child: _outlineAction(
                    context,
                    icon: Icons.location_on_outlined,
                    label: 'Xarumaha Caafimaad ee u dhow',
                    color: AppDesign.teal,
                    onTap: () =>
                        Navigator.pushNamed(context, '/health-facilities'),
                  ),
                ),
                const SizedBox(height: 14),

                if (!isLoggedIn)
                  FadeSlideIn(delayMs: 500, child: _authRow(context)),
                if (isLoggedIn)
                  FadeSlideIn(delayMs: 500, child: _loggedInRow(context)),

                if (isLoggedIn && isAdmin)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    child: FadeSlideIn(
                      delayMs: 560,
                      child: _GradientButton(
                        onTap: () => Navigator.pushNamed(context, '/admin'),
                        gradient: const LinearGradient(colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFF6D28D9)
                        ]),
                        glow: const Color(0xFF7C3AED),
                        icon: Icons.admin_panel_settings_rounded,
                        title: 'Admin Panel',
                        subtitle: 'System management',
                        compact: true,
                      ),
                    ),
                  ),

                const _ReminderCard(),
                const _LastResultCard(),
                const SizedBox(height: 14),

                if (!isLoggedIn)
                  FadeSlideIn(
                    delayMs: 600,
                    child: TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/start-assessment'),
                      icon: const Icon(Icons.bolt_rounded,
                          size: 16, color: AppDesign.teal),
                      label: const Text(
                        'Sii wad si marti ah (Continue as guest)',
                        style: TextStyle(
                          color: AppDesign.teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                FadeSlideIn(delayMs: 650, child: _disclaimer()),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HERO ----------------
  Widget _hero(BuildContext context, bool isLoggedIn) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppDesign.brandGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(44),
              bottomRight: Radius.circular(44),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 44),
              child: Column(
                children: [
                  Row(
                    children: [
                      _glassPill(),
                      const Spacer(),
                      if (isLoggedIn) ...[
                        _ProfileIconButton(
                            onTap: () =>
                                Navigator.pushNamed(context, '/profile')),
                        const SizedBox(width: 10),
                      ],
                      const ThemeToggleButton(onDarkBg: true),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Floating glass logo with glow ring
                  AnimatedBuilder(
                    animation: _float,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, math.sin(_float.value * math.pi) * -8),
                      child: child,
                    ),
                    child: _heroLogo(),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Anemia Risk',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: 0.3,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [Color(0xFFFFE4E6), Colors.white],
                    ).createShader(r),
                    child: const Text(
                      'Assessment',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Qiimeynta Khatarta Yaraanta Dhiigga',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: Colors.white),
          SizedBox(width: 6),
          Text('ML-POWERED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              )),
        ],
      ),
    );
  }

  Widget _heroLogo() {
    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (r) => AppDesign.brandGradient.createShader(r),
            child: const Icon(Icons.bloodtype, size: 54, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ---------------- CARDS / SECTIONS ----------------
  Widget _describeCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderSubtle),
          boxShadow: AppDesign.shadowSm,
        ),
        child: Column(
          children: [
            Text(
              'Nidaamkan wuxuu ka caawiyaa dadka inay si fudud oo degdeg ah u qiimeeyaan khatarta yaraanta dhiigga',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Assess your anemia risk easily and quickly',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: const [
          Expanded(
              child: _FeatureChip(
                  icon: Icons.bolt_rounded,
                  label: 'Fast',
                  somali: 'Degdeg',
                  color: AppDesign.amber)),
          SizedBox(width: 10),
          Expanded(
              child: _FeatureChip(
                  icon: Icons.lock_rounded,
                  label: 'Private',
                  somali: 'Qarsoodi',
                  color: AppDesign.teal)),
          SizedBox(width: 10),
          Expanded(
              child: _FeatureChip(
                  icon: Icons.psychology_rounded,
                  label: 'AI-Powered',
                  somali: 'ML',
                  color: AppDesign.indigo)),
        ],
      ),
    );
  }

  Widget _outlineAction(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.35), width: 1.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _authRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _softButton(context,
                icon: Icons.person_add_alt_1_rounded,
                label: 'Register',
                onTap: () => Navigator.pushNamed(context, '/register')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Pressable(
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppDesign.ink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loggedInRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _softButton(context,
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => Navigator.pushNamed(context, '/profile')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Pressable(
              onTap: () => Navigator.pushNamed(context, '/history'),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppDesign.indigo.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppDesign.indigo.withOpacity(0.4), width: 1.2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights_rounded,
                        color: AppDesign.indigo, size: 18),
                    SizedBox(width: 8),
                    Text('Dashboard',
                        style: TextStyle(
                            color: AppDesign.indigo,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderSubtle, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: context.textPrimary, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _disclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppDesign.amber.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppDesign.amber.withOpacity(0.3)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_outlined, size: 17, color: Color(0xFFB45309)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tani waa qiimeyn awoodda u leh kaaliso oo aanan beddeli karin daryeel dhakhtarka.',
                style: TextStyle(
                    fontSize: 11, color: Color(0xFF92600A), height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable gradient CTA with glow + press feedback.
class _GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final Gradient gradient;
  final Color glow;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  const _GradientButton({
    required this.onTap,
    required this.gradient,
    required this.glow,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 24),
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: compact ? 54 : 60,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppDesign.glow(glow, opacity: 0.38),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows when the next anemia re-assessment is due (set after each result).
class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: ReminderService.daysUntilNext(),
      builder: (context, snap) {
        final days = snap.data;
        if (days == null) return const SizedBox.shrink();
        final overdue = days <= 0;
        final color = overdue ? AppDesign.rose : AppDesign.emerald;
        final label = overdue
            ? 'Waqtigii dib-u-qiimeynta wuu gaaray!'
            : 'Dib-u-qiimeyn: $days maalmood ka dib';
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: FadeSlideIn(
            delayMs: 540,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                        overdue
                            ? Icons.notifications_active_rounded
                            : Icons.event_available_rounded,
                        color: color,
                        size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: color)),
                        const SizedBox(height: 2),
                        Text('Reminder to re-check your anemia risk',
                            style: TextStyle(
                                fontSize: 11, color: context.textMuted)),
                      ],
                    ),
                  ),
                  if (overdue)
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/start-assessment'),
                      child: const Text('Qiimee',
                          style: TextStyle(
                              color: AppDesign.rose,
                              fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows the last assessment result cached on this device (works offline).
class _LastResultCard extends StatelessWidget {
  const _LastResultCard();

  Color _riskColor(int p) => switch (p) {
        0 => AppDesign.emerald,
        1 => AppDesign.amber,
        2 => AppDesign.rose,
        _ => AppDesign.mist,
      };

  String _riskLabel(int p) => switch (p) {
        0 => 'Khatar Hooseyso',
        1 => 'Khatar Dhexdhexaad',
        2 => 'Khatar Sare',
        _ => '—',
      };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CachedResult?>(
      future: ResultCacheService.loadLastResult(),
      builder: (context, snap) {
        final r = snap.data;
        if (r == null) return const SizedBox.shrink();
        final color = _riskColor(r.predictionNumber);
        final d = r.savedAt.toLocal();
        final dateStr =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: FadeSlideIn(
            delayMs: 580,
            child: Pressable(
              onTap: () {
                r.restore();
                Navigator.pushNamed(context, '/result');
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.35)),
                  boxShadow: AppDesign.shadowSm,
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
                      child: Icon(Icons.assignment_turned_in_rounded,
                          color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Natiijadii ugu dambeysay · $dateStr',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: context.textMuted,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '${_riskLabel(r.predictionNumber)} · ${r.confidence.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: color),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: context.textMuted, size: 22),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (AuthService.currentUser?['name'] as String?) ?? 'U';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(initial,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String somali;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.somali,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.22)),
        boxShadow: AppDesign.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 7),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary)),
          Text(somali,
              style: TextStyle(
                  fontSize: 10,
                  color: context.textSecondary,
                  fontStyle: FontStyle.italic),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
