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

  test('previewOf collapses whitespace', () {
    // A notification body renders newlines, so a reply padded with blank lines
    // would otherwise become a full-height banner for one word.
    expect(NotificationType.previewOf('a\n\n\nb'), 'a b');
    expect(NotificationType.previewOf('  spaced   out  '), 'spaced out');
  });

  test('previewOf returns null when there is nothing to show', () {
    // Null so the caller omits the field, which the Cloud Function reads as
    // "no preview" and falls back to the plain sentence.
    expect(NotificationType.previewOf(''), isNull);
    expect(NotificationType.previewOf('   \n  '), isNull);
  });

  test('previewOf caps long replies, ellipsis included', () {
    final capped = NotificationType.previewOf('x' * 500)!;
    expect(capped.length, NotificationType.previewMaxChars + 1);
    expect(capped.endsWith('…'), isTrue);
  });

  test('previewOf leaves a reply at the cap untouched', () {
    final exact = 'y' * NotificationType.previewMaxChars;
    expect(NotificationType.previewOf(exact), exact);
  });
}
