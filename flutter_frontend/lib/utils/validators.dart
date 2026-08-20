/// Shared input validation used by the auth screens.
class Validators {
  Validators._();

  // Local part, @, domain, and at least one dot-separated TLD.
  // Deliberately permissive — it rejects obvious mistakes (missing @, missing
  // domain, spaces) without blocking valid but unusual addresses.
  static final RegExp _emailRe = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static bool isValidEmail(String email) =>
      _emailRe.hasMatch(email.trim().toLowerCase());

  /// Bilingual error message, or null when the email is acceptable.
  static String? emailError(String email) {
    final e = email.trim();
    if (e.isEmpty) return 'Email-kaaga geli (Enter your email)';
    if (!isValidEmail(e)) {
      return 'Email-ku sax maaha. Tusaale: magac@gmail.com\n'
          '(Invalid email address)';
    }
    return null;
  }
}
