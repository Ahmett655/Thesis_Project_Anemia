import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

/// "When child put to breast" — asked for the CHILDREN category only.
/// Maps to the model dummies: Immediately / Hours: 1 / Days: 1.
class QBreastfeedScreen extends StatefulWidget {
  const QBreastfeedScreen({super.key});

  @override
  State<QBreastfeedScreen> createState() => _QBreastfeedScreenState();
}

class _QBreastfeedScreenState extends State<QBreastfeedScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(
        value: 'immediately',
        label: 'Isla markiiba ( Immediately )',
        icon: Icons.flash_on_outlined),
    OptionItem(
        value: 'hours',
        label: 'Saacado gudahood ( Within hours )',
        icon: Icons.schedule_outlined),
    OptionItem(
        value: 'days',
        label: 'Maalmo kadib ( Days later )',
        icon: Icons.calendar_today_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.child(),
      somalTitle: 'Dhalashada Ka Dib Cunuga\nGoormee Ayaa Naaska La Siiyay?',
      englishTitle: '(How soon after birth was the child put to the breast?)',
      illustration: const Icon(
        Icons.child_care_outlined,
        color: Color(0xFF1976D2),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('breastfeed_start', _selected);
        final next = AssessmentData.getNextRoute('/q-breastfeed');
        Navigator.pushNamed(context, next);
      },
    );
  }
}
