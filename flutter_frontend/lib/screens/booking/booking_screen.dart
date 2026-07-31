import 'package:flutter/material.dart';
import '../../models/assessment_data.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/health_facilities_service.dart';
import '../../services/booking_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_design.dart';
import '../../widgets/home_button.dart';
import 'booking_receipt_screen.dart';

/// Lets a user with a Moderate/Severe result book a (simulated) appointment
/// at a nearby hospital — pick hospital, date and time, then get a receipt.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loadingHospitals = true;
  String? _loadError;
  List<HealthFacility> _hospitals = [];
  HealthFacility? _selected;

  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final name = AuthService.currentUser?['name'] as String?;
    if (name != null && name.trim().isNotEmpty) _nameCtrl.text = name.trim();
    _loadHospitals();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _loadingHospitals = true;
      _loadError = null;
    });
    try {
      final loc = await LocationService.getCurrentLatLng();
      final list = await HealthFacilitiesService.nearby(
        lat: loc.lat,
        lon: loc.lon,
        radiusMeters: 8000,
      );
      // Prefer actual hospitals/clinics first.
      list.sort((a, b) {
        int rank(HealthFacility f) =>
            (f.type == 'hospital') ? 0 : (f.type == 'clinic' ? 1 : 2);
        final r = rank(a).compareTo(rank(b));
        return r != 0 ? r : a.distanceMeters.compareTo(b.distanceMeters);
      });
      if (!mounted) return;
      setState(() {
        _hospitals = list.take(15).toList();
        _selected = _hospitals.isNotEmpty ? _hospitals.first : null;
        _loadingHospitals = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loadingHospitals = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _selected != null &&
      _date != null &&
      _time != null &&
      !_submitting;

  String get _dateStr => _date == null
      ? ''
      : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';

  String get _timeStr =>
      _time == null ? '' : _time!.format(context);

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    final res = await BookingService.create(
      patientName: _nameCtrl.text.trim(),
      patientPhone: _phoneCtrl.text.trim(),
      hospitalName: _selected!.name,
      hospitalAddress: _selected!.distanceLabel + ' - ' + _selected!.type,
      hospitalPhone: _selected!.phone,
      hospitalLat: _selected!.lat,
      hospitalLon: _selected!.lon,
      appointmentDate: _dateStr,
      appointmentTime: _timeStr,
      category: AssessmentData.category,
      riskLabel: AssessmentData.predictionLabel,
      riskNumber: AssessmentData.predictionNumber,
      confidence: AssessmentData.confidence,
      hemoglobin: AssessmentData.hemoglobinValue,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.ok && res.booking != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingReceiptScreen(booking: res.booking!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Booking-ku ma guulaysan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                // Header
                Row(
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
                            color: context.textPrimary, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const HomeButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ballan Hospital',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppDesign.brandGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppDesign.glow(AppDesign.rose, opacity: 0.3),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          color: Colors.white, size: 34),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Dooro hospital kuu dhow, taariikh iyo waqti — waxaad '
                          'heli doontaa rasiid ballan.',
                          style: TextStyle(
                              color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Hospital selection
                _sectionLabel(context, 'Xarunta Caafimaad'),
                const SizedBox(height: 8),
                _buildHospitalPicker(context),
                const SizedBox(height: 18),

                // Patient info
                _sectionLabel(context, 'Magaca Bukaanka'),
                const SizedBox(height: 8),
                _textField(context, _nameCtrl, 'Magaca buuxa',
                    Icons.person_outline),
                const SizedBox(height: 12),
                _sectionLabel(context, 'Telefoon (ikhtiyaari)'),
                const SizedBox(height: 8),
                _textField(context, _phoneCtrl, 'Tusaale: 0612345678',
                    Icons.phone_outlined,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 18),

                // Date & time
                _sectionLabel(context, 'Taariikhda & Waqtiga'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _pickerTile(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: _date == null ? 'Dooro taariikh' : _dateStr,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pickerTile(
                        context,
                        icon: Icons.access_time,
                        label: _time == null ? 'Dooro waqti' : _timeStr,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit
                Pressable(
                  onTap: _canSubmit ? _submit : null,
                  child: Opacity(
                    opacity: _canSubmit ? 1 : 0.5,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppDesign.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow:
                            AppDesign.glow(AppDesign.rose, opacity: 0.3),
                      ),
                      child: Center(
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xaqiiji Ballanka',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalPicker(BuildContext context) {
    if (_loadingHospitals) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDeco(context),
        child: const Row(
          children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5)),
            SizedBox(width: 12),
            Expanded(child: Text('Waxaa la raadinayaa hospitalada kuu dhow...')),
          ],
        ),
      );
    }
    if (_loadError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_loadError!,
                style: const TextStyle(color: AppDesign.rose, fontSize: 13)),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _loadHospitals,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Isku day mar kale'),
            ),
          ],
        ),
      );
    }
    if (_hospitals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hospital kuu dhow lama helin.'),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _loadHospitals,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Isku day mar kale'),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: _cardDeco(context),
      child: Column(
        children: [
          for (int i = 0; i < _hospitals.length; i++)
            _hospitalTile(context, _hospitals[i], i == _hospitals.length - 1),
        ],
      ),
    );
  }

  Widget _hospitalTile(BuildContext context, HealthFacility h, bool last) {
    final selected = _selected == h;
    return InkWell(
      onTap: () => setState(() => _selected = h),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: context.borderSubtle)),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppDesign.rose : context.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    '${h.type} • ${h.distanceLabel}'
                    '${h.phone != null ? ' • ${h.phone}' : ''}',
                    style: TextStyle(fontSize: 12, color: context.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String t) => Text(
        t,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
        ),
      );

  Widget _textField(BuildContext context, TextEditingController c, String hint,
      IconData icon,
      {TextInputType? keyboard}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: context.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppDesign.rose, size: 20),
        filled: true,
        fillColor: context.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _pickerTile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: _cardDeco(context),
        child: Row(
          children: [
            Icon(icon, color: AppDesign.rose, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDeco(BuildContext context) => BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      );
}
