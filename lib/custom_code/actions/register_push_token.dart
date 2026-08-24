// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, visibleForTesting;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Only the one function. permission_handler also exports `Permission` and
// `PermissionStatus`, which are near-misses for the names below.
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/custom_code/notification_type.dart';
// The two tap destinations, imported directly rather than through '/index.dart'
// so this file does not pull in every page widget in the app. Their `routeName`
// statics are the same ones the in-app notification list pushes.
import '/community/othersprofile/othersprofile_widget.dart';
import '/community/replies/replies_widget.dart';

// FCM device-token registration. See docs/fcm-push-plan.md, Step 6.
//
// The token lives at `users/{uid}/fcm_tokens/{token}` -- a SUBCOLLECTION, not a
// field on the user document. `firestore.rules` grants `read/write: if true` on
// /users/{document}, and a field there would publish every device token in the
// app to anyone holding the public API key, and let any unauthenticated caller
// wipe them. Subcollections are not covered by the parent match, so the rule at
// firestore.rules:23 is a genuine tightening.
//
// The document id IS the token, which makes registration idempotent and lets
// the Cloud Function delete a dead one with a plain delete instead of an
// arrayRemove read-modify-write.

/// Notification channel id. Must match the `default_notification_channel_id`
/// meta-data in `AndroidManifest.xml` exactly -- FCM names the channel there,
/// but nothing creates it, so without this the OS falls back to an
/// uncategorised "Miscellaneous" channel the user cannot configure.
const String kPushChannelId = 'yogee_social';

/// Guards against stacking a second `onTokenRefresh` listener every time
/// [registerPushToken] runs -- it runs on every auth event, not once.
StreamSubscription<String>? _refreshSub;

/// One plugin instance for the whole file. `show()` only works after
/// [FlutterLocalNotificationsPlugin.initialize] has run, and initialize is
/// per-instance -- a freshly constructed one has not been initialised, so the
/// banner would silently never appear.
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Guards against stacking a second `onMessage` listener. Same reason as
/// [_refreshSub]: one banner per listener, so a second subscription means two
/// identical banners per push.
StreamSubscription<RemoteMessage>? _messageSub;

/// Guards against stacking a second `onMessageOpenedApp` listener. Same reason
/// again, with a worse symptom than a duplicate banner: two subscriptions push
/// the destination screen onto the navigator twice, so the back button lands on
/// a second copy of the screen the user just came from.
StreamSubscription<RemoteMessage>? _tapSub;

/// A tap the app could not act on yet. See [_flushPendingTap].
Map<String, dynamic>? _pendingTap;

/// Last token written, so a refresh can delete the document it replaces. The
/// refresh event only carries the new token.
String? _writtenToken;

/// Every public function here is wrapped in one of these.
///
/// **Push registration must never be able to break authentication.** These are
/// awaited from inside `signOut()` and `deleteUser()`, so an escaping exception
/// would mean `FirebaseAuth.instance.signOut()` never runs and the user cannot
/// log out. Firestore throwing here is not hypothetical: until
/// `firestore.rules` is deployed, no rule matches `users/{uid}/fcm_tokens/...`
/// and **every** read and write is denied.
///
/// Swallowed, but never silently — a failed unregister leaves the token under
/// the old uid, which is the privacy leak Issue 13 is about, and Crashlytics is
/// the only place that would ever surface it.
Future<T> _guarded<T>(
  String what,
  Future<T> Function() body,
  T fallback,
) async {
  try {
    return await body();
  } catch (e, stack) {
    debugPrint('$what error: $e');
    await FirebaseCrashlytics.instance
        .recordError(e, stack, reason: 'push: $what failed', fatal: false);
    return fallback;
  }
}

CollectionReference<Map<String, dynamic>>? _tokensFor(String uid) =>
    uid.isEmpty
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('fcm_tokens');

