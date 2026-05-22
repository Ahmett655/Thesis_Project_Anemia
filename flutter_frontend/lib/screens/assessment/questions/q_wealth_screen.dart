import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QWealthScreen extends StatefulWidget {
  const QWealthScreen({super.key});

  @override
  State<QWealthScreen> createState() => _QWealthScreenState();
}

class _QWealthScreenState extends State<QWealthScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(
        value: 'poor',
        label: 'Danyar (Poor)',
        icon: Icons.money_off_outlined),
    OptionItem(
        value: 'moderate',
        label: 'Dhexdhexaad (Moderate)',
        icon: Icons.attach_money_outlined),
    OptionItem(
        value: 'good',
        label: 'Fiican (Good)',
        icon: Icons.savings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.wealth(),
      somalTitle: 'Xaaladdaada dhaqaale\nsidee tahay?',
      englishTitle: '(What is your financial situation?)',
      illustration: const Icon(
        Icons.account_balance_wallet_outlined,
        color: Color(0xFFFF8F00),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('wealth', _selected);
        final next = AssessmentData.getNextRoute('/q-wealth');
        Navigator.pushNamed(context, next);
      },
    );
  }
}