import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Small reusable Home button — returns to the home screen clearing the
/// navigation stack. Use [onDarkBg] inside gradient/colored headers.
class HomeButton extends StatelessWidget {
  final bool onDarkBg;
  const HomeButton({super.key, this.onDarkBg = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamedAndRemoveUntil(
          context, '/home', (route) => false),
      child: Container(
        width: 40,
        height: 40,
        decoration: onDarkBg
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 1),
              )
            : BoxDecoration(
                color: context.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderSubtle),
              ),
        child: Icon(
          Icons.home_rounded,
          color: onDarkBg ? Colors.white : context.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
