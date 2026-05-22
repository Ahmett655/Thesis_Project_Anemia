import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QBirthHistoryScreen extends StatefulWidget {
  const QBirthHistoryScreen({super.key});

  @override
  State<QBirthHistoryScreen> createState() => _QBirthHistoryScreenState();
}

class _QBirthHistoryScreenState extends State<QBirthHistoryScreen> {
  String _selected = '';

  final List<OptionItem> _options = [
    OptionItem(value: '1', label: '1 Mar ( once )'),
    OptionItem(value: '2', label: '2 Mar ( twice )'),
    OptionItem(value: '3', label: '3 Mar ( three times )'),
    OptionItem(value: '4', label: '4 Mar ( four times )'),
    OptionItem(value: '0', label: 'Marna ( never )'),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.maternal(),
      somalTitle: 'Immisa jeer ayaad umushay\n5tii sano ee la soo dhaafay?',
      englishTitle: '(How many times have you given\nbirth in the past 5 years?)',
      illustration: const Icon(
        Icons.child_friendly_outlined,
        color: Color(0xFFC2185B),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('births_last_5_years', _selected);
        final next =
        AssessmentData.getNextRoute('/q-birth-history');
        Navigator.pushNamed(context, next);
      },
    );
  }
}