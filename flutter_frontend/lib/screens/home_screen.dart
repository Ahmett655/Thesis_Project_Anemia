import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.authToken != null &&
        AuthService.authToken!.isNotEmpty;
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ============ Animated gradient hero ============
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE53935),
                        Color(0xFFB71C1C),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
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
                          const EdgeInsets.fromLTRB(20, 12, 20, 36),
                      child: Column(
                        children: [
                          // Top bar with theme toggle
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.20),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.4),
                                      width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.health_and_safety,
                                        size: 14,
                                        color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'ML-POWERED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (isLoggedIn) ...[
                                _ProfileIconButton(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/profile'),
                                ),
                                const SizedBox(width: 10),
                              ],
                              const ThemeToggleButton(onDarkBg: true),
                            ],
                          ),
                          const SizedBox(height: 26),
                          // Hero blood-cell icon
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.bloodtype,
                                    size: 56,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Anemia Risk',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                          ),
                          const Text(
                            'Assessment',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Qiimeynta Khatarta Yaraanta Dhiigga',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ============ Description card ============
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                          '"This system helps users assess anemia risk easily and quickly"',
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
                ),

                const SizedBox(height: 20),

                // ============ Feature chips ============
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                          child: _FeatureChip(
                              icon: Icons.bolt_outlined,
                              label: 'Fast',
                              somali: 'Degdeg',
                              color: Color(0xFFFF8F00))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _FeatureChip(
                              icon: Icons.lock_outline,
                              label: 'Private',
                              somali: 'Qarsoodi',
                              color: Color(0xFF1565C0))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _FeatureChip(
                              icon: Icons.psychology_outlined,
                              label: 'AI-Powered',
                              somali: 'ML',
                              color: Color(0xFF7B1FA2))),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ============ Primary CTA: Start Assessment ============
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/start-assessment');
                      },
                      icon: const Icon(
                        Icons.play_circle_fill_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      label: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bilaaw Qiimeyn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Start Assessment',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ============ Secondary: Register & Login OR Profile ============
                if (!isLoggedIn) Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                context, '/register'),
                            icon: Icon(Icons.person_add_alt_outlined,
                                color: context.textPrimary, size: 18),
                            label: Text(
                              'Register',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: context.borderSubtle,
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                context, '/login'),
                            icon: const Icon(Icons.login,
                                color: Colors.white, size: 18),
                            label: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF1A1A2E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ============ Profile + History button (logged in) ============
                if (isLoggedIn) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                          context, '/profile'),
                      icon: Icon(Icons.history,
                          color: context.textPrimary, size: 18),
                      label: Text(
                        'My Profile & History',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: context.borderSubtle, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ============ Guest link / Logout ============
                if (!isLoggedIn) TextButton.icon(
                  onPressed: () => Navigator.pushNamed(
                      context, '/start-assessment'),
                  icon: const Icon(Icons.person_outline,
                      size: 16, color: Color(0xFF00ACC1)),
                  label: const Text(
                    'Continue as a guest',
                    style: TextStyle(
                      color: Color(0xFF00ACC1),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ============ Footer ============
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFFD54F)
                              .withOpacity(0.4)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: Color(0xFFFF8F00)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tani waa qiimeyn awoodda u leh kaaliso oo aanan beddeli karin daryeel dhakhtarka.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7C5800),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withOpacity(0.4), width: 1),
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
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
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          Text(
            somali,
            style: TextStyle(
              fontSize: 10,
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
