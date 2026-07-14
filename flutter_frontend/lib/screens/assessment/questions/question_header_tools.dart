import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import '../../../services/question_tts_service.dart';

/// "Su'aasha X / Y" label + white progress bar for the gradient question
/// headers. Reads the current route from [ModalRoute] and looks it up in the
/// active question flow, so individual screens need no extra wiring.
class QuestionProgressBar extends StatelessWidget {
  const QuestionProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    final p = AssessmentData.progressFor(route);
    if (p == null) return const SizedBox.shrink();

    final fraction = (p.current / p.total).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Su\'aasha ${p.current} / ${p.total}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '${(fraction * 100).round()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: fraction),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Speaker button that reads the question aloud (for users who cannot read).
class SpeakQuestionButton extends StatelessWidget {
  final String text;
  const SpeakQuestionButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => QuestionTtsService.speak(text),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
        ),
        child: const Icon(Icons.volume_up_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }
}
