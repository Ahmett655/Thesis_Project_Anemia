import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QMosquitoScreen extends StatefulWidget {
  const QMosquitoScreen({super.key});

  @override
  State<QMosquitoScreen> createState() => _QMosquitoScreenState();
}

class _QMosquitoScreenState extends State<QMosquitoScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.prevention(),
      somalTitle: 'Ma isticmaashaa\nshabaq kaneeco?',
      englishTitle: '(Do you use a mosquito net?)',
      illustration: const Icon(
        Icons.shield_outlined,
        color: Color(0xFF388E3C),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('mosquito_net', _selected);
        final next = AssessmentData.getNextRoute('/q-mosquito');
        Navigator.pushNamed(context, next);
      },
    );
  }
}