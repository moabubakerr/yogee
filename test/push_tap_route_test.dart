// A tapped push and a tapped row in the in-app notification list must open the
// same screen for the same event. Nothing in the type system links them: the
// list decodes `ispost`/`is_like` in notifications_widget.dart, and the push
// decodes `type` out of an FCM data payload built by a Cloud Function.
//
// The case that is easy to get wrong is `like_comment`. It is the only type
// where `ispost` is false but the destination is still the post -- decode it as
// "not a post, so a profile" and every comment-like tap opens the wrong screen,
// which is the same three-state mistake docs/fcm-push-plan.md Issue 1 records.
import 'package:flutter_test/flutter_test.dart';
import 'package:yogee/custom_code/actions/register_push_token.dart';
import 'package:yogee/custom_code/notification_type.dart';

/// What the Cloud Function sends (firebase/functions/index.js:184-189). Values
/// are all strings there -- FCM data payloads carry nothing else.
Map<String, dynamic> payload(String type, {String postref = 'posts/p1'}) => {
      'type': type,
      'notification_id': 'n1',
      'postref': type == NotificationType.follow ? '' : postref,
      'madeby': 'users/actor',
    };

const _me = 'users/me';

void main() {
  test('all three post-related types open the post, not a profile', () {
    for (final type in [
      NotificationType.likePost,
      NotificationType.likeComment,
      NotificationType.reply,
    ]) {
      final route = routeForPush(payload(type), _me);

      expect(route, isNotNull, reason: '$type must resolve a destination');
      expect(route!.$1, 'Replies', reason: '$type must open the post');
      expect(route.$2['postref'], 'posts/p1');
      // Replies force-unwraps this (replies_widget.dart:228). A missing userref
      // is a null-check crash on open, not a degraded screen.
      expect(route.$2['userref'], _me,
          reason: 'userref is the recipient, which for a push is this device');
    }
  });

  test('a follow opens the actor, not the recipient', () {
    final route = routeForPush(payload(NotificationType.follow), _me);

    expect(route, isNotNull);
    expect(route!.$1, 'othersprofile');
    expect(route.$2['profileowner'], 'users/actor',
        reason: 'the profile to open is who followed you, not you');
  });

  test('a payload with nothing to open is dropped rather than half-pushed', () {
    // Both of these would previously have pushed a screen with a null required
    // parameter. Dropping the tap opens the app on its usual screen instead.
    expect(routeForPush(payload(NotificationType.reply, postref: ''), _me),
        isNull);
    expect(
      routeForPush({'type': NotificationType.follow, 'madeby': ''}, _me),
      isNull,
    );
    expect(routeForPush(const {}, _me), isNull);
  });

  test('an unknown type still opens the post when it names one', () {
    // Same stance as bannerIdForType: the server would not have sent a type it
    // had no copy for, so a postref is enough to open something sensible.
    final route = routeForPush(payload('something_new'), _me);

    expect(route, isNotNull);
    expect(route!.$1, 'Replies');
  });

  test('the route names still match the widgets they are meant to open', () {
    // routeForPush reads these off the widget classes, so this only fails if a
    // route is renamed -- at which point the expectations above are stale too.
    expect(routeForPush(payload(NotificationType.reply), _me)!.$1, 'Replies');
    expect(routeForPush(payload(NotificationType.follow), _me)!.$1,
        'othersprofile');
  });
}
