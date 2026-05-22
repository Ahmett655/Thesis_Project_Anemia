import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QAgeAdultsScreen extends StatefulWidget {
  const QAgeAdultsScreen({super.key});

  @override
  State<QAgeAdultsScreen> createState() => _QAgeAdultsScreenState();
}

class _QAgeAdultsScreenState extends State<QAgeAdultsScreen> {
  String _selected = '';

  final List<OptionItem> _options = [
    OptionItem(
        value: '18-29',
        label: '18-29',
        icon: Icons.person),
    OptionItem(
        value: '29-50',
        label: '29-50',
        icon: Icons.person_2),
    OptionItem(
        value: '50+',
        label: '50+',
        icon: Icons.elderly),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.demographics(),
      somalTitle: 'Waa Imisa Jir?',
      englishTitle: '(How old are you?)',
      illustration: const Icon(
        Icons.cake_outlined,
        color: Color(0xFF1565C0),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('age_group', _selected);
        final next = AssessmentData.getNextRoute('/q-age-adults');
        Navigator.pushNamed(context, next);
      },
    );
  }
}