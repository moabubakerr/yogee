import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/meditation/audioplayer/audioplayer_widget.dart';
import '/pages/nav/nav_widget.dart';
import 'dart:ui';
import 'player_widget.dart' show PlayerWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PlayerModel extends FlutterFlowModel<PlayerWidget> {
  ///  Local state fields for this page.

  String? currentchip =
      'chek thsi https://youtu.be/prmGrBTpbL8?si=tukSqMTnkWeHW-jZ';

  ///  State fields for stateful widgets in this page.

  // Model for nav component.
  late NavModel navModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
  }

  @override
  void dispose() {
    navModel.dispose();
  }
}
