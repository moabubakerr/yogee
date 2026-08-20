/// True only in builds made with `--dart-define=UI_PREVIEW=true`.
///
/// Boots straight to the dashboard with no signed-in user, for testing layout
/// on hosted simulators (Appetize) without creating production accounts --
/// the iOS build has a single GoogleService-Info.plist pointing at the live
/// `yoogeeapp` project, and its `allow delete: if false` rules make any
/// account created there permanent.
///
/// Guarded by a dart-define rather than a plain flag so it cannot reach a
/// release build by accident: `const bool.fromEnvironment` folds to false at
/// compile time, and the bypass branches are dropped by the tree shaker.
const bool kUiPreview = bool.fromEnvironment('UI_PREVIEW');
