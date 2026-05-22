import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QChildFoodScreen extends StatefulWidget {
  const QChildFoodScreen({super.key});

  @override
  State<QChildFoodScreen> createState() => _QChildFoodScreenState();
}

class _QChildFoodScreenState extends State<QChildFoodScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'yes', label: 'Haa ( Yes )', icon: Icons.check_circle_outline),
    OptionItem(value: 'no',  label: 'Maya ( No )', icon: Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.nutrition(),
      somalTitle: 'Cunuggu ma cunaa\ncunto fiican?',
      englishTitle: '(Does the child eat good food?)',
      illustration: const Icon(
        Icons.restaurant_outlined,
        color: Color(0xFF558B2F),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('child_good_food', _selected);
        final next = AssessmentData.getNextRoute('/q-child-food');
        Navigator.pushNamed(context, next);
      },
    );
  }
}