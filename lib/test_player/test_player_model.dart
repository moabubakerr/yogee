import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/meditation/playlistsetting/addtoplaylist/addtoplaylist_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'test_player_widget.dart' show TestPlayerWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TestPlayerModel extends FlutterFlowModel<TestPlayerWidget> {
  ///  Local state fields for this page.

  bool isPlayingNewSong = true;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
