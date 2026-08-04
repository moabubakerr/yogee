import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/journal/deletenote/deletenote_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'note_widget.dart' show NoteWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NoteModel extends FlutterFlowModel<NoteWidget> {
  // State field(s) for the editable note body.
  FocusNode? topicFocusNode;
  TextEditingController? topicController;
  String? Function(BuildContext, String?)? topicControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    topicFocusNode?.dispose();
    topicController?.dispose();
  }
}