/// Registers this device for push **without ever showing the permission
/// prompt**. Safe to call on every auth event and every app start.
///
/// iOS shows that prompt exactly once per install, ever, and a decline at
/// launch permanently kills push for that install -- so the prompt lives in
/// [requestPushPermission], called from a screen the user chose to open.
///
/// Returns true when a token was written. Never throws.
Future<bool> registerPushToken() {
  // Web FCM needs a VAPID key and a service worker, neither of which exists
  // here. Skipped rather than half-done: getToken() would throw.
  if (kIsWeb) return Future.value(false);

  return _guarded('registerPushToken', () async {
    // Before any early return below: this runs on every auth event, so it is
    // the first moment a tap held since cold start can name its destination.
    // The token checks that follow are irrelevant to a push already delivered.
    await _flushPendingTap();

    final tokens = _tokensFor(currentUserUid);
    if (tokens == null) return false;

    final messaging = FirebaseMessaging.instance;

    // Read, never request. `provisional` counts -- iOS quiet notifications are
    // delivered, they just land in the notification centre without a banner.
    final settings = await messaging.getNotificationSettings();
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!granted) return false;

    await _ensureChannel();

    // Null rather than an exception is the normal "not ready" answer here: on
    // iOS the APNs token may not have arrived yet, and on an Android device
    // without Play Services there is nothing to issue one. Both self-correct
    // on the next auth event, so this is a return, not an error.
    final token = await messaging.getToken();
    if (token == null) return false;

    await _writeToken(tokens, token);
    _listenForRefresh(messaging);
    return true;
  }, false);
}

/// Tokens rotate on reinstall, on restore-to-new-device, and sometimes on their
/// own. A stale token stops delivering with no error anywhere, so this listener
/// is not optional.
void _listenForRefresh(FirebaseMessaging messaging) {
  // `??=` because registerPushToken runs on every auth event, not once --
  // without it each sign-in stacks another listener on the same stream.
  _refreshSub ??= messaging.onTokenRefresh.listen((newToken) {
    // Guarded separately: this fires long after the call that created it, so
    // there is no caller left to catch anything it throws.
    _guarded('onTokenRefresh', () async {
      // Re-read the uid -- the listener outlives the sign-in that created it.
      final current = _tokensFor(currentUserUid);
      if (current == null) return;
      final previous = _writtenToken;
      await _writeToken(current, newToken);
      if (previous != null && previous != newToken) {
        await current.doc(previous).delete();
      }
    }, null);
  });
}

/// Shows the OS permission prompt, then registers.
///
/// Call this only from somewhere the user deliberately went -- Notification
/// settings -- never on launch. See the note on [registerPushToken].
/// Never throws.
Future<bool> requestPushPermission() async {
  if (kIsWeb) return false;
  // registerPushToken guards itself, so only the prompt needs wrapping. A
  // throw here would take down the settings screen's first frame.
  await _guarded('requestPermission',
      () => FirebaseMessaging.instance.requestPermission(), null);
  return registerPushToken();
}

/// What the OS says about push permission right now, reduced to the three
/// states a UI has to draw differently.
enum PushPermission {
  /// Never asked. The one-shot prompt is still unspent, so
  /// [requestPushPermission] will actually show it.
  notAsked,

  /// Notifications will arrive. `provisional` is folded in here because iOS
  /// quiet notifications ARE delivered -- they just land in the notification
  /// centre without a banner, same as [registerPushToken] treats them.
  granted,

  /// Asked and refused. On iOS the prompt is spent for the life of the install
  /// and can never be shown again; Android 13+ locks it the same way after two
  /// refusals. Calling [requestPushPermission] here does nothing at all -- the
  /// only route back is [openPushSettings].
  denied,
}

/// Reads permission state **without ever showing the prompt**. Safe to call on
/// every build and every resume.
///
/// Never throws. A failure reads as [PushPermission.notAsked], which offers the
/// user a button rather than a dead end.
Future<PushPermission> pushPermissionStatus() async {
  // Web has no token path here at all (see registerPushToken), so there is
  // nothing a prompt could turn on.
  if (kIsWeb) return PushPermission.denied;

  return _guarded('pushPermissionStatus', () async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional =>
        PushPermission.granted,
      AuthorizationStatus.notDetermined => PushPermission.notAsked,
      AuthorizationStatus.denied => PushPermission.denied,
    };
  }, PushPermission.notAsked);
}

/// Opens this app's page in the OS settings.
///
/// The only way back from [PushPermission.denied]: neither platform lets an app
/// re-prompt once the user has refused, so without this the settings screen is
/// a dead end that silently never delivers anything.
///
/// Returns false if the page could not be opened. Never throws.
Future<bool> openPushSettings() =>
    _guarded('openPushSettings', openAppSettings, false);

/// When the priming sheet was last dismissed, as epoch millis.
const String _softAskKey = 'push_soft_ask_at';

/// How long a "Not now" buys before the sheet may appear again.
///
/// Not once-only, because "Not now" does **not** spend the OS prompt -- asking
/// again later is free, and that is the entire point of putting our own sheet
/// in front of it. Not shorter either: a sheet on every post is how an app
/// teaches people to dismiss things without reading them.
const Duration _softAskInterval = Duration(days: 14);

