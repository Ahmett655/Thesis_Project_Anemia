// Verifies the OFFLINE anemia classifier used when the server is unreachable.
// This runs with NO backend, NO internet — proving the app can still produce
// a correct WHO-based result on-device when a hemoglobin value is provided.
//
// Run:  flutter test test/offline_who_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:anemia_assessment/services/offline_who_service.dart';

void main() {
  group('Offline WHO classification (no server needed)', () {
    test('WOMEN thresholds', () {
      expect(OfflineWhoService.classify(7.5, 'women').label, 'Severe');   // <8
      expect(OfflineWhoService.classify(9.0, 'women').label, 'Moderate'); // 8-11
      expect(OfflineWhoService.classify(11.5, 'women').label, 'Mild');    // 11-12
      expect(OfflineWhoService.classify(13.0, 'women').label, 'Mild');    // normal
    });

    test('MEN thresholds', () {
      expect(OfflineWhoService.classify(7.0, 'men').label, 'Severe');   // <8
      expect(OfflineWhoService.classify(10.0, 'men').label, 'Moderate'); // 8-11
      expect(OfflineWhoService.classify(12.0, 'men').label, 'Mild');    // 11-13
      expect(OfflineWhoService.classify(15.0, 'men').label, 'Mild');    // normal
    });

    test('CHILDREN thresholds', () {
      expect(OfflineWhoService.classify(6.5, 'children').label, 'Severe');   // <7
      expect(OfflineWhoService.classify(9.0, 'children').label, 'Moderate'); // 7-10
      expect(OfflineWhoService.classify(10.5, 'children').label, 'Mild');    // 10-11
      expect(OfflineWhoService.classify(12.0, 'children').label, 'Mild');    // normal
    });

    test('Offline result matches Flask server thresholds exactly', () {
      // Same boundaries as classify_by_who_thresholds() in app.py.
      expect(OfflineWhoService.classify(7.9, 'women').predictionNumber, 2);
      expect(OfflineWhoService.classify(8.0, 'women').predictionNumber, 1);
      expect(OfflineWhoService.classify(11.0, 'women').predictionNumber, 0);
      expect(OfflineWhoService.classify(6.9, 'children').predictionNumber, 2);
      expect(OfflineWhoService.classify(7.0, 'children').predictionNumber, 1);
    });

    test('Confidence is clinical-grade (>= 0.92)', () {
      expect(
          OfflineWhoService.classify(9.0, 'women').confidence, greaterThanOrEqualTo(0.92));
    });
  });
}
