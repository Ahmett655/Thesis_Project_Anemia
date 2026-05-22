import 'package:flutter/material.dart';
import '../../../models/assessment_data.dart';
import '../../../services/theme_service.dart';
import 'question_widget.dart' show QuestionTheme;
import 'form_question_layout.dart';

class QResidenceScreen extends StatefulWidget {
  const QResidenceScreen({super.key});

  @override
  State<QResidenceScreen> createState() => _QResidenceScreenState();
}

class _QResidenceScreenState extends State<QResidenceScreen> {
  final _gobolController = TextEditingController();
  final _degmoController = TextEditingController();
  final _tuuloController = TextEditingController();
  final _xaafadController = TextEditingController();

  @override
  void dispose() {
    _gobolController.dispose();
    _degmoController.dispose();
    _tuuloController.dispose();
    _xaafadController.dispose();
    super.dispose();
  }

  bool get _canProceed => _gobolController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = QuestionTheme.location();
    return FormQuestionLayout(
      theme: theme,
      illustration: const Icon(Icons.location_on_outlined,
          color: Color(0xFF00796B)),
      somalTitle: 'Xagee Ku Noolahay?',
      englishTitle: '(Where do you live?)',
      canProceed: _canProceed,
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('region', _gobolController.text.trim());
        AssessmentData.saveAnswer('district', _degmoController.text.trim());
        AssessmentData.saveAnswer('village', _tuuloController.text.trim());
        AssessmentData.saveAnswer(
            'neighborhood', _xaafadController.text.trim());
        final next = AssessmentData.getNextRoute('/q-residence');
        Navigator.pushNamed(context, next);
      },
      children: [
        _label('Gobolka (Region)'),
        _input(_gobolController, 'Tusaale: Banadir', Icons.map_outlined,
            theme.accentColor),
        const SizedBox(height: 14),
        _label('Degmada (District)'),
        _input(_degmoController, 'Tusaale: Hodan', Icons.business_outlined,
            theme.accentColor),
        const SizedBox(height: 14),
        _label('Tuulada (Village)'),
        _input(_tuuloController, 'Tusaale: Halgan', Icons.home_work_outlined,
            theme.accentColor),
        const SizedBox(height: 14),
        _label('Xaafada (Neighborhood)'),
        _input(_xaafadController, 'Tusaale: Howlwadaag',
            Icons.holiday_village_outlined, theme.accentColor),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      );

  Widget _input(TextEditingController c, String hint, IconData icon,
          Color color) =>
      TextField(
        controller: c,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: color, size: 20),
          filled: true,
          fillColor: context.inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
