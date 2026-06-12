import 'package:flutter/material.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/home_button.dart';

/// Reusable widget for all Yes/No and multi-choice questions.
/// Now supports per-question theming via [QuestionTheme].
class QuestionWidget extends StatelessWidget {
  final String somalTitle;
  final String englishTitle;
  final Widget illustration;
  final List<OptionItem> options;
  final String selected;
  final Function(String) onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  /// Optional theme — controls header gradient, accent colors, etc.
  /// If null, falls back to default red theme.
  final QuestionTheme? theme;

  const QuestionWidget({
    super.key,
    required this.somalTitle,
    required this.englishTitle,
    required this.illustration,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? QuestionTheme.defaultTheme();
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // ============ Header with gradient + illustration ============
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: t.gradientColors,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: t.accentColor.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        // Top row: back button + progress dot
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onBack,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const HomeButton(onDarkBg: true),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(t.badgeIcon,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.badgeLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Illustration inside soft circle
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: illustration,
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
              ),

              // ============ Question + Options ============
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                  child: Column(
                    children: [
                      // Somali title
                      Text(
                        somalTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        englishTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Options
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final opt = options[index];
                            final isSelected = selected == opt.value;
                            return _buildOptionTile(opt, isSelected, t, context);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Next button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: selected.isEmpty ? null : onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: t.accentColor,
                            disabledBackgroundColor:
                                Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      OptionItem opt, bool isSelected, QuestionTheme t, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? t.accentColor.withOpacity(context.isDark ? 0.20 : 0.08)
            : context.bgCard,
        border: Border.all(
          color: isSelected ? t.accentColor : context.borderSubtle,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: t.accentColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(opt.value),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            child: Row(
              children: [
                if (opt.icon != null) ...[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.accentColor.withOpacity(
                          isSelected ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(opt.icon, color: t.accentColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? t.accentColor
                          : context.textMuted,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    color: isSelected ? t.accentColor : context.bgCard,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionItem {
  final String value;
  final String label;
  final IconData? icon;

  const OptionItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Theme for individual question screens — controls header gradient,
/// accent color, and small badge in the header.
class QuestionTheme {
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData badgeIcon;
  final String badgeLabel;

  const QuestionTheme({
    required this.gradientColors,
    required this.accentColor,
    required this.badgeIcon,
    required this.badgeLabel,
  });

  /// Default red theme (fallback)
  factory QuestionTheme.defaultTheme() => const QuestionTheme(
        gradientColors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        accentColor: Color(0xFFE53935),
        badgeIcon: Icons.help_outline,
        badgeLabel: 'QUESTION',
      );

  // ============= Themed presets per question topic =============

  /// Demographics / personal info (age, residence, married, etc.)
  factory QuestionTheme.demographics() => const QuestionTheme(
        gradientColors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        accentColor: Color(0xFF1565C0),
        badgeIcon: Icons.person_outline,
        badgeLabel: 'DEMOGRAPHICS',
      );

  /// Location / residence
  factory QuestionTheme.location() => const QuestionTheme(
        gradientColors: [Color(0xFF26A69A), Color(0xFF00796B)],
        accentColor: Color(0xFF00796B),
        badgeIcon: Icons.location_on_outlined,
        badgeLabel: 'LOCATION',
      );

  /// Education
  factory QuestionTheme.education() => const QuestionTheme(
        gradientColors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
        accentColor: Color(0xFF5E35B1),
        badgeIcon: Icons.school_outlined,
        badgeLabel: 'EDUCATION',
      );

  /// Wealth / economic
  factory QuestionTheme.wealth() => const QuestionTheme(
        gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
        accentColor: Color(0xFFFF8F00),
        badgeIcon: Icons.account_balance_wallet_outlined,
        badgeLabel: 'WEALTH',
      );

  /// Lifestyle (smoking, mosquito net)
  factory QuestionTheme.lifestyle() => const QuestionTheme(
        gradientColors: [Color(0xFFEF5350), Color(0xFFC62828)],
        accentColor: Color(0xFFC62828),
        badgeIcon: Icons.local_fire_department_outlined,
        badgeLabel: 'LIFESTYLE',
      );

  /// Health prevention (mosquito net, supplements)
  factory QuestionTheme.prevention() => const QuestionTheme(
        gradientColors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
        accentColor: Color(0xFF388E3C),
        badgeIcon: Icons.shield_outlined,
        badgeLabel: 'PREVENTION',
      );

  /// Pregnancy / maternal health
  factory QuestionTheme.maternal() => const QuestionTheme(
        gradientColors: [Color(0xFFEC407A), Color(0xFFC2185B)],
        accentColor: Color(0xFFC2185B),
        badgeIcon: Icons.pregnant_woman,
        badgeLabel: 'MATERNAL',
      );

  /// Marriage / family
  factory QuestionTheme.family() => const QuestionTheme(
        gradientColors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
        accentColor: Color(0xFF7B1FA2),
        badgeIcon: Icons.favorite_outline,
        badgeLabel: 'FAMILY',
      );

  /// Symptoms (tired, dizzy, weak)
  factory QuestionTheme.symptoms() => const QuestionTheme(
        gradientColors: [Color(0xFFFF7043), Color(0xFFE64A19)],
        accentColor: Color(0xFFE64A19),
        badgeIcon: Icons.healing_outlined,
        badgeLabel: 'SYMPTOMS',
      );

  /// Children-specific
  factory QuestionTheme.child() => const QuestionTheme(
        gradientColors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
        accentColor: Color(0xFF1976D2),
        badgeIcon: Icons.child_care,
        badgeLabel: 'CHILD HEALTH',
      );

  /// Nutrition / food
  factory QuestionTheme.nutrition() => const QuestionTheme(
        gradientColors: [Color(0xFF9CCC65), Color(0xFF558B2F)],
        accentColor: Color(0xFF558B2F),
        badgeIcon: Icons.restaurant_outlined,
        badgeLabel: 'NUTRITION',
      );
}
