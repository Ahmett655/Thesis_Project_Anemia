/// Local (offline) WHO anemia classification.
///
/// Mirror of `classify_by_who_thresholds` in the Flask API (app.py): when the
/// server cannot be reached but the user provided a hemoglobin measurement,
/// the app can still give the clinically-correct WHO result on-device.
class OfflineWhoResult {
  final int predictionNumber; // 0=Mild/Low, 1=Moderate, 2=Severe
  final String label;
  final double confidence; // 0..1

  const OfflineWhoResult(this.predictionNumber, this.label, this.confidence);
}

class OfflineWhoService {
  OfflineWhoService._();

  static OfflineWhoResult classify(double hb, String category) {
    final cat = category.toLowerCase();

    if (cat == 'children') {
      // WHO for children 6-59 months
      if (hb < 7.0) return const OfflineWhoResult(2, 'Severe', 0.98);
      if (hb < 10.0) return const OfflineWhoResult(1, 'Moderate', 0.95);
      if (hb < 11.0) return const OfflineWhoResult(0, 'Mild', 0.92);
      return const OfflineWhoResult(0, 'Mild', 0.95);
    }

    if (cat == 'men') {
      // WHO for adult men (15+)
      if (hb < 8.0) return const OfflineWhoResult(2, 'Severe', 0.98);
      if (hb < 11.0) return const OfflineWhoResult(1, 'Moderate', 0.95);
      if (hb < 13.0) return const OfflineWhoResult(0, 'Mild', 0.92);
      return const OfflineWhoResult(0, 'Mild', 0.95);
    }

    // Women (default) — non-pregnant women 15+
    if (hb < 8.0) return const OfflineWhoResult(2, 'Severe', 0.98);
    if (hb < 11.0) return const OfflineWhoResult(1, 'Moderate', 0.95);
    if (hb < 12.0) return const OfflineWhoResult(0, 'Mild', 0.92);
    return const OfflineWhoResult(0, 'Mild', 0.95);
  }
}
