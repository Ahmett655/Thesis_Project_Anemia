import 'package:flutter/material.dart';
import '../models/assessment_data.dart';

/// Severity of a contributing factor.
enum FactorSeverity { high, medium, low }

/// A single human-readable factor that influenced the anemia risk result.
class RiskFactor {
  final String titleSo;
  final String titleEn;
  final FactorSeverity severity;
  final IconData icon;

  RiskFactor(this.titleSo, this.titleEn, this.severity, this.icon);

  Color get color => switch (severity) {
        FactorSeverity.high => const Color(0xFFE53935),
        FactorSeverity.medium => const Color(0xFFFFA726),
        FactorSeverity.low => const Color(0xFF26A69A),
      };

  String get severityLabel => switch (severity) {
        FactorSeverity.high => 'Saameyn sare',
        FactorSeverity.medium => 'Saameyn dhexe',
        FactorSeverity.low => 'Saameyn yar',
      };
}

/// Produces a transparent, rule-based explanation of which answers most
/// likely contributed to the user's anemia risk result. This complements
/// the ML model with a clinically-grounded factor breakdown.
class ExplainabilityService {
  static List<RiskFactor> topFactors({int max = 5}) {
    final a = AssessmentData.answers;
    final factors = <RiskFactor>[];

    String s(String k) => (a[k] ?? '').toString().toLowerCase().trim();

    // Hemoglobin (strongest clinical signal).
    if (s('has_hemoglobin_test') == 'yes') {
      final hb = double.tryParse(s('hemoglobin_value')) ?? 0;
      if (hb > 0 && hb < 8) {
        factors.add(RiskFactor('Hemoglobin aad u hooseeya ($hb g/dL)',
            'Very low hemoglobin', FactorSeverity.high, Icons.bloodtype));
      } else if (hb >= 8 && hb < 11) {
        factors.add(RiskFactor('Hemoglobin hooseeya ($hb g/dL)',
            'Low hemoglobin', FactorSeverity.high, Icons.bloodtype));
      } else if (hb >= 11 && hb < 12) {
        factors.add(RiskFactor('Hemoglobin xad-dhaaf hooseeya ($hb g/dL)',
            'Borderline hemoglobin', FactorSeverity.medium,
            Icons.bloodtype_outlined));
      }
    }

    // Symptoms.
    if (s('fatigue') == 'yes') {
      factors.add(RiskFactor('Daal joogto ah', 'Fatigue',
          FactorSeverity.high, Icons.battery_alert));
    }
    if (s('dizziness') == 'yes') {
      factors.add(RiskFactor('Dawakhaad', 'Dizziness', FactorSeverity.medium,
          Icons.blur_on));
    }
    if (s('child_weak_dizzy') == 'yes') {
      factors.add(RiskFactor('Daciifnimo / dawakhaad', 'Weakness',
          FactorSeverity.high, Icons.sentiment_dissatisfied));
    }
    if (s('child_tired') == 'yes') {
      factors.add(RiskFactor('Daal carruureed', 'Child fatigue',
          FactorSeverity.high, Icons.battery_alert));
    }
    if (s('child_pale') == 'yes') {
      factors.add(RiskFactor('Cabowga maqaarka/indhaha', 'Pale skin/eyes',
          FactorSeverity.high, Icons.face_retouching_off));
    }

    // Nutrition (child_good_food == 'no' means poor nutrition).
    if (s('child_good_food') == 'no') {
      factors.add(RiskFactor('Nafaqo xumo (cunto birta leh oo yar)',
          'Poor iron nutrition', FactorSeverity.high, Icons.no_meals));
    }

    // Frequent childbirth (women).
    final births = int.tryParse(s('births_last_5_years')) ?? 0;
    if (births >= 3) {
      factors.add(RiskFactor('Dhalmo badan (${births}x 5 sano gudahood)',
          'Frequent childbirth', FactorSeverity.high, Icons.pregnant_woman));
    } else if (births == 2) {
      factors.add(RiskFactor('Dhalmo soo noqnoqotay',
          'Repeated childbirth', FactorSeverity.medium, Icons.pregnant_woman));
    }

    // Socioeconomic / environmental.
    if (s('wealth') == 'poor') {
      factors.add(RiskFactor('Xaalad dhaqaale oo hooseysa',
          'Low income', FactorSeverity.medium, Icons.savings_outlined));
    }
    if (s('mosquito_net') == 'no') {
      factors.add(RiskFactor('Shabaq kaneeco la\'aan (khatar duumo)',
          'No mosquito net (malaria risk)', FactorSeverity.medium,
          Icons.bedroom_baby_outlined));
    }
    if (s('education') == 'no_education') {
      factors.add(RiskFactor('Waxbarasho la\'aan', 'No formal education',
          FactorSeverity.low, Icons.menu_book_outlined));
    }
    if (s('smoking') == 'yes') {
      factors.add(RiskFactor('Sigaar cabbid', 'Smoking', FactorSeverity.low,
          Icons.smoking_rooms));
    }
    if (s('age_group') == '1-6') {
      factors.add(RiskFactor('Da\'da yar ee canugga', 'Young child age',
          FactorSeverity.medium, Icons.child_care));
    }

    // Highest severity first.
    factors.sort((a, b) => a.severity.index.compareTo(b.severity.index));
    return factors.take(max).toList();
  }
}
