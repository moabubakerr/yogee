import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'reportpostbutton_model.dart';
export 'reportpostbutton_model.dart';

class ReportpostbuttonWidget extends StatefulWidget {
  const ReportpostbuttonWidget({
    super.key,
    required this.post,
  });

  final DocumentReference? post;

  @override
  State<ReportpostbuttonWidget> createState() => _ReportpostbuttonWidgetState();
}

class _ReportpostbuttonWidgetState extends State<ReportpostbuttonWidget> {
  late ReportpostbuttonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportpostbuttonModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        context.pushNamed(
          ReportpostWidget.routeName,
          queryParameters: {
            'post': serializeParam(
              widget!.post,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        );
      },
      text: 'Report post',
      icon: Icon(
        Icons.report_problem_rounded,
        size: 15.0,
      ),
      options: FFButtonOptions(
        width: 130.0,
        height: 40.0,
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        iconAlignment: IconAlignment.end,
        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: Color(0xFF282828),
        textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.manrope(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              letterSpacing: 0.0,
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
        elevation: 0.0,
        borderSide: BorderSide(
          color: Color(0xFF828282),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
