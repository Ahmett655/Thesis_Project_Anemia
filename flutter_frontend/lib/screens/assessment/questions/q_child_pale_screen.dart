import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QChildPaleScreen extends StatefulWidget {
  const QChildPaleScreen({super.key});

  @override
  State<QChildPaleScreen> createState() => _QChildPaleScreenState();
}

class _QChildPaleScreenState extends State<QChildPaleScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.child(),
      somalTitle: 'Cunuggu ma u egyahay\nmid cirro ah (midab cad)?',
      englishTitle: '(Does the child look pale (white)?)',
      illustration: const Icon(
        Icons.face_outlined,
        color: Color(0xFF1976D2),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('child_pale', _selected);
        final next = AssessmentData.getNextRoute('/q-child-pale');
        Navigator.pushNamed(context, next);
      },
    );
  }
}