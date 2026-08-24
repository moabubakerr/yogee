import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Facebook Login, shaped to match `google_auth.dart` so both providers behave
/// the same way at the call site: return a `UserCredential` on success, `null`
/// when the user backs out, and throw on anything genuinely wrong.
///
/// The null return matters. `_signInOrCreateAccount` treats it as "cancelled"
/// and shows no error, which is the correct outcome for someone who dismissed
/// the Facebook sheet on purpose.
Future<UserCredential?> facebookSignInFunc() async {
  if (kIsWeb) {
    // Same shape as google_auth: on web, firebase_auth drives the whole flow
    // in a popup and no plugin is involved.
    return await FirebaseAuth.instance.signInWithPopup(FacebookAuthProvider());
  }

  // Clear any cached Facebook session first, exactly as googleSignInFunc calls
  // signOutWithGoogle(). Without it the SDK silently reuses the last account
  // and a user who wants to switch has no way to.
  await signOutWithFacebook().catchError((_) => null);

  final result = await FacebookAuth.instance.login(
    permissions: const ['email', 'public_profile'],
  );

  switch (result.status) {
    case LoginStatus.success:
      break;
    case LoginStatus.cancelled:
      // Backed out. Not an error -- null keeps the snackbar away.
      return null;
    case LoginStatus.operationInProgress:
      // A second tap while the sheet is already open. Nothing to report.
      return null;
    case LoginStatus.failed:
      // A real failure. Raised as PlatformException rather than returned as
      // null so it reaches authErrorMessage instead of looking like a
      // cancellation -- silent failure is the bug docs/auth-signin-plan.md
      // exists because of.
      throw PlatformException(
        code: 'facebook_login_failed',
        message: result.message,
      );
  }

  final token = result.accessToken;
  if (token == null) {
    // Reported success with no token. Should not happen; treat it as a failure
    // rather than a cancellation so it is visible.
    throw PlatformException(
      code: 'facebook_login_failed',
      message: 'Facebook returned no access token.',
    );
  }

  // Limited Login (iOS 17+, or when the user denies tracking) issues an OIDC
  // token instead of a classic access token, and the two need different
  // credentials. Getting this wrong fails only on the devices you are least
  // likely to be testing on.
  final credential = token is LimitedToken
      ? OAuthCredential(
          providerId: 'facebook.com',
          signInMethod: 'oauth',
          idToken: token.tokenString,
          rawNonce: token.nonce,
        )
      : FacebookAuthProvider.credential(token.tokenString);

  return FirebaseAuth.instance.signInWithCredential(credential);
}

/// Clears the Facebook SDK's own session.
///
/// Note this is NOT called from `FirebaseAuthManager.signOut()` -- neither is
/// `signOutWithGoogle()`. Both providers clear their cached session at the
/// START of the next sign-in instead, which is what makes the account picker
/// appear every time.
Future signOutWithFacebook() => FacebookAuth.instance.logOut();
