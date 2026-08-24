const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Firestore for this project lives in europe-west2. Functions default to
// us-central1, which still triggers correctly -- gen1 Firestore triggers work
// cross-region -- but pays a transatlantic round trip on every read and write.
//
// Applied to new functions only. A function's region CANNOT be changed after
// creation; moving onUserDeleted (and the two undeployed FlutterFlow functions)
// would mean deleting and recreating them, so they stay in us-central1 and the
// codebase is deliberately mixed-region.
const REGION = "europe-west2";

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const firestore = admin.firestore();
  // recursiveDelete, not delete: Firestore does NOT remove a document's
  // subcollections along with it, so a plain delete left
  // users/{uid}/fcm_tokens/* behind forever -- an orphan device token under a
  // uid whose auth user no longer exists.
  await firestore.recursiveDelete(firestore.doc("users/" + user.uid));
});

// Left unbounded, failurePolicy retries a v1 background function for SEVEN
// DAYS -- backoff runs 10s, 30s, 70s, 150s, 310s, 630s, then every 600s, which
// is ~1,000 invocations for one permanently-failing event. Stuck events retry
// independently, so a systematic failure multiplies by the posts deleted while
// it lasts.
//
// Two minutes caps that at 3 retries. A transient Firestore error clears in
// seconds; anything still failing at two minutes is a bug, and a bug will not
// fix itself given seven days either.
//
// Two things make the guard work: context.timestamp is the ORIGINAL event time,
// identical across retries, so the window is absolute rather than resetting;
// and it returns SUCCESSFULLY, which is what ends the chain -- throwing would
// continue it.
const MAX_RETRY_AGE_MS = 2 * 60 * 1000;

// A deleted post leaves two things behind. Both `comments` and `notifications`
// are separate top-level collections holding a `postref` back at the post, and
// removing the post document touches neither. Clients cannot clean either up --
// the rules deny delete on comments outright, and only let a user delete
// notifications addressed to them -- so the cascade runs here with admin
// privileges, which bypass security rules.
//
// Leaving notifications behind is not cosmetic: one pointing at a deleted post
// still renders, and notifications_widget.dart:381 navigates to RepliesWidget
// with that dangling reference when tapped. Push tap-routing lands on the same
// screen.
//
// retry is on because every operation here is a delete and therefore
// idempotent: re-running a partially-completed cascade converges rather than
// duplicating. Without it, a failure partway through the chunk loop left the
// cascade half done forever.
exports.onPostDeleted = functions
    .region(REGION)
    //disable retries for now, because of the potentially large bills, monitor first before enabling retries
    .runWith({failurePolicy: false})
    .firestore.document("posts/{postId}")
    .onDelete(async (snap, context) => {
      const ageMs = Date.now() - Date.parse(context.timestamp);
      if (ageMs > MAX_RETRY_AGE_MS) {
        console.error(
            "onPostDeleted giving up on " + context.params.postId +
            " after " + Math.round(ageMs / 1000) + "s of retries",
        );
        return;
      }

      const firestore = admin.firestore();
      const postRef = snap.ref;

      // Neither query needs a composite index: a single equality filter is
      // covered by the automatic single-field index. Notifications with no
      // postref -- a follow -- do not match, which is correct; they outlive the
      // post because they were never about it.
      const [comments, notifications] = await Promise.all([
        firestore.collection("comments").where("postref", "==", postRef).get(),
        firestore
            .collection("notifications")
            .where("postref", "==", postRef)
            .get(),
      ]);

      const refs = comments.docs
          .concat(notifications.docs)
          .map((doc) => doc.ref);
      if (refs.length === 0) {
        return;
      }

      // A write batch caps out at 500 operations, so commit in chunks rather
      // than assuming a post has few replies.
      const chunkSize = 400;
      for (let i = 0; i < refs.length; i += chunkSize) {
        const batch = firestore.batch();
        refs.slice(i, i + chunkSize).forEach((ref) => batch.delete(ref));
        await batch.commit();
      }

      console.log(
          "post " + context.params.postId + ": deleted " + comments.size +
          " comment(s) and " + notifications.size + " notification(s)",
      );
    });

// ---------------------------------------------------------------------------
// Push delivery -- docs/fcm-push-plan.md, Step 7
// ---------------------------------------------------------------------------

// Kept in their own module because Firebase treats every export of this file as
// a function to deploy, and these are the only part of the push path testable
// without an emulator. See notification_type.test.js.
const {
  typeFromLegacy,
  bodyForType,
  collapseKeyForType,
  socialPushMuted,
} = require("./notification_type");

