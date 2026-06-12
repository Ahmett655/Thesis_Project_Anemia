import 'package:flutter/material.dart';
import '../../widgets/home_button.dart';
import '../../models/assessment_data.dart';
import '../../services/theme_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selected = '';

  // Each category has its OWN color so selection feels distinct
  final List<_Category> _categories = const [
    _Category(
      value: 'men',
      label: 'Rag',
      english: 'Men',
      icon: Icons.man_rounded,
      color: Color(0xFF1565C0), // blue
    ),
    _Category(
      value: 'women',
      label: 'Dumar',
      english: 'Women',
      icon: Icons.woman_rounded,
      color: Color(0xFFC2185B), // pink
    ),
    _Category(
      value: 'children',
      label: 'Ilmo Yar',
      english: 'Children',
      icon: Icons.child_care_rounded,
      color: Color(0xFF00897B), // teal
    ),
  ];

  static const _heroColor = Color(0xFF1A1A2E);
  static const _accentColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // ============ Gradient header ============
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.25),
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
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Colors.white.withOpacity(0.4),
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
                                    color:
                                        Colors.white.withOpacity(0.4),
                                    width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.assignment_outlined,
                                      size: 14, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'CATEGORY',
                                    style: TextStyle(
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
                        // Hero illustration
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
                              child: const Center(
                                child: Icon(
                                  Icons.assignment_ind_outlined,
                                  size: 50,
                                  color: _accentColor,
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

              // ============ Body ============
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                  child: Column(
                    children: [
                      Text(
                        'Yaa la baarayaa?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(Who is being tested?)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Category cards
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = _selected == cat.value;
                            return _CategoryCard(
                              category: cat,
                              selected: isSelected,
                              onTap: () =>
                                  setState(() => _selected = cat.value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Next button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _selected.isEmpty
                              ? null
                              : () {
                                  AssessmentData.category = _selected;
                                  final flow =
                                      AssessmentData.getQuestionFlow();
                                  Navigator.pushNamed(
                                      context, flow[0]);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selected.isEmpty
                                ? Colors.grey.shade300
                                : _categories
                                    .firstWhere(
                                        (c) => c.value == _selected,
                                        orElse: () =>
                                            _categories[0])
                                    .color,
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
}

class _Category {
  final String value;
  final String label;
  final String english;
  final IconData icon;
  final Color color;

  const _Category({
    required this.value,
    required this.label,
    required this.english,
    required this.icon,
    required this.color,
  });
}

class _CategoryCard extends StatelessWidget {
  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? category.color.withOpacity(context.isDark ? 0.20 : 0.08)
            : context.bgCard,
        border: Border.all(
          color: selected ? category.color : context.borderSubtle,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: category.color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(
                        selected ? 0.18 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.english,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected
                          ? category.color
                          : context.textMuted,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    color: selected ? category.color : context.bgCard,
                  ),
                  child: selected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 16)
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
