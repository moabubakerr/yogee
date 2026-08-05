import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'deletepost_widget.dart' show DeletepostWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DeletepostModel extends FlutterFlowModel<DeletepostWidget> {
  /// Guards against a double-tap firing two deletes while the first is in
  /// flight.
  bool isDeleting = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
