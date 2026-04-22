import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/community/addfriend/addfriend_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/nav/nav_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'othersprofile_widget.dart' show OthersprofileWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class OthersprofileModel extends FlutterFlowModel<OthersprofileWidget> {
  ///  Local state fields for this page.

  List<DocumentReference> usersinchat = [];
  void addToUsersinchat(DocumentReference item) => usersinchat.add(item);
  void removeFromUsersinchat(DocumentReference item) =>
      usersinchat.remove(item);
  void removeAtIndexFromUsersinchat(int index) => usersinchat.removeAt(index);
  void insertAtIndexInUsersinchat(int index, DocumentReference item) =>
      usersinchat.insert(index, item);
  void updateUsersinchatAtIndex(
          int index, Function(DocumentReference) updateFn) =>
      usersinchat[index] = updateFn(usersinchat[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - identifyExistingChat] action in messageButton widget.
  ChatsRecord? existingChat;
  // Stores action output result for [Backend Call - Create Document] action in messageButton widget.
  ChatsRecord? newchatcreated;
  // Model for nav component.
  late NavModel navModel;

  // Pagination for profile posts list
  int postsPageSize = 20;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
  }

  @override
  void dispose() {
    navModel.dispose();
  }
}
