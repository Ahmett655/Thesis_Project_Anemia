import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_design.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance; // logo + text reveal
  late final AnimationController _breathe; // continuous breathing/glow
  late final AnimationController _orbit; // rotating rings + particles

  late final Animation<double> _logoScale;
  late final Animation<double> _ringFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subFade;

  @override
  void initState() {
    super.initState();

    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScale = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut));
    _ringFade = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut));
    _titleFade = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut));
    _titleSlide = Tween(begin: const Offset(0, 0.35), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic)));
    _subFade = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut));

    _entrance.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 4200));
    if (mounted) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, a, __) => const _HomeLoader(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ));
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _breathe.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.brandGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft radial glow behind the logo
            AnimatedBuilder(
              animation: _breathe,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.12 + _breathe.value * 0.05),
                      Colors.transparent,
                    ],
                    radius: 0.6 + _breathe.value * 0.08,
                  ),
                ),
              ),
            ),

            // Orbiting blood-cell particles
            ..._particles(),

            // Center content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _logo(),
                  const SizedBox(height: 42),
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: Column(
                        children: [
                          const Text(
                            'Anemia Risk',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.05,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (r) => const LinearGradient(
                              colors: [Color(0xFFFFE4E6), Colors.white],
                            ).createShader(r),
                            child: const Text(
                              'Assessment',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _subFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.28)),
                      ),
                      child: const Text(
                        'Qiimeynta Khatarta Yaraanta Dhiigga',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom branding + progress
            Positioned(
              bottom: 46,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _subFade,
                child: Column(
                  children: [
                    _progressBar(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined,
                            size: 13,
                            color: Colors.white.withOpacity(0.75)),
                        const SizedBox(width: 6),
                        Text(
                          'POWERED BY MACHINE LEARNING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.75),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Breathing logo with concentric ripple rings ----
  Widget _logo() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding ripple rings
          for (int i = 0; i < 3; i++)
            AnimatedBuilder(
              animation: Listenable.merge([_breathe, _ringFade]),
              builder: (_, __) {
                final t = ((_breathe.value + i / 3) % 1.0);
                return Opacity(
                  opacity: (1 - t) * 0.5 * _ringFade.value,
                  child: Container(
                    width: 120 + t * 100,
                    height: 120 + t * 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.6), width: 1.5),
                    ),
                  ),
                );
              },
            ),
          // Core logo
          AnimatedBuilder(
            animation: Listenable.merge([_logoScale, _breathe]),
            builder: (_, __) {
              final pulse = 1 + _breathe.value * 0.05;
              return Transform.scale(
                scale: _logoScale.value.clamp(0.0, 2.0) * pulse,
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.22),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (r) =>
                        AppDesign.brandGradient.createShader(r),
                    child: const Icon(Icons.bloodtype,
                        size: 64, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _progressBar() {
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AnimatedBuilder(
          animation: _orbit,
          builder: (_, __) {
            return LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.22),
              valueColor:
                  AlwaysStoppedAnimation(Colors.white.withOpacity(0.95)),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _particles() {
    final rnd = math.Random(7);
    return List.generate(14, (i) {
      final radius = 120.0 + rnd.nextDouble() * 130;
      final baseAngle = rnd.nextDouble() * 2 * math.pi;
      final size = 5.0 + rnd.nextDouble() * 12;
      final speed = 0.4 + rnd.nextDouble() * 0.8;
      return AnimatedBuilder(
        animation: _orbit,
        builder: (_, __) {
          final a = baseAngle + _orbit.value * 2 * math.pi * speed;
          return Transform.translate(
            offset: Offset(math.cos(a) * radius, math.sin(a) * radius),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10 + (i % 3) * 0.04),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      );
    });
  }
}

/// Tiny pass-through so the splash transition targets the real home route
/// while keeping named-route navigation intact elsewhere.
class _HomeLoader extends StatelessWidget {
  const _HomeLoader();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/home');
    });
    return const Scaffold(
      backgroundColor: Color(0xFF9F1239),
      body: SizedBox.shrink(),
    );
  }
}
