import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/top_message_banner.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/google_signin_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final firstName = _firstNameController.text.trim();
    final secondName = _secondNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (firstName.isEmpty || email.isEmpty || password.isEmpty) {
      TopMessageBanner.warning(context,
          'Magaca, email iyo password buuxi (Name, email & password required)');
      return;
    }
    if (password != confirm) {
      TopMessageBanner.warning(
          context, 'Passwords-ku ma isku mid aha (Passwords do not match)');
      return;
    }
    if (password.length < 6) {
      TopMessageBanner.warning(context,
          'Password waa inuu yahay 6+ xaraf (Password must be 6+ chars)');
      return;
    }

    final fullName = [firstName, secondName, lastName]
        .where((s) => s.isNotEmpty)
        .join(' ');

    setState(() => _loading = true);
    final result = await AuthService.register(
      name: fullName,
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.ok) {
      TopMessageBanner.success(
        context,
        'Akoonkaagu waa la sameeyay! Hadda gal.',
        title: 'Guul!',
      );
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      TopMessageBanner.error(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.30),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AppBackButton(
                                onDarkBg: true,
                                onTap: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              const ThemeToggleButton(onDarkBg: true),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.20),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_add_alt_1,
                                    size: 34,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Samee Akoon Cusub',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, 'First Name'),
                      _input(_firstNameController, 'Frist Name',
                          Icons.person_outline),
                      const SizedBox(height: 12),
                      _label(context, 'Second Name'),
                      _input(_secondNameController, 'Second Name',
                          Icons.person_outline),
                      const SizedBox(height: 12),
                      _label(context, 'Last Name'),
                      _input(_lastNameController, 'Last Name',
                          Icons.person_outline),
                      const SizedBox(height: 12),
                      _label(context, 'Email'),
                      _input(_emailController, 'Email',
                          Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _label(context, 'Password'),
                      _passwordField(
                        controller: _passwordController,
                        hint: 'Password',
                        obscure: _obscurePassword,
                        onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 12),
                      _label(context, 'Confirm Password'),
                      _passwordField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm password',
                        obscure: _obscureConfirm,
                        onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _onRegister,
                          icon: _loading
                              ? const SizedBox.shrink()
                              : const Icon(Icons.person_add_alt_1,
                                  color: Colors.white, size: 20),
                          label: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Agree and Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            disabledBackgroundColor:
                                Colors.grey.shade400,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: context.borderSubtle)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            child: Text(
                              'Or Login with',
                              style: TextStyle(
                                color: context.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: context.borderSubtle)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Working Google sign-up (web renders Google's button).
                      GoogleSignInButton(
                        onSuccess: () {
                          TopMessageBanner.success(
                            context,
                            'Account ready!',
                            title: 'Soo Dhowow!',
                          );
                          Future.delayed(
                              const Duration(milliseconds: 700), () {
                            if (mounted) {
                              Navigator.pushReplacementNamed(
                                  context, '/home');
                            }
                          });
                        },
                        onError: (msg) =>
                            TopMessageBanner.error(context, msg),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/start-assessment'),
                          child: const Text(
                            'Continue as a guest',
                            style: TextStyle(
                              color: Color(0xFF00ACC1),
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
      );

  Widget _input(TextEditingController c, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFE53935), size: 20),
        filled: true,
        fillColor: context.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFE53935), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline,
            color: Color(0xFFE53935), size: 20),
        filled: true,
        fillColor: context.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFE53935), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: context.textMuted,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

}
