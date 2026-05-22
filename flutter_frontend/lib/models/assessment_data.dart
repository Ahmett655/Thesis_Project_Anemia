class AssessmentData {
  // Category: 'men', 'women', 'children'
  static String category = '';

  // All answers collected from questions
  static Map<String, dynamic> answers = {};

  // Result from API
  static int predictionNumber = 0;
  static String predictionLabel = '';
  static double confidence = 0.0;
  static String method = ''; // "WHO Clinical Thresholds" or "Machine Learning (Random Forest)"
  static double hemoglobinValue = 0.0; // 0 if user didn't provide

  // Reset everything
  static void reset() {
    category = '';
    answers = {};
    predictionNumber = 0;
    predictionLabel = '';
    confidence = 0.0;
    method = '';
    hemoglobinValue = 0.0;
  }

  // Save one answer
  static void saveAnswer(String key, dynamic value) {
    answers[key] = value;
  }

  // Get full payload for API
  static Map<String, dynamic> getPayload() {
    return {
      'category': category,
      ...answers,
    };
  }

  // Question flow for each category
  static List<String> getQuestionFlow() {
    if (category == 'women') {
      return [
        '/q-age-adults',
        '/q-residence',
        '/q-education',
        '/q-wealth',
        '/q-smoking',
        '/q-mosquito',
        '/q-birth-history',
        '/q-first-birth-age',
        '/q-married',
        '/q-husband',
        '/q-men-tired',   // Symptom: fatigue (asked to all categories)
        '/q-men-dizzy',   // Symptom: dizziness (asked to all categories)
        '/q-hemoglobin',
        '/submit',
      ];
    } else if (category == 'children') {
      return [
        '/q-age-child',
        '/q-residence',
        '/q-education',
        '/q-wealth',
        '/q-mosquito',
        '/q-child-weak',
        '/q-child-tired',
        '/q-child-pale',
        '/q-child-food',
        '/q-men-tired',   // Symptom: fatigue (asked to all categories)
        '/q-men-dizzy',   // Symptom: dizziness (asked to all categories)
        '/q-hemoglobin',
        '/submit',
      ];
    } else {
      // men
      return [
        '/q-age-adults',
        '/q-residence',
        '/q-education',
        '/q-wealth',
        '/q-smoking',
        '/q-mosquito',
        '/q-men-tired',
        '/q-men-dizzy',
        '/q-hemoglobin',
        '/submit',
      ];
    }
  }

  // Navigate to next question
  static String getNextRoute(String currentRoute) {
    final flow = getQuestionFlow();
    final index = flow.indexOf(currentRoute);
    if (index >= 0 && index < flow.length - 1) {
      return flow[index + 1];
    }
    return '/submit';
  }
}