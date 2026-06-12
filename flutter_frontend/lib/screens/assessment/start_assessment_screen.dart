import 'package:flutter/material.dart';
import '../../widgets/home_button.dart';
import '../../models/assessment_data.dart';
import '../../services/theme_service.dart';
import '../../widgets/theme_toggle_button.dart';

class StartAssessmentScreen extends StatelessWidget {
  const StartAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // ============ Gradient hero header ============
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
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    child: Column(
                      children: [
                        // Top row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withOpacity(0.25),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.4),
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
                            const ThemeToggleButton(onDarkBg: true),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Hero illustration
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.health_and_safety_outlined,
                                  size: 80,
                                  color: Color(0xFFE53935),
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
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bilaaw Baaritaan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: context.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '(Start the assessment)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFFFB74D)
                                  .withOpacity(0.4)),
                        ),
                        child: const Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline,
                                color: Color(0xFFFF8F00), size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sii jawaab dhammaan su\'aalaha',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF7C5800),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Answer all questions honestly for the most accurate anemia risk assessment.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF7C5800),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Start button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            AssessmentData.reset();
                            Navigator.pushNamed(context, '/category');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start Assessment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
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
