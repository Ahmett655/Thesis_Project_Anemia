import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QMenDizzyScreen extends StatefulWidget {
  const QMenDizzyScreen({super.key});

  @override
  State<QMenDizzyScreen> createState() => _QMenDizzyScreenState();
}

class _QMenDizzyScreenState extends State<QMenDizzyScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.symptoms(),
      somalTitle: 'Ma dareemeysaa\nmadax wareer?',
      englishTitle: '(Do you feel dizzy?)',
      illustration: const Icon(
        Icons.psychology_outlined,
        color: Color(0xFFE64A19),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('dizziness', _selected);
        final next = AssessmentData.getNextRoute('/q-men-dizzy');
        Navigator.pushNamed(context, next);
      },
    );
  }
}