import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'createnote_widget.dart' show CreatenoteWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreatenoteModel extends FlutterFlowModel<CreatenoteWidget> {
  ///  Local state fields for this component.

  String state = 'notset';

  ///  State fields for stateful widgets in this component.

  // State field(s) for notename widget.
  FocusNode? notenameFocusNode;
  TextEditingController? notenameTextController;
  String? Function(BuildContext, String?)? notenameTextControllerValidator;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  WrittenNoteRecord? voicenote;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  WrittenNoteRecord? note;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    notenameFocusNode?.dispose();
    notenameTextController?.dispose();
  }
}
