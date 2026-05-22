import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bgController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    // Background "blood drop" circles slow rotation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Pulse animation for the logo glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Logo scale + rotation entrance (slower & smoother)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // Text fade and slide (a bit slower for a smoother reveal)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    _subtitleFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    // Sequence
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _textController.forward();
    });

    _navigateToHome();
  }

  void _navigateToHome() async {
    // Full splash duration: ~4.5 seconds
    // ( logo entrance 1.5s + text reveal 1.2s + breathing room ~1.8s )
    await Future.delayed(const Duration(milliseconds: 4500));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE53935),
              Color(0xFFC62828),
              Color(0xFFB71C1C),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ===== Decorative background circles (blood cells) =====
            ..._buildBgCircles(),

            // ===== Center content =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_logoController, _pulseController]),
                    builder: (context, _) {
                      final pulse = 1.0 + (_pulseController.value * 0.08);
                      return Transform.scale(
                        scale: _logoScale.value * pulse,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: _buildLogo(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  // Main title
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: const Column(
                        children: [
                          Text(
                            'Anemia Risk',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Assessment',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Subtitle Somali
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1),
                      ),
                      child: const Text(
                        'Qiimeynta Khatarta Yaraanta Dhiigga',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
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

            // ===== Bottom loading + branding =====
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _subtitleFade,
                child: Column(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                            Colors.white.withOpacity(0.85)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Powered by Machine Learning',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.0,
                      ),
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

  // ============ Logo widget ============
  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
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
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.bloodtype,
              size: 60,
              color: Color(0xFFE53935),
            ),
          ),
        ),
      ),
    );
  }

  // ============ Animated decorative bg circles ============
  List<Widget> _buildBgCircles() {
    return [
      // Big outer rotating ring
      AnimatedBuilder(
        animation: _bgController,
        builder: (_, __) => Transform.rotate(
          angle: _bgController.value * 2 * math.pi,
          child: _circle(420, 0.06),
        ),
      ),
      // Medium ring counter-rotating
      AnimatedBuilder(
        animation: _bgController,
        builder: (_, __) => Transform.rotate(
          angle: -_bgController.value * 2 * math.pi * 0.7,
          child: _circle(300, 0.08),
        ),
      ),
      // Floating decorative dots
      _floatingDot(left: 40, top: 80, size: 12, opacity: 0.25),
      _floatingDot(right: 30, top: 130, size: 18, opacity: 0.18),
      _floatingDot(left: 60, bottom: 180, size: 10, opacity: 0.20),
      _floatingDot(right: 50, bottom: 220, size: 14, opacity: 0.22),
      _floatingDot(left: 30, top: 240, size: 8, opacity: 0.30),
    ];
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(opacity),
          width: 2,
        ),
      ),
    );
  }

  Widget _floatingDot({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final scale = 1.0 + (_pulseController.value * 0.3);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