exports.onNotificationCreated = functions
    .region(REGION)
    .firestore.document("notifications/{id}")
    .onCreate(async (snap, context) => {
      const data = snap.data() || {};
      const madeby = data.madeby;
      const madeto = data.madeto;

      if (!madeby || !madeto) {
        console.log("notification " + context.params.id + ": no madeby/madeto");
        return;
      }

      // Backstop for Issue 2. The clients guard this, but a client guard has to
      // be repeated at all seven write sites and cannot cover one nobody has
      // written yet. In-app a self-notification is cosmetic; as push it wakes
      // the user's phone for their own tap.
      if (madeby.path === madeto.path) {
        return;
      }

      // `type` first, the boolean pair second -- documents from an older client
      // carry only the booleans.
      const type = data.type || typeFromLegacy(
          data.ispost === true,
          data.is_like === true,
      );
      // `preview` carries the reply's own text (replies_widget.dart). Absent
      // for every other type, and for documents written before it existed --
      // bodyForType falls back to the plain sentence.
      const body = bodyForType(type, data.preview);
      if (body === null) {
        console.log("notification " + context.params.id + ": type " + type);
        return;
      }

      // The "Social notifications" switch in Notification settings. Read
      // BEFORE the token query, so a muted recipient costs one read not three.
      //
      // This only suppresses the PUSH. The notification document is already
      // written and still appears in the in-app list, which is the distinction
      // the switches promise: "stop waking my phone", not "stop telling me".
      //
      // The field sits on the users document, which firestore.rules still
      // grants `write: if true` -- so anyone holding the public API key can
      // mute anyone. That is the wide-open-rules problem tracked in CLAUDE.md,
      // not something this gate introduces; fcm_tokens live in a subcollection
      // precisely because a token is worse to expose than a preference.
      const recipient = await madeto.get();
      if (socialPushMuted(recipient.data() || {})) {
        console.log(
            "notification " + context.params.id + " (" + type + "): muted by " +
            madeto.path,
        );
        return;
      }

      // Registered devices for the recipient, written by registerPushToken in
      // lib/custom_code/actions/register_push_token.dart.
      const tokenDocs = await madeto.collection("fcm_tokens").get();
      if (tokenDocs.empty) {
        // The common case, and the one that looks like a bug from outside: no
        // device registered, or permission never granted. Logged because
        // nothing else anywhere reports it.
        console.log("no fcm tokens for " + madeto.path);
        return;
      }

      // A second read per send, to put a name in the copy -- the notification
      // document carries only a reference (Issue 9). Fine at this scale; if it
      // stops being fine, denormalise the name at write time rather than
      // caching here.
      const actor = await madeby.get();
      const actorData = actor.data() || {};
      const name = actorData.display_name || actorData.username || "Someone";

      const tokens = tokenDocs.docs.map((doc) => doc.id);
      const collapseKey = collapseKeyForType(type);

      // sendEachForMulticast, NOT sendMulticast/sendAll: those target a batch
      // endpoint that has since been decommissioned. It caps at 500 tokens,
      // which is one per install and so unreachable for a single user.
      const response = await admin.messaging().sendEachForMulticast({
        tokens: tokens,
        notification: {title: name, body: body},
        // Values must be strings. This is what a tap routes on once tap
        // handling exists; without it the tap has nothing to navigate to.
        data: {
          type: type,
          notification_id: context.params.id,
          postref: data.postref ? data.postref.path : "",
          madeby: madeby.path,
        },
        android: {
          collapseKey: collapseKey,
          // Must match kPushChannelId in register_push_token.dart and the
          // manifest meta-data; test/push_channel_id_test.dart guards those two
          // against each other.
          notification: {channelId: "yogee_social"},
        },
        apns: {headers: {"apns-collapse-id": collapseKey}},
      });

      // Dead devices, removed as they are discovered. This is what stops the
      // subcollection filling with tokens that will never deliver again. With
      // tokens as documents it is a plain delete -- no arrayRemove
      // read-modify-write race.
      const stale = [];
      response.responses.forEach((result, i) => {
        if (result.success) {
          return;
        }
        const code = result.error ? result.error.code : "";
        if (code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-registration-token") {
          stale.push(tokenDocs.docs[i].ref);
        } else {
          console.error("send failed on " + madeto.path, result.error);
        }
      });
      await Promise.all(stale.map((ref) => ref.delete()));

      console.log(
          "notification " + context.params.id + " (" + type + "): " +
          response.successCount + " sent, " + response.failureCount +
          " failed, " + stale.length + " pruned",
      );
    });

// Step 7b -- token dedup. Closes the one failure in the token lifecycle that
// does not self-heal.
//
// unregisterPushToken swallows its own errors, and has to: it is awaited inside
// signOut(), where an exception would leave the user unable to log out. When it
// fails the token stays under the old uid -- and an FCM token belongs to the
// INSTALL, not the user, so once the next person signs in on that phone the
// same token exists under two uids and both deliver. The new owner receives the
// previous owner's likes and follows.
//
// No client can repair that. By the time it is detectable the previous user is
// signed out, and firestore.rules correctly forbids user B from deleting a
// document under users/A. It needs admin privileges, so it lives here.
//
// onCreate rather than onWrite, deliberately: re-registering on the same
// account rewrites an existing document, which is an update and does not fire.
// A new user on the same device writes under a different parent, which is a
// create -- exactly the event that matters. The document that triggered this is
// therefore the newest copy by construction, so every other copy is stale and
// no timestamp comparison is needed.
exports.onTokenRegistered = functions
    .region(REGION)
    .firestore.document("users/{uid}/fcm_tokens/{token}")
    .onCreate(async (snap, context) => {
      const firestore = admin.firestore();
      const uid = context.params.uid;
      const token = snap.get("token");

      // _writeToken stores the token as a field as well as the document id: a
      // collection group query cannot match on FieldPath.documentId() with a
      // bare id, because for a collection group that comparison is against the
      // full resource path.
      if (!token) {
        console.log("fcm token doc " + snap.ref.path + ": no token field");
        return;
      }

      const copies = await firestore
          .collectionGroup("fcm_tokens")
          .where("token", "==", token)
          .get();

      const stale = copies.docs.filter((doc) => {
        const owner = doc.ref.parent.parent;
        return owner !== null && owner.id !== uid;
      });

      if (stale.length === 0) {
        return;
      }

      await Promise.all(stale.map((doc) => doc.ref.delete()));
      console.log(
          "token registered for " + uid + ": removed " + stale.length +
          " stale copies under other users",
      );
    });
