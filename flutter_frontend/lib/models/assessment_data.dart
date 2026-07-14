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
      // The marriage question comes FIRST; birth-history, first-birth-age
      // and husband questions are only asked when she answers "yes"
      // (religiously/culturally appropriate flow). The flow is re-evaluated
      // on every navigation, so it adapts as soon as 'married' is answered.
      final bool married = (answers['married'] ?? '') == 'yes';
      return [
        '/q-age-adults',
        '/q-residence',
        '/q-education',
        '/q-wealth',
        '/q-smoking',
        '/q-mosquito',
        '/q-married',
        if (married) '/q-birth-history',
        if (married) '/q-first-birth-age',
        if (married) '/q-husband',
        '/q-men-tired',   // Symptom: fatigue (asked to all categories)
        '/q-men-dizzy',   // Symptom: dizziness (asked to all categories)
        '/q-fever',       // Model feature: Had fever in last two weeks
        '/q-iron',        // Model feature: Taking iron pills/sprinkles/syrup
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
        // Fatigue and dizziness are already covered by the child-specific
        // questions below (child_tired / child_weak_dizzy), so the shared
        // /q-men-tired and /q-men-dizzy screens are NOT repeated here.
        '/q-child-weak',
        '/q-child-tired',
        '/q-child-pale',
        '/q-child-food',
        '/q-breastfeed',  // Model feature: When child put to breast (children only)
        '/q-fever',       // Model feature: Had fever in last two weeks
        '/q-iron',        // Model feature: Taking iron pills/sprinkles/syrup
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
        '/q-fever',       // Model feature: Had fever in last two weeks
        '/q-iron',        // Model feature: Taking iron pills/sprinkles/syrup
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

  /// 1-based progress of [route] within the current question flow
  /// ('/submit' excluded). Returns null when [route] is not part of it.
  static QuestionProgress? progressFor(String? route) {
    if (route == null || route.isEmpty) return null;
    final questions =
        getQuestionFlow().where((r) => r != '/submit').toList();
    final i = questions.indexOf(route);
    if (i < 0) return null;
    return QuestionProgress(i + 1, questions.length);
  }
}

/// Position of a question inside the active flow (e.g. 4 of 11).
class QuestionProgress {
  final int current;
  final int total;
  const QuestionProgress(this.current, this.total);
}