/// The priming sheet -- our ask, in front of the OS one.
///
/// Call from a moment where push has just become obviously useful: after the
/// user posts, never at launch. The OS prompt is one-shot on both platforms, so
/// the only way to protect it is to never show it to someone who would decline.
/// Everyone who reaches it from here has already said yes once, to a dialog
/// that costs nothing when refused.
///
/// Does nothing when permission is already decided either way, or when this
/// sheet was dismissed recently. Never throws.
Future<void> maybeAskForPush(BuildContext context) async {
  if (kIsWeb) return;

  await _guarded('maybeAskForPush', () async {
    // Already granted: nothing to ask for. Already denied: the OS prompt is
    // spent and cannot be shown again, and marching someone to system settings
    // seconds after their first post is worse than staying quiet -- the
    // Notification settings screen offers that route when they go looking.
    if (await pushPermissionStatus() != PushPermission.notAsked) return;

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_softAskKey);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (last != null && now - last < _softAskInterval.inMilliseconds) return;

    // Written BEFORE the sheet, not after. If the app dies while it is up,
    // silent-for-14-days is the recoverable outcome; re-asking on every post is
    // the one that gets the app deleted.
    await prefs.setInt(_softAskKey, now);

    if (!context.mounted) return;
    final accepted = await _showSoftAskSheet(context);
    // Only here does the one-shot OS prompt get spent.
    if (accepted == true) {
      await requestPushPermission();
    }
  }, null);
}

/// Returns true if the user asked for push, null/false if they dismissed.
Future<bool?> _showSoftAskSheet(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);

  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xD8000000),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: const Color(0xFF939393)),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active,
                  color: theme.primary, size: 32.0),
              const SizedBox(height: 12.0),
              Text(
                'Know when someone replies',
                style: theme.titleMedium.override(letterSpacing: 0.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                // Says what arrives and what does not. The three things named
                // here are exactly what the one "Social notifications" switch
                // covers, so the promise and the control match.
                'Get notified when people like or reply to your posts, or '
                'start following you. Nothing else.',
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    // Costs nothing: the OS prompt is untouched, so this can be
                    // offered again in _softAskInterval.
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: Text(
                      'Not now',
                      style: theme.bodyMedium.override(
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0x1DF1B2F0),
                      side: const BorderSide(color: Color(0x6CE0E3E7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    ),
                    child: Text(
                      'Turn on',
                      style: theme.bodyMedium.override(letterSpacing: 0.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Draws the notification banner for pushes that arrive while the app is
/// **foregrounded**. See docs/fcm-push-plan.md, Step 3.
///
/// FCM draws its own banner only when the app is backgrounded or killed. In the
/// foreground the message is handed to `onMessage` with **no UI at all** -- so
/// without this, a push that works perfectly looks like a push that never
/// arrived. That is exactly what it looked like on-device before this existed.
///
/// Also wires **tap routing**: a tapped notification opens the same screen the
/// in-app notification list opens for that event. See [routeForPush].
///
/// Call once from `main.dart`'s `initState`, NOT from [registerPushToken]:
/// message delivery is a property of the install, not of who is signed in, and
/// hanging it off the auth stream would re-subscribe on every auth event.
/// Never throws.
Future<void> initPushMessaging() async {
  if (kIsWeb) return;

  await _guarded('initPushMessaging', () async {
    // iOS draws its own foreground banner once asked to; it needs no local
    // notification, and posting one as well would show TWO banners. So this is
    // the whole iOS implementation.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      // `show()` needs this; `createNotificationChannel` does not, which is why
      // the channel already worked without it. Icon must be a drawable/mipmap
      // that exists, or initialize throws.
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        // Taps on a FOREGROUND banner, Android only. Those banners are drawn by
        // this plugin, so FirebaseMessaging never hears about the tap -- it is
        // not a message being opened, it is a local notification being pressed.
        // iOS needs no equivalent: it draws its own foreground banner and a tap
        // on that arrives through onMessageOpenedApp like any other.
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null) return;
          _guarded('bannerTap', () => _routeFromData(jsonDecode(payload)), null);
        },
      );

      // A foreground banner outlives the app that drew it: background the app,
      // let Android kill the process, then tap the banner still sitting in the
      // shade. onDidReceiveNotificationResponse is NOT called on that path --
      // the launch details are the only record that it happened.
      final launch = await _localNotifications.getNotificationAppLaunchDetails();
      final launchPayload = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true && launchPayload != null) {
        await _routeFromData(jsonDecode(launchPayload));
      }
    }

    _messageSub ??= FirebaseMessaging.onMessage.listen((message) {
      // Guarded separately -- this fires long after the call that created it,
      // so there is no caller left to catch anything it throws.
      _guarded('onMessage', () => _showBanner(message), null);
    });

    // Tapped while the app was alive but backgrounded. FCM drew that banner
    // itself, so this is the only place the tap surfaces.
    _tapSub ??= FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _guarded('onMessageOpenedApp', () => _routeFromData(message.data), null);
    });

    // Tapped while the app was killed: this is the message that launched it.
    // Returns null on every normal launch, and consumes the message, so it is
    // safe to call unconditionally but pointless to call twice.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      await _routeFromData(initial.data);
    }
  }, null);
}

