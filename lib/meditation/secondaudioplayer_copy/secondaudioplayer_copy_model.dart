import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/meditation/next/next_widget.dart';
import '/meditation/playlistsetting/addtoplaylist/addtoplaylist_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'secondaudioplayer_copy_widget.dart' show SecondaudioplayerCopyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SecondaudioplayerCopyModel
    extends FlutterFlowModel<SecondaudioplayerCopyWidget> {
  ///  Local state fields for this component.

  bool isPlayingNewSong = true;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
