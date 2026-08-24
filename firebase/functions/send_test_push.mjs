// Sends a real FCM push to a user's registered devices, bypassing Firestore.
//
//   node send_test_push.mjs <email-or-uid> [type]
//
// This is Step 8 of docs/fcm-push-plan.md -- "verify on a device". It sends the
// SAME payload onNotificationCreated builds (index.js:179), so a push that
// arrives here proves the token, the channel and the APNs/Android config are
// all good, and anything still broken afterwards is in the trigger, not the
// device.
//
// Deliberately does NOT write a `notifications` document. That would exercise
// the trigger too, but firestore.rules sets `allow delete: if false` on
// notifications, so every test run would leave a permanent row in the
// recipient's in-app list. Use a real like from a second account for that.

import admin from 'firebase-admin';

// The project the app actually points at. Android release AND debug builds both
// land here, because android/app/src/debug/google-services.json is missing.
// Tokens live nowhere else, so there is no other target worth offering.
const PROJECT_ID = 'yoogeeapp';

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('GOOGLE_APPLICATION_CREDENTIALS is not set.');
  console.error(`Firebase console -> ${PROJECT_ID} -> Project settings -> Service accounts`);
  console.error('  -> Generate new private key, save it OUTSIDE the repo, then:');
  console.error('  $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\\path\\to\\key.json"');
  process.exit(1);
}

const [target, type = 'like_post', preview] = process.argv.slice(2);
if (!target) {
  console.error('Usage: node send_test_push.mjs <email-or-uid> [type] [preview]');
  console.error('  type: like_post | like_comment | reply | follow');
  console.error('  preview: reply text to quote, `reply` only');
  process.exit(1);
}

// Same module the Cloud Function uses, so the copy and the collapse key under
// test are the real ones rather than a second implementation that can drift.
const { bodyForType, collapseKeyForType } = await import('./notification_type.js')
  .then((m) => m.default ?? m);

const body = bodyForType(type, preview);
if (body === null) {
  console.error(`Unknown type "${type}". Use like_post, like_comment, reply or follow.`);
  process.exit(1);
}

admin.initializeApp({ projectId: PROJECT_ID });

const uid = target.includes('@')
  ? (await admin.auth().getUserByEmail(target)).uid
  : target;

const tokenDocs = await admin.firestore()
  .collection('users').doc(uid).collection('fcm_tokens').get();

if (tokenDocs.empty) {
  // The failure everyone hits first. The Cloud Function returns silently here
  // too (index.js:157), which is why this says out loud what to do about it.
  console.error(`No fcm_tokens under users/${uid}.`);
  console.error('On the phone: sign in, then open Notification settings and grant');
  console.error('permission -- that screen is the ONLY place the prompt fires.');
  process.exit(1);
}

const tokens = tokenDocs.docs.map((d) => d.id);
console.log(`users/${uid}: ${tokens.length} device(s)`);

const collapseKey = collapseKeyForType(type);
const response = await admin.messaging().sendEachForMulticast({
  tokens,
  notification: { title: 'Yogee test', body },
  data: {
    type,
    notification_id: 'test-' + Date.now(),
    postref: '',
    madeby: '',
  },
  android: {
    collapseKey,
    // Must match kPushChannelId in register_push_token.dart. A wrong id here
    // still delivers, but into an uncategorised channel -- which is exactly the
    // bug this script exists to catch, so it must not be hardcoded loosely.
    notification: { channelId: 'yogee_social' },
  },
  apns: { headers: { 'apns-collapse-id': collapseKey } },
});

response.responses.forEach((r, i) => {
  const short = tokens[i].slice(0, 12) + '...';
  console.log(r.success ? `  ok    ${short}` : `  FAIL  ${short}  ${r.error?.code}`);
});

console.log(`${response.successCount} sent, ${response.failureCount} failed`);
// Stale tokens are left in place on purpose: pruning is the Cloud Function's
// job, and a test script that deletes rows can turn a bad credential into data
// loss.
process.exit(response.failureCount > 0 ? 1 : 0);
