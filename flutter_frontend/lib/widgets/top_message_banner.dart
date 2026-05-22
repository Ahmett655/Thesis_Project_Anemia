import 'package:flutter/material.dart';
import '../services/theme_service.dart';

enum BannerType { success, error, info, warning }

/// Beautiful animated top banner that slides down from the top of the screen.
/// Use [TopMessageBanner.show] to display anywhere in the app.
class TopMessageBanner {
  /// Show an animated banner sliding down from the top.
  static void show(
    BuildContext context, {
    required String message,
    BannerType type = BannerType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (ctx) => _BannerWidget(
        message: message,
        title: title,
        type: type,
        duration: duration,
        onDismissed: () => entry?.remove(),
      ),
    );
    overlay.insert(entry);
  }

  /// Quick success banner.
  static void success(BuildContext context, String message, {String? title}) =>
      show(context,
          message: message, title: title, type: BannerType.success);

  /// Quick error banner.
  static void error(BuildContext context, String message, {String? title}) =>
      show(context,
          message: message, title: title, type: BannerType.error);

  /// Quick info banner.
  static void info(BuildContext context, String message, {String? title}) =>
      show(context, message: message, title: title, type: BannerType.info);

  /// Quick warning banner.
  static void warning(BuildContext context, String message, {String? title}) =>
      show(context,
          message: message, title: title, type: BannerType.warning);
}

class _BannerWidget extends StatefulWidget {
  final String message;
  final String? title;
  final BannerType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _BannerWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.title,
  });

  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _bounce = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.bounceOut),
    );

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _BannerStyle get _style {
    switch (widget.type) {
      case BannerType.success:
        return const _BannerStyle(
          color: Color(0xFF26A69A),
          gradientStart: Color(0xFF26A69A),
          gradientEnd: Color(0xFF00897B),
          icon: Icons.check_circle,
          defaultTitle: 'Guul!',
        );
      case BannerType.error:
        return const _BannerStyle(
          color: Color(0xFFE53935),
          gradientStart: Color(0xFFE53935),
          gradientEnd: Color(0xFFC62828),
          icon: Icons.error,
          defaultTitle: 'Cilad!',
        );
      case BannerType.info:
        return const _BannerStyle(
          color: Color(0xFF1565C0),
          gradientStart: Color(0xFF42A5F5),
          gradientEnd: Color(0xFF1565C0),
          icon: Icons.info,
          defaultTitle: 'Macluumaad',
        );
      case BannerType.warning:
        return const _BannerStyle(
          color: Color(0xFFFF8F00),
          gradientStart: Color(0xFFFFB300),
          gradientEnd: Color(0xFFE65100),
          icon: Icons.warning_amber_rounded,
          defaultTitle: 'Digniin!',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          style.gradientStart,
                          style.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: style.color.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Bouncing icon
                          ScaleTransition(
                            scale: _bounce,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                style.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title ?? style.defaultTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.95),
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          IconButton(
                            onPressed: _dismiss,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white.withOpacity(0.85),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerStyle {
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final String defaultTitle;

  const _BannerStyle({
    required this.color,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    required this.defaultTitle,
  });
}

/// Reusable themed back button used throughout the app.
/// Renders a small rounded square with arrow that adapts to dark / light mode.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool onDarkBg;

  const AppBackButton({super.key, this.onTap, this.onDarkBg = false});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = onDarkBg
        ? Colors.white.withOpacity(0.25)
        : (isDark ? const Color(0xFF252538) : Colors.white);
    final border = onDarkBg
        ? Colors.white.withOpacity(0.4)
        : (isDark ? const Color(0xFF3A3A50) : Colors.grey.shade300);
    final iconColor = onDarkBg
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1A1A2E));

    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
          boxShadow: onDarkBg
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 16),
      ),
    );
  }
}
