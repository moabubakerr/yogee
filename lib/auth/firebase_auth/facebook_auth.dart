import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;

/// Facebook Login is TEMPORARILY DISABLED (2026-11-08).
///
/// Why: the `flutter_facebook_auth` plugin pulls the Facebook iOS SDK as a zip
/// from GitHub release downloads, which were returning 504 and failing every
/// Codemagic iOS build at `pod install`. Facebook Login was not configured yet
/// anyway (no facebook_app_id / client token -- see commit 287f5ef), so the
/// button could not have worked.
///
/// To restore:
///   1. Re-add `flutter_facebook_auth: 7.2.0` to pubspec.yaml.
///   2. Restore the full implementation of this file:
///        git show 1dd81a9:lib/auth/firebase_auth/facebook_auth.dart
///   3. Set [kFacebookLoginEnabled] back to true (shows the login/sign-up
///      buttons again).
///   4. Add facebook_app_id / facebook_client_token to Info.plist and
///      strings.xml.
///
/// The function names below are kept so FirebaseAuthManager compiles
/// unchanged.
const bool kFacebookLoginEnabled = false;

Future<UserCredential?> facebookSignInFunc() async {
  throw PlatformException(
    code: 'facebook_login_timeout',
    message: 'Facebook Login is disabled in this build.',
  );
}

Future signOutWithFacebook() async {}
