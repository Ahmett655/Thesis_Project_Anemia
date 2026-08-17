import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/assessment_data.dart';
import '../../../services/theme_service.dart';
import 'question_widget.dart' show QuestionTheme;
import 'form_question_layout.dart';

class QHemoglobinScreen extends StatefulWidget {
  const QHemoglobinScreen({super.key});

  @override
  State<QHemoglobinScreen> createState() => _QHemoglobinScreenState();
}

class _QHemoglobinScreenState extends State<QHemoglobinScreen> {
  final _hbController = TextEditingController();
  String _hasTest = ''; // 'yes' / 'no'

  @override
  void dispose() {
    _hbController.dispose();
    super.dispose();
  }

  void _selectOption(String value) {
    setState(() => _hasTest = value);
  }

  // Clinically plausible hemoglobin range that may be ENTERED, per category.
  // Values outside this range are almost certainly typing mistakes.
  double get _minHb => 3.0;

  double get _maxHb {
    switch (AssessmentData.category) {
      case 'men':
        return 20.0;
      case 'women':
        return 18.0;
      case 'children':
        return 17.0;
      default:
        return 20.0;
    }
  }

  bool get _isChild => AssessmentData.category == 'children';

  String get _categoryName {
    switch (AssessmentData.category) {
      case 'men':
        return 'ragga';
      case 'women':
        return 'haweenka';
      case 'children':
        return 'carruurta';
      default:
        return '';
    }
  }

  /// Error text shown under the input while the value is invalid.
  String? get _hbError {
    final txt = _hbController.text.trim();
    if (txt.isEmpty) return null;
    final v = double.tryParse(txt);
    if (v == null) {
      return 'Fadlan geli nambar sax ah (tusaale: 12.5).';
    }
    if (v < _minHb || v > _maxHb) {
      return 'Qiimaha hemoglobin ee ${_categoryName.isEmpty ? 'la aqbali karo' : _categoryName} '
          'waa inuu u dhexeeyaa ${_minHb.toStringAsFixed(0)} – ${_maxHb.toStringAsFixed(0)} g/dL. '
          'Hubi baadhitaankaaga oo sax qiimaha.';
    }
    return null;
  }

  bool get _canProceed {
    if (_hasTest == 'no') return true;
    if (_hasTest == 'yes') {
      final v = double.tryParse(_hbController.text.trim());
      return v != null && v >= _minHb && v <= _maxHb;
    }
    return false;
  }

  void _onNext() {
    AssessmentData.saveAnswer('has_hemoglobin_test', _hasTest);
    if (_hasTest == 'yes') {
      AssessmentData.saveAnswer(
          'hemoglobin_value', _hbController.text.trim());
    } else {
      AssessmentData.saveAnswer('hemoglobin_value', '');
    }
    final next = AssessmentData.getNextRoute('/q-hemoglobin');
    Navigator.pushNamed(context, next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = const QuestionTheme(
      gradientColors: [Color(0xFFE53935), Color(0xFFB71C1C)],
      accentColor: Color(0xFFE53935),
      badgeIcon: Icons.bloodtype,
      badgeLabel: 'LAB RESULT',
    );

    return FormQuestionLayout(
      theme: theme,
      illustration:
          const Icon(Icons.bloodtype, color: Color(0xFFE53935)),
      somalTitle: _isChild
          ? 'Cunuga Baari Taan Dhiig\nMiyaa Loo Sameeyay?'
          : 'Baari Taan Dhiig\nMiyaad Sameesay?',
      englishTitle: '(Have you had a recent hemoglobin test?)',
      canProceed: _canProceed,
      onBack: () => Navigator.pop(context),
      onNext: _onNext,
      children: [
        // Yes / No row
        Row(
          children: [
            Expanded(
              child: _OptionButton(
                label: 'Haa',
                english: '(Yes)',
                color: theme.accentColor,
                selected: _hasTest == 'yes',
                onTap: () => _selectOption('yes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OptionButton(
                label: 'Maya',
                english: '(No)',
                color: theme.accentColor,
                selected: _hasTest == 'no',
                onTap: () => _selectOption('no'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Hemoglobin value input (shown only if "Yes")
        if (_hasTest == 'yes') ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              'Geli qiimaha hemoglobin (g/dL):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ),
          TextField(
            controller: _hbController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              // Digits and decimal point only; length-capped (e.g. 12.5).
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Tusaale: 12.5',
              errorText: _hbError,
              errorMaxLines: 3,
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              hintStyle:
                  TextStyle(color: context.textMuted, fontSize: 14),
              prefixIcon: Icon(Icons.opacity,
                  color: theme.accentColor, size: 20),
              suffixText: 'g/dL',
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFFFD54F).withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: Color(0xFFFF8F00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Xadka la geli karo (${_categoryName.isEmpty ? 'guud' : _categoryName}): '
                    '${_minHb.toStringAsFixed(0)} – ${_maxHb.toStringAsFixed(0)} g/dL.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C5800),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_hasTest == 'no')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: Color(0xFF1565C0)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hagaag — Qiimeyntu waxay ku salaysnaan doontaa jawaabahaaga kale oo keliya.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D47A1),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final String english;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.english,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? color : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selected ? Colors.white : color,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  english,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected
                        ? Colors.white.withOpacity(0.85)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
