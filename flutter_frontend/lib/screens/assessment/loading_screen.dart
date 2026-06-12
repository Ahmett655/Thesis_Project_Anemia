import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/assessment_data.dart';
import '../../services/assessment_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
    _progressController.forward();
    _callApi();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _callApi() async {
    await Future.delayed(const Duration(seconds: 3));

    // Single LAN IP so Chrome (web) and physical mobile device both reach the
    // same backend over Wi-Fi. Change if the computer's LAN IP changes.
    const String apiUrl = 'http://192.168.8.70:3000/api/predict';

    try {
      debugPrint('[Loading] POST $apiUrl');
      debugPrint('[Loading] Payload: ${jsonEncode(AssessmentData.getPayload())}');

      // Includes Authorization header automatically if user is logged in.
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: AssessmentService.headersForPredict,
            body: jsonEncode(AssessmentData.getPayload()),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('[Loading] Status: ${response.statusCode}');
      debugPrint('[Loading] Body:   ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = (data['result'] as Map<String, dynamic>?) ?? {};
        AssessmentData.predictionNumber =
            (result['prediction_number'] as num?)?.toInt() ?? 0;
        AssessmentData.predictionLabel =
            (result['prediction_label'] as String?) ?? 'Unknown';
        final conf = result['confidence'];
        AssessmentData.confidence =
            ((conf is num) ? conf.toDouble() : 0.0) * 100;
        AssessmentData.method =
            (result['method'] as String?) ?? 'Machine Learning';
        final hb = result['hemoglobin_value'];
        AssessmentData.hemoglobinValue =
            (hb is num) ? hb.toDouble() : 0.0;
      } else {
        debugPrint('[Loading] API failed with status ${response.statusCode}');
        AssessmentData.predictionNumber = -1;
        AssessmentData.predictionLabel = 'Error';
        AssessmentData.confidence = 0.0;
        AssessmentData.method = '';
        AssessmentData.hemoglobinValue = 0.0;
      }
    } catch (e, st) {
      debugPrint('[Loading] Exception: $e');
      debugPrint('[Loading] Stack: $st');
      AssessmentData.predictionNumber = -1;
      AssessmentData.predictionLabel = 'Error';
      AssessmentData.confidence = 0.0;
      AssessmentData.method = '';
      AssessmentData.hemoglobinValue = 0.0;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE53935),
              Color(0xFFC62828),
              Color(0xFFB71C1C),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative animated rings background
            ...List.generate(3, (i) {
              return Positioned.fill(
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) {
                    final t = (_progressController.value + i * 0.33) % 1.0;
                    return Center(
                      child: Transform.scale(
                        scale: 0.3 + t * 1.4,
                        child: Opacity(
                          opacity: 0.25 * (1 - t),
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated DNA/medical icon with double rotation
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer rotating ring
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (_, __) => Transform.rotate(
                                  angle: _progressController.value *
                                      2 *
                                      3.14159,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.6),
                                        width: 3,
                                      ),
                                      gradient: SweepGradient(
                                        colors: [
                                          Colors.white
                                              .withOpacity(0.0),
                                          Colors.white
                                              .withOpacity(0.4),
                                          Colors.white
                                              .withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Inner pulsing circle with icon
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.35),
                                      width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.biotech_outlined,
                                        size: 58,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Animated dots
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            final v = _progressController.value;
                            return Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                final phase = (v + i * 0.33) % 1.0;
                                final scale =
                                    0.6 + (phase < 0.5 ? phase : 1 - phase) * 0.8;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Waxaan Falanqeyneynaa\nJawaabahaaga....',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Analyzing your responses with AI...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Animated progress bar
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Fadlan sug',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                    Text(
                                      '${(_progressAnimation.value * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor:
                                        _progressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white
                                                .withOpacity(0.6),
                                            blurRadius: 8,
                                            offset:
                                                const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}