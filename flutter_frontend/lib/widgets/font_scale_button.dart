import 'package:flutter/material.dart';
import '../services/font_scale_service.dart';
import '../services/theme_service.dart';

/// "Aa" button that cycles the app-wide text size (100% → 115% → 130%).
/// Styled to match [ThemeToggleButton].
class FontScaleButton extends StatelessWidget {
  final bool onDarkBg;
  final double size;

  const FontScaleButton({
    super.key,
    this.onDarkBg = false,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: FontScaleService.instance,
      builder: (context, scale, _) {
        final isDark = ThemeService.instance.isDark;
        final bg = onDarkBg
            ? Colors.white.withOpacity(0.25)
            : (isDark ? const Color(0xFF252538) : Colors.white);
        final border = onDarkBg
            ? Colors.white.withOpacity(0.4)
            : (isDark ? const Color(0xFF3A3A50) : Colors.grey.shade300);
        final fg = onDarkBg
            ? Colors.white
            : (isDark ? Colors.white : const Color(0xFF1A1A2E));

        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: FontScaleService.instance.cycle,
            customBorder: const CircleBorder(),
            child: Container(
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
              child: Center(
                child: Text(
                  // Grows slightly with the current scale as a visual hint.
                  'Aa',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13 + (scale - 1.0) * 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
