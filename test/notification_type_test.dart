// Covers the legacy notification encoding. The bug this guards against: the
// ispost/is_like pair has FOUR states, and a decoder that assumes three treats
// `ispost == false` as "follow" -- which sends "started following you" to
// everyone whose comment was liked.
//
// The Cloud Function that delivers pushes (docs/fcm-push-plan.md, Step 7)
// mirrors this mapping in JS for documents written before the `type` field
// existed. If a row here changes, that switch changes with it.
import 'package:flutter_test/flutter_test.dart';

import 'package:yogee/custom_code/notification_type.dart';

void main() {
  test('all four legacy states decode to distinct types', () {
    expect(
      NotificationType.fromLegacy(ispost: true, isLike: true),
      NotificationType.likePost,
    );
    expect(
      NotificationType.fromLegacy(ispost: false, isLike: true),
      NotificationType.likeComment,
    );
    expect(
      NotificationType.fromLegacy(ispost: true, isLike: false),
      NotificationType.reply,
    );
    expect(
      NotificationType.fromLegacy(ispost: false, isLike: false),
      NotificationType.follow,
    );
  });

  test('a liked comment is not decoded as a follow', () {
    // The specific three-state mistake: `ispost == false` meaning "follow".
    expect(
      NotificationType.fromLegacy(ispost: false, isLike: true),
      isNot(NotificationType.follow),
    );
  });

  test('the four values are distinct', () {
    final values = {
      NotificationType.likePost,
      NotificationType.likeComment,
      NotificationType.reply,
      NotificationType.follow,
    };
    expect(values, hasLength(4));
  });
}
