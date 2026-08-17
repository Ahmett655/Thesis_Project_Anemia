import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

/// "Had fever in last two weeks" — asked to ALL categories.
/// Maps directly to the model feature 'Had fever in last two weeks'.
class QFeverScreen extends StatefulWidget {
  const QFeverScreen({super.key});

  @override
  State<QFeverScreen> createState() => _QFeverScreenState();
}

class _QFeverScreenState extends State<QFeverScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  bool get _isChild => AssessmentData.category == 'children';

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.symptoms(),
      somalTitle: _isChild
          ? 'Cunuga Qandho Miyaa Isku Arkay\n2-dii Is Buuc Ee U Dambeesay?'
          : 'Qandho Miyaa Isku Aragtay\n2-dii Is Buuc Ee U Dambeesay?',
      englishTitle: _isChild
          ? '(Has the child had a fever in the last two weeks?)'
          : '(Have you had a fever in the last two weeks?)',
      illustration: const Icon(
        Icons.thermostat_outlined,
        color: Color(0xFFE64A19),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('fever', _selected);
        final next = AssessmentData.getNextRoute('/q-fever');
        Navigator.pushNamed(context, next);
      },
    );
  }
}
