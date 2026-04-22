import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'credentials_widget.dart' show CredentialsWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CredentialsModel extends FlutterFlowModel<CredentialsWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for update_email widget.
  FocusNode? updateEmailFocusNode;
  TextEditingController? updateEmailTextController;
  String? Function(BuildContext, String?)? updateEmailTextControllerValidator;
  // State field(s) for update_password widget.
  FocusNode? updatePasswordFocusNode;
  TextEditingController? updatePasswordTextController;
  String? Function(BuildContext, String?)?
      updatePasswordTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    updateEmailFocusNode?.dispose();
    updateEmailTextController?.dispose();

    updatePasswordFocusNode?.dispose();
    updatePasswordTextController?.dispose();
  }
}
