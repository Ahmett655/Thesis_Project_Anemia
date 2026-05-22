import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QChildTiredScreen extends StatefulWidget {
  const QChildTiredScreen({super.key});

  @override
  State<QChildTiredScreen> createState() => _QChildTiredScreenState();
}

class _QChildTiredScreenState extends State<QChildTiredScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.child(),
      somalTitle: 'Cunuggu ma dareemaa\ndaal badan?',
      englishTitle: '(Does the child feel very tired?)',
      illustration: const Icon(
        Icons.airline_seat_flat_outlined,
        color: Color(0xFF1976D2),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('child_tired', _selected);
        final next = AssessmentData.getNextRoute('/q-child-tired');
        Navigator.pushNamed(context, next);
      },
    );
  }
}