import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/nav/nav_widget.dart';
import '/settings/aboutus/aboutus_widget.dart';
import '/settings/credentials/credentials_widget.dart';
import '/settings/deleteaccount/deleteaccount_widget.dart';
import '/settings/notificationssettings/notificationssettings_widget.dart';
import '/settings/personalinfo/personalinfo_widget.dart';
import '/settings/support/support_widget.dart';
import '/settings/termsandconditions/termsandconditions_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'settings_widget.dart' show SettingsWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsModel extends FlutterFlowModel<SettingsWidget> {
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
