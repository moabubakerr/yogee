import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/nav/nav_widget.dart';
import 'community_widget.dart' show CommunityWidget;
import 'package:flutter/material.dart';

class CommunityModel extends FlutterFlowModel<CommunityWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for nav component.
  late NavModel navModel;

  // Pagination — All Posts tab (load more button)
  int allPostsPageSize = 20;

  // Pagination — Following tab (load more button)
  int followingPostsPageSize = 20;

  // Comment counts, cached per post for the life of this page.
  //
  // The two FutureBuilders that show them build their `future:` inline in
  // `build()`, so without this every rebuild issues one fresh request per
  // visible post and resets the builder to `hasData: false` -- the spinner comes
  // back and the number disappears. That is worse here than for the streams
  // alongside it: `queryCommentsRecordCount` is a `count()` aggregation, which
  // is server-only, so unlike `snapshots()` there is no local cache to answer
  // the repeat instantly.
  //
  // ponytail: never expires while the page is alive, so a comment added by
  // SOMEONE ELSE while you sit on the feed will not appear until you leave.
  // Only the count is stale, and only until the next visit. Swap for a
  // denormalised `commentCount` on `posts` (maintained by a function, next to
  // onPostDeleted) if that stops being acceptable.
  final Map<DocumentReference, Future<int>> commentCounts = {};

  /// Count for [post], issued once and reused afterwards.
  Future<int> commentCount(DocumentReference post) =>
      commentCounts[post] ??= queryCommentsRecordCount(
        queryBuilder: (commentsRecord) =>
            commentsRecord.where('postref', isEqualTo: post),
      );

  /// Drops the cached count for [post] so the next build re-reads it.
  ///
  /// Called when returning from Replies, where the user may have just added
  /// one. Scoped to the single post they actually opened -- invalidating the
  /// whole map would re-query every visible row for one known change.
  void invalidateCommentCount(DocumentReference post) =>
      commentCounts.remove(post);

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    navModel.dispose();
  }
}
