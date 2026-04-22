import '/community/blockuser/blockuser_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'blockuserbutton_model.dart';
export 'blockuserbutton_model.dart';

class BlockuserbuttonWidget extends StatefulWidget {
  const BlockuserbuttonWidget({
    super.key,
    required this.chat,
    required this.user,
  });

  final DocumentReference? chat;
  final DocumentReference? user;

  @override
  State<BlockuserbuttonWidget> createState() => _BlockuserbuttonWidgetState();
}

class _BlockuserbuttonWidgetState extends State<BlockuserbuttonWidget> {
  late BlockuserbuttonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BlockuserbuttonModel());

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
        await showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: false,
          context: context,
          builder: (context) {
            return Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: BlockuserWidget(
                user: widget!.user!,
                chat: widget!.chat!,
              ),
            );
          },
        ).then((value) => safeSetState(() {}));
      },
      text: 'Block user',
      icon: Icon(
        Icons.block_sharp,
        size: 20.0,
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
