import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Reusable theme toggle button.
///
/// - Floats over a dark background when [onDarkBg] is true (e.g. inside a
///   colored header) — uses translucent white pill styling.
/// - Otherwise blends with the page surface — uses theme card color.
class ThemeToggleButton extends StatelessWidget {
  final bool onDarkBg;
  final double size;

  const ThemeToggleButton({
    super.key,
    this.onDarkBg = false,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bg = onDarkBg
            ? Colors.white.withOpacity(0.25)
            : (isDark ? const Color(0xFF252538) : Colors.white);
        final border = onDarkBg
            ? Colors.white.withOpacity(0.4)
            : (isDark ? const Color(0xFF3A3A50) : Colors.grey.shade300);
        final iconColor = onDarkBg
            ? Colors.white
            : (isDark ? Colors.amber.shade400 : const Color(0xFF1A1A2E));

        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: ThemeService.instance.toggle,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1),
                boxShadow: onDarkBg
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: Tween<double>(begin: 0.5, end: 1.0).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(isDark),
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
