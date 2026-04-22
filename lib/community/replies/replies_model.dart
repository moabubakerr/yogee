import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/community/reportpostbutton/reportpostbutton_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/nav/nav_widget.dart';
import 'dart:ui';
import 'replies_widget.dart' show RepliesWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RepliesModel extends FlutterFlowModel<RepliesWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for commenttextfield widget.
  FocusNode? commenttextfieldFocusNode;
  TextEditingController? commenttextfieldTextController;
  String? Function(BuildContext, String?)?
      commenttextfieldTextControllerValidator;
  // Model for nav component.
  late NavModel navModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
  }

  @override
  void dispose() {
    commenttextfieldFocusNode?.dispose();
    commenttextfieldTextController?.dispose();

    navModel.dispose();
  }
}
