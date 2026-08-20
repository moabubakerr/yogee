// Values for the `type` field on a notifications document.
//
// Lives directly in lib/custom_code/ rather than beside the record class:
// lib/backend/schema/*_record.dart is generated from the FlutterFlow schema
// editor, so constants added there would not survive a re-export. Files at the
// root of lib/custom_code/ are untouched by it.
//
// These strings are a contract with the Cloud Function that delivers pushes
// (docs/fcm-push-plan.md, Step 7) -- it switches on them and falls back to the
// ispost/is_like pair for documents written by older clients. Change a value
// here and the function stops recognising it, so the function's switch has to
// change in the same commit.

/// The four kinds of social event a notification can represent.
///
/// The legacy encoding is a pair of booleans with FOUR states, which is easy to
/// decode as three -- treating `ispost == false` as "follow" also swallows
/// "liked your comment". Hence an explicit field.
///
/// | `ispost` | `is_like` | value |
/// |---|---|---|
/// | true | true | [likePost] |
/// | false | true | [likeComment] |
/// | true | false | [reply] |
/// | false | false | [follow] |
abstract final class NotificationType {
  /// Someone liked the user's post.
  static const String likePost = 'like_post';

  /// Someone liked one of the user's comments.
  static const String likeComment = 'like_comment';

  /// Someone replied to the user's post.
  static const String reply = 'reply';

  /// Someone started following the user.
  static const String follow = 'follow';

  /// Decodes the legacy boolean pair, for documents written before the `type`
  /// field existed.
  ///
  /// Kept next to the values it produces so the table above and the mapping
  /// cannot drift apart.
  static String fromLegacy({required bool ispost, required bool isLike}) {
    if (isLike) return ispost ? likePost : likeComment;
    return ispost ? reply : follow;
  }
}
