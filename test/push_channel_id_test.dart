// The notification channel id is declared in two places that cannot see each
// other: `AndroidManifest.xml` tells FCM which channel to post a background
// message into, and `register_push_token.dart` is what actually CREATES that
// channel at runtime. Nothing links them.
//
// Change one and not the other and Android quietly posts into a channel that
// was never created, so the OS files it under an uncategorised "Miscellaneous"
// heading the user cannot configure -- no exception, no log, and the
// notification still arrives, which is why this is easy to ship and hard to
// notice. See docs/fcm-push-plan.md, Step 4.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the runtime channel id matches the manifest meta-data', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final action =
        File('lib/custom_code/actions/register_push_token.dart').readAsStringSync();

    final manifestId = RegExp(
      r'default_notification_channel_id"\s*\n?\s*android:value="([^"]+)"',
    ).firstMatch(manifest)?.group(1);

    final runtimeId = RegExp(
      r"kPushChannelId\s*=\s*'([^']+)'",
    ).firstMatch(action)?.group(1);

    expect(manifestId, isNotNull,
        reason: 'the default_notification_channel_id meta-data is gone from '
            'AndroidManifest.xml -- FCM has no channel to post into');
    expect(runtimeId, isNotNull,
        reason: 'kPushChannelId is gone from register_push_token.dart -- '
            'nothing creates the channel the manifest names');
    expect(runtimeId, manifestId);
  });
}
