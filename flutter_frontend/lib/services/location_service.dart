import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Detects the device's current location and reverse-geocodes it into
/// address parts (region/district/village/neighborhood) so the residence
/// form can be auto-filled.
///
/// Reverse geocoding uses OpenStreetMap Nominatim over HTTP, which works
/// on BOTH web and mobile (the native `geocoding` plugin does not work on
/// Flutter web).
class LocationService {
  /// Returns just the current coordinates (lat, lon). Throws
  /// [LocationException] on failure.
  static Future<({double lat, double lon})> getCurrentLatLng() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationException(
          'Location-ka waa la xidhay. Fadlan fur GPS-ka / location-ka.');
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw LocationException('Ogolaanshaha location waa la diiday.');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 25),
      ),
    );
    return (lat: pos.latitude, lon: pos.longitude);
  }

  static Future<AddressParts> getCurrentAddress() async {
    // 1) Location services enabled?
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationException(
          'Location-ka waa la xidhay. Fadlan fur GPS-ka / location-ka.');
    }

    // 2) Permission.
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw LocationException('Ogolaanshaha location waa la diiday.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw LocationException(
          'Location waa la diiday. Ka ogolow browser-ka/Settings-ka.');
    }

    // 3) Current position.
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 25),
      ),
    );

    // 4) Reverse-geocode via Nominatim (works on web + mobile).
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2'
          '&lat=${pos.latitude}&lon=${pos.longitude}'
          '&zoom=18&addressdetails=1&accept-language=so,en');
      final res = await http.get(uri, headers: {
        // Nominatim asks for an identifying User-Agent.
        'User-Agent': 'AnemiaRiskAssessment/1.0',
      }).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = (data['address'] ?? {}) as Map<String, dynamic>;
        String pick(List<String> keys) {
          for (final k in keys) {
            final v = addr[k];
            if (v != null && v.toString().trim().isNotEmpty) {
              return v.toString().trim();
            }
          }
          return '';
        }

        return AddressParts(
          region: pick(['state', 'region', 'province']),
          district: pick(
              ['county', 'state_district', 'city_district', 'municipality']),
          village: pick(['city', 'town', 'village', 'hamlet']),
          neighborhood: pick(['suburb', 'neighbourhood', 'quarter', 'road']),
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      }
      debugPrint('[Location] Nominatim status ${res.statusCode}');
    } catch (e) {
      debugPrint('[Location] reverse geocode failed: $e');
    }

    // Fallback: still return coordinates so nothing is lost.
    return AddressParts(
      region: '',
      district: '',
      village: '',
      neighborhood: '',
      latitude: pos.latitude,
      longitude: pos.longitude,
    );
  }
}

class AddressParts {
  final String region;
  final String district;
  final String village;
  final String neighborhood;
  final double latitude;
  final double longitude;

  AddressParts({
    required this.region,
    required this.district,
    required this.village,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
  });

  bool get hasAnyText =>
      region.isNotEmpty ||
      district.isNotEmpty ||
      village.isNotEmpty ||
      neighborhood.isNotEmpty;
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => message;
}
