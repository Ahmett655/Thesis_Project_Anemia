import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/payment_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/home_button.dart';

/// Collects the payer's mobile-money number and charges the assessment
/// fee via WaafiPay (EVC Plus). On success, continues to the result.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final phone = _phoneController.text.trim();
    if (phone.replaceAll(RegExp(r'[^0-9]'), '').length < 7) {
      setState(() => _error = 'Fadlan geli lambar sax ah (tusaale: 61xxxxxxx)');
      return;
    }
    setState(() {
      _processing = true;
      _error = null;
    });

    final result = await PaymentService.charge(accountNo: phone);
    if (!mounted) return;

    if (result.ok) {
      // Payment approved -> continue to loading -> result.
      Navigator.pushReplacementNamed(context, '/loading');
    } else {
      setState(() {
        _processing = false;
        _error = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E7D32);
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Gradient header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _processing
                                  ? null
                                  : () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.4)),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const HomeButton(onDarkBg: true),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet,
                              size: 42, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Lacag Bixin',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  child: Column(
                    children: [
                      // Fee card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: green.withOpacity(0.25)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Qiimaha Natiijada',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '\$0.10',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: green,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'USD · EVC Plus / Mobile Money',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Lambarka EVC Plus',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_processing,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+]')),
                        ],
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tusaale: 615123456',
                          hintStyle:
                              TextStyle(color: context.textMuted),
                          prefixIcon: const Icon(Icons.phone_android,
                              color: green),
                          filled: true,
                          fillColor: context.inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: green, width: 1.5),
                          ),
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFE53935)
                                    .withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFE53935), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFFFD54F)
                                  .withOpacity(0.5)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: Color(0xFFFF8F00)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Markaad gujiso "Bixi", waxaa telefoonkaaga ku soo degi doona codsi (push) si aad u ansixiso lacag bixinta.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7C5800),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _processing ? null : _pay,
                          icon: _processing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Icon(Icons.lock, color: Colors.white),
                          label: Text(
                            _processing
                                ? 'Sugaya ansixinta...'
                                : 'Bixi \$0.10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
