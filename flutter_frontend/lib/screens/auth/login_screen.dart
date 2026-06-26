import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/top_message_banner.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/google_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      TopMessageBanner.warning(
        context,
        'Email iyo password buuxi (Fill in email and password)',
      );
      return;
    }

    setState(() => _loading = true);
    final result = await AuthService.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.ok) {
      TopMessageBanner.success(
        context,
        'Welcome back!',
        title: 'Soo Dhowow!',
      );
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
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
                // ============ Header gradient ============
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
                          const SizedBox(height: 18),
                          Container(
                            width: 90,
                            height: 90,
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
                                    Icons.lock_outline,
                                    size: 40,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Welcome Back!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to continue',
                            textAlign: TextAlign.center,
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

                const SizedBox(height: 28),

                // ============ Form body ============
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, 'Email'),
                      _input(
                        controller: _emailController,
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 14),
                      _label(context, 'Password'),
                      _passwordInput(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/forgot-password'),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _onLogin,
                          icon: _loading
                              ? const SizedBox.shrink()
                              : const Icon(Icons.login,
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
                                  'Login',
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
                      const SizedBox(height: 20),
                      // Divider
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
                      const SizedBox(height: 16),
                      // Working Google sign-in (web renders Google's button;
                      // mobile shows a Continue with Google button).
                      GoogleSignInButton(
                        onSuccess: () {
                          TopMessageBanner.success(
                            context,
                            'Welcome!',
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
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, '/register'),
                              child: const Text(
                                'Register Now',
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 24),
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

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
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
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _passwordInput() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: 'Enter your password',
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: context.textMuted,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
    );
  }

}
