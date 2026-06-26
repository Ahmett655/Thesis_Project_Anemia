import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Shared GoogleSignIn instance.
///
/// Web uses the OAuth Web Client ID (clientId). Mobile passes it as
/// serverClientId so the backend can verify the resulting ID token.
class GoogleAuthService {
  static const String webClientId =
      '455968430035-8faqf78i2ibkvk02t6o09l9r236lcbrc.apps.googleusercontent.com';

  static final GoogleSignIn instance = GoogleSignIn(
    clientId: kIsWeb ? webClientId : null,
    serverClientId: kIsWeb ? null : webClientId,
    scopes: const ['email', 'profile'],
  );
}
