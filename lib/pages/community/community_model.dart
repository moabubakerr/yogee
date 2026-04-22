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
