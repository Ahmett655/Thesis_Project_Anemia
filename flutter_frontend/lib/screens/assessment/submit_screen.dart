import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../widgets/home_button.dart';
import '../../models/assessment_data.dart';
import '../../services/theme_service.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/top_message_banner.dart';

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatController;
  late AnimationController _ringsController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _ringsController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    // Decide payment from the wealth question already answered:
    // "poor" -> free (skip payment); "moderate"/"good" -> pay via WaafiPay.
    final wealth = (AssessmentData.answers['wealth'] ?? '').toString();

    if (wealth == 'poor') {
      AssessmentData.saveAnswer('payment_status', 'waived_poor');
      TopMessageBanner.info(
        context,
        'Falanqayn dhammaan jawaabahaaga...',
        title: 'Submit la sameeyay!',
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) Navigator.pushNamed(context, '/loading');
      });
    } else {
      // Moderate / Good (or unspecified) -> require payment first.
      AssessmentData.saveAnswer('payment_status', 'paid');
      Navigator.pushNamed(context, '/payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final answeredCount = AssessmentData.answers.length;
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.30),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppBackButton(
                              onDarkBg: true,
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            const HomeButton(onDarkBg: true),
                            const Spacer(),
                            const ThemeToggleButton(onDarkBg: true),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
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
                              const Icon(Icons.checklist_rounded,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                '$answeredCount QUESTIONS ANSWERED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ..._buildRings(),
                            AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_scaleAnim, _floatController]),
                              builder: (context, _) {
                                final floatY = math.sin(
                                            _floatController.value *
                                                math.pi *
                                                2) *
                                        6 -
                                    2;
                                return Transform.translate(
                                  offset: Offset(0, floatY),
                                  child: Transform.scale(
                                    scale: _scaleAnim.value,
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF1E88E5),
                                            Color(0xFF1565C0),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF1565C0)
                                                .withOpacity(0.5),
                                            blurRadius: 30,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 70,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SlideTransition(
                        position: _slideAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [
                              Text(
                                'SUBMIT',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: context.textPrimary,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Gudbi Xogtaada Si Laguu Siiyo\nTalo Kugu Haboon',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textSecondary,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Submit your data to get personalized advice',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SlideTransition(
                        position: _slideAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0)
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF1565C0)
                                      .withOpacity(0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lock_outline,
                                    size: 18,
                                    color: Color(0xFF1565C0)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Xogtaadu waa sirta — kaliya ML-ka ayaa falanqaynaaya, lama wadaagi doonno qof kale.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SlideTransition(
                        position: _slideAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: _onSubmit,
                              icon: const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 22),
                              label: const Text(
                                'SUBMIT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1565C0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
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
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRings() {
    return [
      AnimatedBuilder(
        animation: _ringsController,
        builder: (_, __) => Transform.scale(
          scale: 1.0 + _ringsController.value * 0.4,
          child: Opacity(
            opacity: 0.4 - _ringsController.value * 0.4,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF1565C0), width: 2.5),
              ),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _ringsController,
        builder: (_, __) {
          final v = (_ringsController.value + 0.5) % 1.0;
          return Transform.scale(
            scale: 1.0 + v * 0.4,
            child: Opacity(
              opacity: 0.4 - v * 0.4,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF42A5F5), width: 2),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
}
