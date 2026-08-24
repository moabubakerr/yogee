// The foreground banner and the background push must collapse the SAME way.
//
// Background: FCM replaces a banner when the new message reuses a collapse key,
// and `collapseKeyForType` in firebase/functions/notification_type.js maps the
// four types onto three keys.
// Foreground: flutter_local_notifications replaces a banner when the new one
// reuses a notification id, and `bannerIdForType` maps the same four types onto
// three ids.
//
// Nothing links the two files. Let them drift and one path collapses while the
// other stacks -- 200 likes on a post becomes 200 banners in the foreground and
// one in the background, which is docs/fcm-push-plan.md Issue 8 half-fixed and
// is only reproducible by getting 200 likes.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yogee/custom_code/actions/register_push_token.dart';
import 'package:yogee/custom_code/notification_type.dart';

void main() {
  test('the two like types share one banner id, the others are distinct', () {
    final likePost = bannerIdForType(NotificationType.likePost);
    final likeComment = bannerIdForType(NotificationType.likeComment);
    final reply = bannerIdForType(NotificationType.reply);
    final follow = bannerIdForType(NotificationType.follow);

    expect(likePost, likeComment,
        reason: 'both like types collapse to one key on the server, so they '
            'must share one banner id here');
    expect({likePost, reply, follow}, hasLength(3),
        reason: 'like, reply and follow must not overwrite each other');
  });

  test('an unknown type still gets a banner', () {
    // Dropping it would silently hide a type added on the server before this
    // switch learns about it.
    expect(bannerIdForType('something_new'), isA<int>());
    expect(bannerIdForType(null), isA<int>());
  });

  test('the server still collapses both like types together', () {
    // The half of the invariant that lives in JavaScript. If someone gives
    // like_post and like_comment separate collapse keys there, the grouping
    // asserted above is wrong and this is what says so.
    final js = File('firebase/functions/notification_type.js').readAsStringSync();

    expect(
      js.contains('type === TYPE_LIKE_POST || type === TYPE_LIKE_COMMENT'),
      isTrue,
      reason: 'collapseKeyForType no longer groups the two like types -- '
          'bannerIdForType must be changed to match',
    );
  });
}
