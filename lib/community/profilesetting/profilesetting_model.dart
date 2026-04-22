import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/nav/nav_widget.dart';
import '/settings/usernameset/usernameset_widget.dart';
import 'dart:ui';
import 'profilesetting_widget.dart' show ProfilesettingWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilesettingModel extends FlutterFlowModel<ProfilesettingWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataCbn = false;
  FFUploadedFile uploadedLocalFile_uploadDataCbn =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataCbn = '';

  // State field(s) for fullname widget.
  FocusNode? fullnameFocusNode;
  TextEditingController? fullnameTextController;
  String? Function(BuildContext, String?)? fullnameTextControllerValidator;
  // State field(s) for username widget.
  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  String? Function(BuildContext, String?)? usernameTextControllerValidator;
  // State field(s) for Bio widget.
  FocusNode? bioFocusNode;
  TextEditingController? bioTextController;
  String? Function(BuildContext, String?)? bioTextControllerValidator;
  // State field(s) for interests widget.
  FocusNode? interestsFocusNode;
  TextEditingController? interestsTextController;
  String? Function(BuildContext, String?)? interestsTextControllerValidator;
  // State field(s) for from widget.
  FocusNode? fromFocusNode;
  TextEditingController? fromTextController;
  String? Function(BuildContext, String?)? fromTextControllerValidator;
  // State field(s) for current widget.
  FocusNode? currentFocusNode;
  TextEditingController? currentTextController;
  String? Function(BuildContext, String?)? currentTextControllerValidator;
  // Model for nav component.
  late NavModel navModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
  }

  @override
  void dispose() {
    fullnameFocusNode?.dispose();
    fullnameTextController?.dispose();

    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    bioFocusNode?.dispose();
    bioTextController?.dispose();

    interestsFocusNode?.dispose();
    interestsTextController?.dispose();

    fromFocusNode?.dispose();
    fromTextController?.dispose();

    currentFocusNode?.dispose();
    currentTextController?.dispose();

    navModel.dispose();
  }
}
