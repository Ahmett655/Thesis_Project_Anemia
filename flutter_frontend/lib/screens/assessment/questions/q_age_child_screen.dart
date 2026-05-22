import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QAgeChildScreen extends StatefulWidget {
  const QAgeChildScreen({super.key});

  @override
  State<QAgeChildScreen> createState() => _QAgeChildScreenState();
}

class _QAgeChildScreenState extends State<QAgeChildScreen> {
  String _selected = '';

  final List<OptionItem> _options = [
    OptionItem(
        value: '1-6',
        label: '1-6',
        icon: Icons.child_care),
    OptionItem(
        value: '6-12+',
        label: '6-12+',
        icon: Icons.child_friendly),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.child(),
      somalTitle: 'Ilmuhu waa Imisa Jir?',
      englishTitle: '(How old is the child?)',
      illustration: const Icon(
        Icons.child_care,
        color: Color(0xFF1976D2),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('age_group', _selected);
        final next = AssessmentData.getNextRoute('/q-age-child');
        Navigator.pushNamed(context, next);
      },
    );
  }
}