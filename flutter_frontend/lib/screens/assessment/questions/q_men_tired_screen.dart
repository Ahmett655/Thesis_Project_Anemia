import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QMenTiredScreen extends StatefulWidget {
  const QMenTiredScreen({super.key});

  @override
  State<QMenTiredScreen> createState() => _QMenTiredScreenState();
}

class _QMenTiredScreenState extends State<QMenTiredScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.symptoms(),
      somalTitle: 'Ma dareemeysaa\ndaal badan?',
      englishTitle: '(Do you feel very tired?)',
      illustration: const Icon(
        Icons.sentiment_very_dissatisfied_outlined,
        color: Color(0xFFE64A19),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('fatigue', _selected);
        final next = AssessmentData.getNextRoute('/q-men-tired');
        Navigator.pushNamed(context, next);
      },
    );
  }
}