Future<void> _showBanner(RemoteMessage message) async {
  // Android only: iOS is handled by setForegroundNotificationPresentationOptions
  // above, and showing here too would double up.
  if (defaultTargetPlatform != TargetPlatform.android) return;

  // The Cloud Function always sends a `notification` block (index.js:181), so
  // the copy is already built and localised-by-the-server. Deriving it again
  // from `data` would be a second implementation free to drift from the first.
  final notification = message.notification;
  if (notification == null) return;

  await _ensureChannel();

  await _localNotifications.show(
    id: bannerIdForType(message.data['type']),
    title: notification.title,
    body: notification.body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        kPushChannelId,
        'Community',
        channelDescription: 'Likes, replies and new followers.',
        // Both are needed for a heads-up banner: `importance` is the channel
        // ceiling (API 26+), `priority` is what pre-26 honours.
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    // No tap handler is wired yet, so nothing reads this today. It costs one
    // argument and means tap routing does not have to touch this call.
    payload: jsonEncode(message.data),
  );
}

/// Which screen a tapped push opens, and the document **paths** its route
/// parameters need.
///
/// Mirrors what the in-app notification list does for the same event
/// (`notifications_widget.dart:381` for the two like types, `:639` and `:666`
/// for reply and follow) -- a push and a list row for one notification must not
/// land on different screens.
///
/// Path-based and pure on purpose: the caller turns the paths into
/// `DocumentReference`s, which keeps this testable without a Firebase app.
///
/// Returns null when the payload cannot name a destination. That is a dropped
/// tap -- the app opens on its usual screen -- rather than a crash.
@visibleForTesting
(String, Map<String, String>)? routeForPush(
  Map<String, dynamic> data,
  String currentUserPath,
) {
  final type = data['type'];

  if (type == NotificationType.follow) {
    // A follow carries no postref (addfriend_widget.dart:156 writes none), and
    // the actor's profile is the whole destination.
    final madeby = data['madeby'];
    if (madeby is! String || madeby.isEmpty) return null;
    return (OthersprofileWidget.routeName, {'profileowner': madeby});
  }

  // like_post, like_comment and reply all open the post. like_comment carries
  // the POST's reference, not the comment's (replies_widget.dart:1307), so all
  // three take the same route with the same parameter.
  //
  // An unrecognised type lands here too rather than being dropped, for the same
  // reason bannerIdForType still draws one: the server would not have sent it
  // without copy for it, and a postref is enough to open something sensible.
  final postref = data['postref'];
  if (postref is! String || postref.isEmpty) return null;
  // `userref` is the notification's `madeto`, which for a push IS the recipient
  // -- this device's signed-in user. It is not in the payload because it is
  // knowable without being sent.
  return (
    RepliesWidget.routeName,
    {'postref': postref, 'userref': currentUserPath},
  );
}

/// Entry point for all four tap paths. Holds the tap, then tries to act on it.
Future<void> _routeFromData(Map<String, dynamic> data) async {
  _pendingTap = data;
  await _flushPendingTap();
}

/// Pushes the held tap once both things it needs exist.
///
/// A tap on a killed app arrives from `getInitialMessage()` during
/// `initState`, before Firebase Auth has restored the session and before
/// `MaterialApp.router` has built its navigator. Neither is optional here:
/// `RepliesWidget` force-unwraps `userref` (`replies_widget.dart:228, :1031`),
/// so pushing before the user is known is a null-check crash rather than a
/// degraded screen, and there is no navigator to push onto either.
///
/// Retried from [registerPushToken], which runs on every auth event and is
/// therefore the first moment the destination is knowable.
Future<void> _flushPendingTap() async {
  final data = _pendingTap;
  if (data == null) return;

  final currentUserPath = currentUserReference?.path;
  // Held, not dropped. If the user never signs in there is nothing to open, and
  // holding is the correct end state -- a push cannot arrive for a device with
  // no registered token in the first place.
  if (currentUserPath == null) return;

  final route = routeForPush(data, currentUserPath);
  if (route == null) {
    _pendingTap = null;
    return;
  }

  final context = appNavigatorKey.currentContext;
  if (context == null) {
    // Auth is ready but the navigator is not, so this needs one more frame --
    // not another auth event, which on a cold start may never come.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _guarded('pendingTap', _flushPendingTap, null),
    );
    return;
  }

  _pendingTap = null;
  context.pushNamed(
    route.$1,
    queryParameters: {
      for (final param in route.$2.entries)
        param.key: serializeParam(
          FirebaseFirestore.instance.doc(param.value),
          ParamType.DocumentReference,
        ),
    }.withoutNulls,
  );
  await _markRead(data['notification_id']);
}

