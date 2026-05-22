import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QChildWeakScreen extends StatefulWidget {
  const QChildWeakScreen({super.key});

  @override
  State<QChildWeakScreen> createState() => _QChildWeakScreenState();
}

class _QChildWeakScreenState extends State<QChildWeakScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.child(),
      somalTitle: 'Cunuggu ma Tabar Daran yahay\nama madax wareer ma leeyahay?',
      englishTitle: '(Is the child weak or dizzy?)',
      illustration: const Icon(
        Icons.sick_outlined,
        color: Color(0xFF1976D2),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('child_weak_dizzy', _selected);
        final next = AssessmentData.getNextRoute('/q-child-weak');
        Navigator.pushNamed(context, next);
      },
    );
  }
}