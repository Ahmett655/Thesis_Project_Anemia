import 'package:flutter/material.dart';

/// ============================================================
///  APP DESIGN SYSTEM  —  "Clinical Crimson"
///  A refined, professional health palette: deep rose/crimson
///  for identity, emerald for positive states, soft neutral
///  surfaces, modern gradients and shadows.
/// ============================================================
class AppDesign {
  AppDesign._();

  // ---- Brand crimson / rose ----
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose = Color(0xFFE11D48); // primary
  static const Color roseDeep = Color(0xFFBE123C);
  static const Color roseDark = Color(0xFF9F1239);
  static const Color roseInk = Color(0xFF6B0F2A);

  // ---- Supporting accents ----
  static const Color emerald = Color(0xFF10B981); // positive / safe
  static const Color amber = Color(0xFFF59E0B); // moderate / warning
  static const Color indigo = Color(0xFF6366F1); // info / AI
  static const Color teal = Color(0xFF0EA5A4);

  // ---- Ink / neutrals ----
  static const Color ink = Color(0xFF14122B);
  static const Color slate = Color(0xFF475569);
  static const Color mist = Color(0xFF94A3B8);
  static const Color cloud = Color(0xFFF6F7FB);

  // ---- Signature gradients ----
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB3B5E), Color(0xFFE11D48), Color(0xFF9F1239)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient roseSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE4E6), Color(0xFFFFF1F2)],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF059669)],
  );

  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
  );

  // ---- Soft elevation ----
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: const Color(0xFF6B0F2A).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: const Color(0xFF6B0F2A).withOpacity(0.10),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glow(Color c, {double opacity = 0.35}) => [
        BoxShadow(
          color: c.withOpacity(opacity),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];

  // ---- Motion ----
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration med = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
}

/// A staggered fade + slide-up entrance. Wrap any widget; pass an
/// increasing [delayMs] to cascade a list of items into view.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 28,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<double> _slide = Tween(begin: widget.offsetY, end: 0.0)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// A button/card that gently scales down on tap for a tactile feel.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Pressable(
      {super.key, required this.child, this.onTap, this.scale = 0.96});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