/// Marks the notification read, the same as tapping its row in the list
/// (`notifications_widget.dart:399`). Without it a tapped push stays unread and
/// keeps counting toward the bell badge, so the badge disagrees with what the
/// user has actually seen.
Future<void> _markRead(Object? notificationId) async {
  if (notificationId is! String || notificationId.isEmpty) return;
  // send_test_push.mjs sends a synthetic id for a document that does not exist
  // (`test-<millis>`); updating it would throw and file a Crashlytics report in
  // the middle of the one flow that exists to prove push works.
  if (notificationId.startsWith('test-')) return;

  await NotificationsRecord.collection
      .doc(notificationId)
      .update(createNotificationsRecordData(isread: true));
}

/// Notification id, and therefore what collapses.
///
/// Reusing an id REPLACES the existing banner. Background pushes already
/// collapse into three buckets via `collapseKeyForType` in
/// `firebase/functions/notification_type.js`, so a foreground banner with a
/// unique id per message would stack where the background one replaces --
/// 200 likes on a post would be 200 banners (Issue 8). These three ids mirror
/// those three collapse keys; change one and change the other.
@visibleForTesting
int bannerIdForType(String? type) {
  switch (type) {
    case NotificationType.likePost:
    case NotificationType.likeComment:
      return 1; // collapse key "like"
    case NotificationType.reply:
      return 2;
    case NotificationType.follow:
      return 3;
    default:
      // An unrecognised type still gets a banner rather than being dropped --
      // the server would not have sent it if it had no copy for it.
      return 0;
  }
}

/// Removes this device's token from the signed-in user.
///
/// Runs at the top of `deleteUser()` and inside `signOut()`
/// (`firebase_auth_manager.dart`). Deleting an absent document is a no-op, so
/// the double call on the delete-account path is harmless.
///
/// Deliberately does NOT call `messaging.deleteToken()`. Delivery is driven by
/// this subcollection, not by the token's existence, so invalidating it would
/// only force a pointless re-registration on the next sign-in.
/// **Never throws** -- see [_guarded]. `signOut()` awaits this before
/// `FirebaseAuth.instance.signOut()`, so an escaping exception would leave the
/// user unable to log out at all.
Future<void> unregisterPushToken() async {
  if (kIsWeb) return;

  await _guarded('unregisterPushToken', () async {
    final tokens = _tokensFor(currentUserUid);
    if (tokens == null) return;

    final token = _writtenToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await tokens.doc(token).delete();
    // Only cleared on success. If the delete was denied the document is still
    // there, and keeping the memo is what lets the next attempt find it.
    _writtenToken = null;
  }, null);
}

Future<void> _writeToken(
  CollectionReference<Map<String, dynamic>> tokens,
  String token,
) async {
  await tokens.doc(token).set({
    // Duplicated from the document id on purpose. The dedup trigger
    // (docs/fcm-push-plan.md, Step 7b) has to find every copy of one token
    // across every user's subcollection, and a collection group query cannot
    // match on `FieldPath.documentId()` with a bare id -- for a collection
    // group that comparison is against the full resource path. It needs a real
    // field. Needs a COLLECTION_GROUP fieldOverrides entry in
    // firestore.indexes.json before that query will run.
    'token': token,
    'platform': defaultTargetPlatform.name,
    // serverTimestamp, so the dedup trigger picks the surviving copy on the
    // server's clock rather than trusting a device's.
    'updated_at': FieldValue.serverTimestamp(),
  });
  _writtenToken = token;
}

/// Creates the channel named by the manifest meta-data. Required since API 26.
/// Re-creating an existing channel is a no-op on Android, so this runs on every
/// registration rather than being tracked.
///
/// `Importance.high` is what produces a heads-up banner; `defaultImportance`
/// posts silently to the shade, which for a like or a follow reads as broken.
Future<void> _ensureChannel() async {
  if (defaultTargetPlatform != TargetPlatform.android) return;

  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        kPushChannelId,
        'Community',
        description: 'Likes, replies and new followers.',
        importance: Importance.high,
      ));
}
