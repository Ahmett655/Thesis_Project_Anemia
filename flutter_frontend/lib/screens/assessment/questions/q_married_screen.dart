import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QMarriedScreen extends StatefulWidget {
  const QMarriedScreen({super.key});

  @override
  State<QMarriedScreen> createState() => _QMarriedScreenState();
}

class _QMarriedScreenState extends State<QMarriedScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.family(),
      somalTitle: 'Ma guursatay?',
      englishTitle: '(Are you married?)',
      illustration: const Icon(
        Icons.favorite_outline,
        color: Color(0xFF7B1FA2),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('married', _selected);
        final next = AssessmentData.getNextRoute('/q-married');
        Navigator.pushNamed(context, next);
      },
    );
  }
}