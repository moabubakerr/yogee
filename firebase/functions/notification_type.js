// Mirror of lib/custom_code/notification_type.dart.
//
// A separate module rather than living in index.js for two reasons: Firebase
// treats every export of index.js as a function to deploy, and these are the
// only part of the push path that can be tested without an emulator or a
// device. notification_type.test.js covers them.
//
// The Dart side has its own test (test/notification_type_test.dart). These two
// mappings must agree -- a document written by an older client carries only the
// booleans, and this is what decodes them.

const TYPE_LIKE_POST = "like_post";
const TYPE_LIKE_COMMENT = "like_comment";
const TYPE_REPLY = "reply";
const TYPE_FOLLOW = "follow";

/**
 * Decodes the legacy boolean pair, for documents written before the `type`
 * field existed. Those clients are still installed and outlive this deploy, so
 * the fallback is not optional.
 *
 * The pair has FOUR states, and a decoder that assumes three sends
 * "started following you" to everyone whose comment was liked.
 *
 * @param {boolean} ispost Whether the target was a post.
 * @param {boolean} isLike Whether the event was a like.
 * @return {string} One of the TYPE_* values.
 */
function typeFromLegacy(ispost, isLike) {
  if (isLike) {
    return ispost ? TYPE_LIKE_POST : TYPE_LIKE_COMMENT;
  }
  return ispost ? TYPE_REPLY : TYPE_FOLLOW;
}

/**
 * Longest reply preview that goes out in a push.
 *
 * Mirrors `NotificationType.previewMaxChars` in
 * lib/custom_code/notification_type.dart, which caps it at the write site too.
 * This cap is the one that has to exist: any client can write a notification
 * document, `firestore.rules` does not constrain the field's length, and an FCM
 * message has a 4KB ceiling for the whole payload.
 */
const PREVIEW_MAX = 120;

/**
 * The reply text as it appears in a banner, or null if there is none worth
 * showing.
 *
 * Whitespace is collapsed rather than trimmed: a notification body renders
 * newlines, so a reply padded with blank lines would turn a one-word banner
 * into a full-height one.
 *
 * @param {*} preview The raw `preview` field, which is untrusted client input
 *     and may be any type, or absent entirely.
 * @return {?string} Condensed preview, or null.
 */
function cleanPreview(preview) {
  if (typeof preview !== "string") {
    return null;
  }
  const collapsed = preview.replace(/\s+/g, " ").trim();
  if (collapsed === "") {
    return null;
  }
  if (collapsed.length <= PREVIEW_MAX) {
    return collapsed;
  }
  return collapsed.slice(0, PREVIEW_MAX).trimEnd() + "…";
}

/**
 * The sentence shown under the actor's name.
 *
 * A reply quotes itself when the document carries the text. It falls back to
 * the bare sentence when it does not, which covers every document written
 * before the `preview` field existed and every reply that was pure whitespace.
 *
 * @param {string} type One of the TYPE_* values.
 * @param {*=} preview The document's `preview` field. Ignored for every type
 *     but TYPE_REPLY, which is the only one with text of its own.
 * @return {?string} The body copy, or null if the type is unrecognised.
 */
function bodyForType(type, preview) {
  switch (type) {
    case TYPE_LIKE_POST:
      return "liked your post";
    case TYPE_LIKE_COMMENT:
      return "liked your comment";
    case TYPE_REPLY: {
      const quoted = cleanPreview(preview);
      return quoted === null ?
        "replied to your post" :
        "replied to your post: “" + quoted + "”";
    }
    case TYPE_FOLLOW:
      return "started following you";
    default:
      return null;
  }
}

/**
 * Groups the four types into three collapse keys.
 *
 * Android allows a maximum of FOUR distinct collapse keys per device at once;
 * past that FCM discards keys unpredictably and the behaviour is undefined.
 * Four types would sit exactly on that ceiling with no headroom for a fifth
 * feature later, so the two like variants share a key. Per-post granularity is
 * what the notification body is for.
 *
 * @param {string} type One of the TYPE_* values.
 * @return {string} The collapse key.
 */
function collapseKeyForType(type) {
  if (type === TYPE_LIKE_POST || type === TYPE_LIKE_COMMENT) {
    return "like";
  }
  return type;
}

/**
 * The `users` document field behind the single "Social notifications" switch.
 *
 * ONE switch for all four types. Not one per type: every one of them is the
 * same promise from the user's side -- "tell me when someone interacts with
 * me" -- and a settings screen that makes people reason about four near
 * identical rows mostly teaches them to turn the lot off.
 *
 * Mirrors lib/backend/schema/users_record.dart and the row in
 * lib/settings/notificationssettings/notificationssettings_widget.dart. Rename
 * it here and rename it there in the same commit, or the switch silently stops
 * doing anything.
 */
const SOCIAL_PREF_FIELD = "notify_social";

/**
 * Whether the recipient has switched social push off.
 *
 * ABSENT MEANS ON, and that is the whole reason this is a function rather than
 * a truthiness check at the call site. Nobody who signed up before this field
 * existed has it, so reading a missing field as "off" would silence push for
 * the entire existing user base in a single deploy. Only an explicit `false`
 * mutes.
 *
 * @param {!Object} userData The recipient's `users` document data.
 * @return {boolean} True if the push must not be sent.
 */
function socialPushMuted(userData) {
  return userData[SOCIAL_PREF_FIELD] === false;
}

module.exports = {
  TYPE_LIKE_POST,
  TYPE_LIKE_COMMENT,
  TYPE_REPLY,
  TYPE_FOLLOW,
  SOCIAL_PREF_FIELD,
  PREVIEW_MAX,
  typeFromLegacy,
  bodyForType,
  cleanPreview,
  collapseKeyForType,
  socialPushMuted,
};
