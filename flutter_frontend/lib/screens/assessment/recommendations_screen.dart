import 'package:flutter/material.dart';
import '../../widgets/home_button.dart';
import '../../models/assessment_data.dart';
import '../../services/theme_service.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  // Recommendations based on severity
  List<Map<String, dynamic>> _getRecommendations(int prediction) {
    final List<Map<String, dynamic>> base = [
      {
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFF2E7D32),
        'somal': 'Cun cuntooyinka hodonka ku ah birta',
        'english': 'Eat iron-rich foods',
        'route': '/iron-foods', // Clickable!
      },
      {
        'icon': Icons.local_hospital_outlined,
        'color': const Color(0xFFE53935),
        'somal': 'Booqo Xarun Caafimaad',
        'english': 'Visit a health center',
        'route': null,
      },
      {
        'icon': Icons.medical_information_outlined,
        'color': const Color(0xFF1565C0),
        'somal': 'La tasho dhakhtar haddii calaamadaha sii socdaan',
        'english': 'Consult a doctor if symptoms continue',
        'route': null,
      },
      {
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFF00ACC1),
        'somal': 'Cab biyo badan',
        'english': 'Drink enough fluids',
        'route': null,
      },
    ];

    if (prediction == 2) {
      base.insert(0, {
        'icon': Icons.emergency_outlined,
        'color': const Color(0xFFE53935),
        'somal': 'DEGDEG — La tasho dhakhtar hadda',
        'english': 'URGENT — See a doctor immediately',
        'route': null,
      });
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final int prediction = AssessmentData.predictionNumber;
    final recommendations = _getRecommendations(prediction);

    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Gradient green header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Talooyinka Caafimaadka',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Recommendations',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Hero illustration
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFF66BB6A)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.local_florist,
                          size: 64,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Recommendations list
                      ...recommendations.map((rec) {
                        final route = rec['route'] as String?;
                        final clickable = route != null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: context.borderSubtle),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: clickable
                                    ? () => Navigator.pushNamed(
                                        context, route)
                                    : null,
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Icon circle
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: (rec['color'] as Color)
                                              .withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          rec['icon'] as IconData,
                                          color:
                                              rec['color'] as Color,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rec['somal'] as String,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: context.textPrimary,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              rec['english'] as String,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Clickable indicator
                                      if (clickable)
                                        Container(
                                          padding:
                                              const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: (rec['color'] as Color)
                                                .withOpacity(0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: rec['color'] as Color,
                                            size: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      // Buttons row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                AssessmentData.reset();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.home_outlined,
                                  size: 18, color: Colors.white),
                              label: const Text(
                                'Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF4CAF50),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                AssessmentData.reset();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/start-assessment',
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.refresh,
                                  size: 18, color: Colors.white),
                              label: const Text(
                                'Retake',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF2E7D32),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
