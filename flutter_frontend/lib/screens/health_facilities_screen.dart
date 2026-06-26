import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../services/health_facilities_service.dart';
import '../services/theme_service.dart';
import '../widgets/home_button.dart';

/// Shows nearby hospitals/clinics/pharmacies on an OpenStreetMap map plus
/// a distance-sorted list. Uses the device GPS + free Overpass API.
class HealthFacilitiesScreen extends StatefulWidget {
  const HealthFacilitiesScreen({super.key});

  @override
  State<HealthFacilitiesScreen> createState() =>
      _HealthFacilitiesScreenState();
}

class _HealthFacilitiesScreenState extends State<HealthFacilitiesScreen> {
  final MapController _map = MapController();
  bool _loading = true;
  String? _error;
  LatLng? _me;
  List<HealthFacility> _facilities = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loc = await LocationService.getCurrentLatLng();
      final me = LatLng(loc.lat, loc.lon);
      final facilities =
          await HealthFacilitiesService.nearby(lat: loc.lat, lon: loc.lon);
      if (!mounted) return;
      setState(() {
        _me = me;
        _facilities = facilities;
        _loading = false;
      });
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Wax khalad ah ayaa dhacay. Isku day mar kale.';
      });
    }
  }

  Color _typeColor(String type) => switch (type) {
        'hospital' => const Color(0xFFE53935),
        'clinic' => const Color(0xFF1565C0),
        'pharmacy' => const Color(0xFF2E7D32),
        'doctors' => const Color(0xFF6A1B9A),
        _ => const Color(0xFF00838F),
      };

  IconData _typeIcon(String type) => switch (type) {
        'hospital' => Icons.local_hospital,
        'clinic' => Icons.medical_services,
        'pharmacy' => Icons.local_pharmacy,
        'doctors' => Icons.person,
        _ => Icons.health_and_safety,
      };

  Future<void> _directions(HealthFacility f) async {
    // Opens the location in the device's map app / browser.
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${f.lat},${f.lon}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _focus(HealthFacility f) {
    _map.move(LatLng(f.lat, f.lon), 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderSubtle),
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const HomeButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xarumaha Caafimaad',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              'Nearby health facilities',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: context.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _load,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderSubtle),
                          ),
                          child: Icon(Icons.refresh,
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _body(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 48, color: context.textMuted),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Isku day mar kale'),
              ),
            ],
          ),
        ),
      );
    }

    final me = _me!;
    return Column(
      children: [
        // Map
        SizedBox(
          height: 260,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: me,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.anemia.assessment',
                ),
                MarkerLayer(
                  markers: [
                    // Me
                    Marker(
                      point: me,
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.my_location,
                          color: Color(0xFF1565C0), size: 30),
                    ),
                    // Facilities
                    ..._facilities.take(40).map(
                          (f) => Marker(
                            point: LatLng(f.lat, f.lon),
                            width: 36,
                            height: 36,
                            child: Icon(_typeIcon(f.type),
                                color: _typeColor(f.type), size: 28),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _facilities.isEmpty
                  ? 'Wax xarun ah lama helin agagaarka'
                  : '${_facilities.length} xarun oo kuu dhow',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _facilities.length,
            itemBuilder: (_, i) => _tile(context, _facilities[i]),
          ),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, HealthFacility f) {
    final color = _typeColor(f.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _focus(f),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_typeIcon(f.type), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${f.type[0].toUpperCase()}${f.type.substring(1)} · ${f.distanceLabel}',
                        style: TextStyle(
                            fontSize: 11, color: context.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _directions(f),
                  icon: Icon(Icons.directions, color: color),
                  tooltip: 'Directions',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
