import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QSmokingScreen extends StatefulWidget {
  const QSmokingScreen({super.key});

  @override
  State<QSmokingScreen> createState() => _QSmokingScreenState();
}

class _QSmokingScreenState extends State<QSmokingScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.lifestyle(),
      somalTitle: 'Ma cabtaa sigaar?',
      englishTitle: '(Do you smoke?)',
      illustration: const Icon(
        Icons.smoking_rooms_outlined,
        color: Color(0xFFC62828),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('smoking', _selected);
        final next = AssessmentData.getNextRoute('/q-smoking');
        Navigator.pushNamed(context, next);
      },
    );
  }
}