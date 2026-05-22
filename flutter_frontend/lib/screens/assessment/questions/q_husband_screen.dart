import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QHusbandScreen extends StatefulWidget {
  const QHusbandScreen({super.key});

  @override
  State<QHusbandScreen> createState() => _QHusbandScreenState();
}

class _QHusbandScreenState extends State<QHusbandScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.family(),
      somalTitle: 'Ma la nooshahay\nninkaaga hadda?',
      englishTitle: '(Do you live with your husband now?)',
      illustration: const Icon(
        Icons.people_outline,
        color: Color(0xFF7B1FA2),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('husband_present', _selected);
        final next = AssessmentData.getNextRoute('/q-husband');
        Navigator.pushNamed(context, next);
      },
    );
  }
}