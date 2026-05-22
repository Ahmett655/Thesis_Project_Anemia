import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import 'question_widget.dart';

class QEducationScreen extends StatefulWidget {
  const QEducationScreen({super.key});

  @override
  State<QEducationScreen> createState() => _QEducationScreenState();
}

class _QEducationScreenState extends State<QEducationScreen> {
  String _selected = '';

  final List<OptionItem> _options = const [
    OptionItem(value: 'no_education', label: 'Waxbarasho ma lihi', icon: Icons.do_disturb_alt_outlined),
    OptionItem(value: 'primary',      label: 'Dugsi hoose',         icon: Icons.menu_book_outlined),
    OptionItem(value: 'middle',       label: 'Dugsi Dhexe',         icon: Icons.book_outlined),
    OptionItem(value: 'secondary',    label: 'Dugsi sare',          icon: Icons.school_outlined),
    OptionItem(value: 'university',   label: 'Jaamacad',            icon: Icons.workspace_premium_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionWidget(
      theme: QuestionTheme.education(),
      somalTitle: 'Heerka waxbarashadaadu\nwaa kee?',
      englishTitle: '(What is your level of education?)',
      illustration: const Icon(
        Icons.school_outlined,
        color: Color(0xFF5E35B1),
      ),
      options: _options,
      selected: _selected,
      onSelect: (val) => setState(() => _selected = val),
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('education', _selected);
        final next = AssessmentData.getNextRoute('/q-education');
        Navigator.pushNamed(context, next);
      },
    );
  }
}