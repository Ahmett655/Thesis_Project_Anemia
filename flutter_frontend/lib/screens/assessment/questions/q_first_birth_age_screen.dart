import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/assessment_data.dart';
import '../../../services/theme_service.dart';
import 'question_widget.dart' show QuestionTheme;
import 'form_question_layout.dart';

class QFirstBirthAgeScreen extends StatefulWidget {
  const QFirstBirthAgeScreen({super.key});

  @override
  State<QFirstBirthAgeScreen> createState() => _QFirstBirthAgeScreenState();
}

class _QFirstBirthAgeScreenState extends State<QFirstBirthAgeScreen> {
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  // Biologically plausible age for a woman's FIRST birth: 15 (youngest
  // realistic) to 50 (around menopause; training data max was 48).
  static const int _minAge = 15;
  static const int _maxAge = 50;

  /// Error text shown under the input while the value is invalid.
  String? get _ageError {
    final txt = _ageController.text.trim();
    if (txt.isEmpty) return null;
    final v = int.tryParse(txt);
    if (v == null) return 'Fadlan geli nambar sax ah (tusaale: 18).';
    if (v < _minAge || v > _maxAge) {
      return 'Da\'du waa inay u dhexeysaa $_minAge – $_maxAge sano. '
          'Hubi oo sax da\'da.';
    }
    return null;
  }

  bool get _canProceed {
    final v = int.tryParse(_ageController.text.trim());
    return v != null && v >= _minAge && v <= _maxAge;
  }

  @override
  Widget build(BuildContext context) {
    final theme = QuestionTheme.maternal();
    return FormQuestionLayout(
      theme: theme,
      illustration: const Icon(Icons.cake_outlined,
          color: Color(0xFFC2185B)),
      somalTitle: 'Meeqo Sano Ayaad Jirtay\nUmushaadii Ugu Horeesay?',
      englishTitle:
          '(How old were you when you first gave birth?)',
      canProceed: _canProceed,
      onBack: () => Navigator.pop(context),
      onNext: () {
        AssessmentData.saveAnswer('first_birth_age', _ageController.text.trim());
        final next = AssessmentData.getNextRoute('/q-first-birth-age');
        Navigator.pushNamed(context, next);
      },
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Geli da\'da (Enter age in years):',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Tusaale: 18',
            errorText: _ageError,
            errorMaxLines: 3,
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            hintStyle: TextStyle(color: context.textMuted, fontSize: 14),
            prefixIcon: Icon(Icons.calendar_today_outlined,
                color: theme.accentColor, size: 20),
            suffixText: 'sano',
            suffixStyle: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
            filled: true,
            fillColor: context.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.accentColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: theme.accentColor.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 18, color: theme.accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Da\'du waxay u dhexeysaa $_minAge ilaa $_maxAge sano.',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF455A64),
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
