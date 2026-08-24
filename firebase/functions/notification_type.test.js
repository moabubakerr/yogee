// Run with `npm test` (node:test, built into Node 20 -- no framework, no deps).
//
// The Dart mirror is test/notification_type_test.dart. If a row changes in one,
// it changes in both: an older client writes only the boolean pair, so this
// decode is the only thing standing between it and the wrong copy.

const test = require("node:test");
const assert = require("node:assert");

const {
  TYPE_LIKE_POST,
  TYPE_LIKE_COMMENT,
  TYPE_REPLY,
  TYPE_FOLLOW,
  typeFromLegacy,
  bodyForType,
  collapseKeyForType,
  SOCIAL_PREF_FIELD,
  PREVIEW_MAX,
  socialPushMuted,
  cleanPreview,
} = require("./notification_type");

test("all four legacy states decode to distinct types", () => {
  assert.strictEqual(typeFromLegacy(true, true), TYPE_LIKE_POST);
  assert.strictEqual(typeFromLegacy(false, true), TYPE_LIKE_COMMENT);
  assert.strictEqual(typeFromLegacy(true, false), TYPE_REPLY);
  assert.strictEqual(typeFromLegacy(false, false), TYPE_FOLLOW);
});

test("a liked comment is not decoded as a follow", () => {
  // The specific three-state mistake: `ispost == false` meaning "follow".
  // This is the row that sends the wrong push to the wrong person.
  assert.notStrictEqual(typeFromLegacy(false, true), TYPE_FOLLOW);
});

test("every type has copy, and an unknown type has none", () => {
  const types = [TYPE_LIKE_POST, TYPE_LIKE_COMMENT, TYPE_REPLY, TYPE_FOLLOW];
  for (const type of types) {
    assert.strictEqual(typeof bodyForType(type), "string");
  }
  // Null is what makes onNotificationCreated return instead of sending a
  // notification with an empty body.
  assert.strictEqual(bodyForType("something_new"), null);
  assert.strictEqual(bodyForType(undefined), null);
});

test("the four bodies are distinct", () => {
  const bodies = new Set([
    bodyForType(TYPE_LIKE_POST),
    bodyForType(TYPE_LIKE_COMMENT),
    bodyForType(TYPE_REPLY),
    bodyForType(TYPE_FOLLOW),
  ]);
  assert.strictEqual(bodies.size, 4);
});

test("collapse keys stay under the Android ceiling of four", () => {
  const keys = new Set([
    collapseKeyForType(TYPE_LIKE_POST),
    collapseKeyForType(TYPE_LIKE_COMMENT),
    collapseKeyForType(TYPE_REPLY),
    collapseKeyForType(TYPE_FOLLOW),
  ]);
  // Three, not four: past four distinct keys FCM discards them unpredictably,
  // so the two like variants deliberately share one and leave headroom.
  assert.strictEqual(keys.size, 3);
  assert.strictEqual(
      collapseKeyForType(TYPE_LIKE_POST),
      collapseKeyForType(TYPE_LIKE_COMMENT),
  );
});


test("a user with no preference field is not muted", () => {
  // The regression that would silence every existing user in one deploy:
  // nobody has this field, so absent MUST read as on.
  assert.strictEqual(socialPushMuted({}), false);
  assert.strictEqual(socialPushMuted({some_other_field: false}), false);
});

test("only an explicit false mutes", () => {
  assert.strictEqual(socialPushMuted({[SOCIAL_PREF_FIELD]: false}), true);
  assert.strictEqual(socialPushMuted({[SOCIAL_PREF_FIELD]: true}), false);
  // Not falsiness -- null and undefined are what a half-written document has,
  // and neither is the user having chosen anything.
  assert.strictEqual(socialPushMuted({[SOCIAL_PREF_FIELD]: null}), false);
  assert.strictEqual(socialPushMuted({[SOCIAL_PREF_FIELD]: undefined}), false);
});

test("the one switch covers every type", () => {
  // There is no per-type field any more. If this ever splits again, it splits
  // here first -- the gate in index.js does not know the type at all.
  const muted = {[SOCIAL_PREF_FIELD]: false};
  assert.strictEqual(socialPushMuted(muted), true);
  assert.strictEqual(SOCIAL_PREF_FIELD, "notify_social");
});

test("a reply quotes its own text", () => {
  assert.strictEqual(
      bodyForType(TYPE_REPLY, "great track"),
      "replied to your post: “great track”",
  );
});

test("a reply with no usable preview falls back to the plain sentence", () => {
  // Every document written before the field existed hits this, so it is the
  // normal path, not the error path.
  assert.strictEqual(bodyForType(TYPE_REPLY), "replied to your post");
  assert.strictEqual(bodyForType(TYPE_REPLY, ""), "replied to your post");
  assert.strictEqual(bodyForType(TYPE_REPLY, "   "), "replied to your post");
  assert.strictEqual(bodyForType(TYPE_REPLY, null), "replied to your post");
});

test("preview is untrusted, so a non-string never reaches the body", () => {
  // Any client can write a notification document. A number or an object here
  // would otherwise be string-concatenated into the banner.
  for (const bad of [42, {}, [], true, () => {}]) {
    assert.strictEqual(bodyForType(TYPE_REPLY, bad), "replied to your post");
  }
});

test("a long preview is capped, and the cap includes the ellipsis", () => {
  const long = "x".repeat(500);
  const cleaned = cleanPreview(long);
  assert.strictEqual(cleaned.length, PREVIEW_MAX + 1);
  assert.ok(cleaned.endsWith("…"));
});

test("newlines are collapsed, not preserved", () => {
  // A body renders newlines. Without this, a reply padded with blank lines
  // becomes a full-height banner for one word of text.
  assert.strictEqual(cleanPreview("a\n\n\n\nb"), "a b");
  assert.strictEqual(cleanPreview("  spaced   out  "), "spaced out");
});

test("the other three types ignore preview entirely", () => {
  const types = [TYPE_LIKE_POST, TYPE_LIKE_COMMENT, TYPE_FOLLOW];
  for (const type of types) {
    assert.strictEqual(bodyForType(type, "ignored"), bodyForType(type));
  }
  // And an unknown type is still null, preview or not.
  assert.strictEqual(bodyForType("something_new", "text"), null);
});
