import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

/// "Taking iron pills, sprinkles or syrup" — asked to ALL categories.
/// Maps directly to the model feature 'Taking iron pills, sprinkles or syrup'.
class QIronScreen extends StatefulWidget {
  const QIronScreen({super.key});

  @override
  State<QIronScreen> createState() => _QIronScreenState();
}

class _QIronScreenState extends State<QIronScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  bool get _isChild => AssessmentData.category == 'children';

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.nutrition(),
      somalTitle: _isChild
          ? 'Cunuggu ma qaataa kaniiniga birta (iron),\nsharoobo ama sprinkles?'
          : 'Ma qaadataa kaniiniga birta (iron)\nama sharoobadiisa?',
      englishTitle: _isChild
          ? '(Is the child taking iron pills, sprinkles or syrup?)'
          : '(Are you taking iron pills or iron syrup?)',
      illustration: const Icon(
        Icons.medication_outlined,
        color: Color(0xFF2E7D32),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('iron_supplement', _selected);
        final next = AssessmentData.getNextRoute('/q-iron');
        Navigator.pushNamed(context, next);
      },
    );
  }
}
