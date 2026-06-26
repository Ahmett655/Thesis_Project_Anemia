import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import 'google_web_button_stub.dart'
    if (dart.library.html) 'google_web_button_web.dart';

/// "Continue with Google" button.
///
/// - Web: shows Google's officially rendered button (required by the
///   Google Identity Services SDK).
/// - Mobile: a styled button that triggers the native sign-in sheet.
///
/// On success it exchanges the Google ID token for our JWT via
/// [AuthService.googleSignInWithToken] and calls [onSuccess].
class GoogleSignInButton extends StatefulWidget {
  final VoidCallback onSuccess;
  final void Function(String message) onError;

  const GoogleSignInButton({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  StreamSubscription<GoogleSignInAccount?>? _sub;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // React to sign-ins (the web rendered button reports here too).
    _sub = GoogleAuthService.instance.onCurrentUserChanged
        .listen(_handleAccount);
    if (kIsWeb) {
      // Try a silent sign-in to restore a previous session on web.
      GoogleAuthService.instance.signInSilently();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _handleAccount(GoogleSignInAccount? account) async {
    if (account == null || _busy) return;
    setState(() => _busy = true);
    try {
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        widget.onError('Google token lama helin. Isku day mar kale.');
        return;
      }
      final result = await AuthService.googleSignInWithToken(idToken);
      if (!mounted) return;
      if (result.ok) {
        widget.onSuccess();
      } else {
        widget.onError(result.message ?? 'Google sign-in failed');
      }
    } catch (e) {
      widget.onError('Google sign-in error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInMobile() async {
    setState(() => _busy = true);
    try {
      final account = await GoogleAuthService.instance.signIn();
      if (account == null) {
        // User cancelled.
        if (mounted) setState(() => _busy = false);
      }
      // Success path handled by onCurrentUserChanged.
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        widget.onError('Google sign-in error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const SizedBox(
        height: 52,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (kIsWeb) {
      // Google's own rendered button.
      return SizedBox(
        height: 44,
        child: Align(
          alignment: Alignment.center,
          child: googleWebRenderButton(),
        ),
      );
    }

    // Mobile styled button.
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _signInMobile,
        icon: const Icon(Icons.g_mobiledata,
            color: Color(0xFFEA4335), size: 28),
        label: const Text(
          'Continue with Google',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
