import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

/// Finds nearby health facilities (hospitals, clinics, pharmacies, doctors)
/// using the free OpenStreetMap Overpass API — no API key required.
class HealthFacilitiesService {
  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  /// Search within [radiusMeters] of (lat, lon). Returns facilities sorted
  /// by distance (nearest first).
  static Future<List<HealthFacility>> nearby({
    required double lat,
    required double lon,
    int radiusMeters = 5000,
  }) async {
    // Overpass QL: hospitals, clinics, doctors, pharmacies near the point.
    final query = '''
[out:json][timeout:25];
(
  node["amenity"~"hospital|clinic|doctors|pharmacy"](around:$radiusMeters,$lat,$lon);
  way["amenity"~"hospital|clinic|doctors|pharmacy"](around:$radiusMeters,$lat,$lon);
);
out center 40;
''';

    try {
      final res = await http
          .post(Uri.parse(_endpoint), body: {'data': query})
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) {
        debugPrint('[Facilities] status ${res.statusCode}');
        return [];
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List?) ?? [];
      final list = <HealthFacility>[];
      for (final e in elements) {
        final el = e as Map<String, dynamic>;
        final tags = (el['tags'] ?? {}) as Map<String, dynamic>;
        final flat = (el['lat'] ?? el['center']?['lat']) as num?;
        final flon = (el['lon'] ?? el['center']?['lon']) as num?;
        if (flat == null || flon == null) continue;
        final name = (tags['name'] ??
                tags['name:en'] ??
                _amenityLabel(tags['amenity'])) as String;
        list.add(HealthFacility(
          name: name,
          type: (tags['amenity'] ?? 'health') as String,
          lat: flat.toDouble(),
          lon: flon.toDouble(),
          phone: (tags['phone'] ?? tags['contact:phone']) as String?,
          distanceMeters: _haversine(lat, lon, flat.toDouble(), flon.toDouble()),
        ));
      }
      list.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return list;
    } catch (e) {
      debugPrint('[Facilities] error: $e');
      return [];
    }
  }

  static String _amenityLabel(dynamic amenity) {
    switch (amenity) {
      case 'hospital':
        return 'Hospital';
      case 'clinic':
        return 'Clinic';
      case 'pharmacy':
        return 'Pharmacy';
      case 'doctors':
        return 'Doctor';
      default:
        return 'Health facility';
    }
  }

  static double _haversine(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // metres
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
}

class HealthFacility {
  final String name;
  final String type;
  final double lat;
  final double lon;
  final String? phone;
  final double distanceMeters;

  HealthFacility({
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    this.phone,
    required this.distanceMeters,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}
