import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'deletepost_model.dart';
export 'deletepost_model.dart';

/// Confirmation dialog for deleting a community post.
///
/// Pops with `true` once the post document is gone, `null`/`false` otherwise,
/// so the caller can decide whether to show a confirmation toast. Comments and
/// likes attached to the post are cleaned up server-side by the
/// `onPostDeleted` Cloud Function — the client only removes the post document.
class DeletepostWidget extends StatefulWidget {
  const DeletepostWidget({
    super.key,
    required this.post,
  });

  final DocumentReference? post;

  @override
  State<DeletepostWidget> createState() => _DeletepostWidgetState();
}

class _DeletepostWidgetState extends State<DeletepostWidget> {
  late DeletepostModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeletepostModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> _deletePost() async {
    if (_model.isDeleting || widget.post == null) {
      return;
    }
    safeSetState(() => _model.isDeleting = true);

    try {
      await widget.post!.delete();
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      safeSetState(() => _model.isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete this post. Please try again.',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 300.0,
        decoration: BoxDecoration(
          color: Color(0xD8000000),
          boxShadow: [
            BoxShadow(
              blurRadius: 24.0,
              color: Color(0x2CF1B2F0),
              offset: Offset(
                0.0,
                2.0,
              ),
              spreadRadius: 3.0,
            )
          ],
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Color(0xFF939393),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200.0,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14.0,
                      color: Color(0x63F1B2F0),
                      offset: Offset(
                        0.0,
                        0.0,
                      ),
                    )
                  ],
                  gradient: LinearGradient(
                    colors: [Color(0xFF181818), Colors.black],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.64, 1.0),
                    end: AlignmentDirectional(-0.64, -1.0),
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Color(0xFF212121),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.solidTrashAlt,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 32.0,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: Text(
                          'Delete this post? Its replies and likes will be removed too.',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ].divide(SizedBox(height: 12.0)),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xA831222D), Color(0x1EEBB7E7)],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.64, 1.0),
                        end: AlignmentDirectional(-0.64, -1.0),
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: FFButtonWidget(
                      onPressed: _model.isDeleting ? null : _deletePost,
                      text: _model.isDeleting ? 'Deleting...' : 'Delete',
                      options: FFButtonOptions(
                        width: 150.0,
                        height: 35.0,
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: Color(0x1DF1B2F0),
                        textStyle:
                            FlutterFlowTheme.of(context).bodyLarge.override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .fontStyle,
                                ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: Color(0x6CE0E3E7),
                        ),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: FFButtonWidget(
                      onPressed: _model.isDeleting
                          ? null
                          : () async {
                              Navigator.pop(context, false);
                            },
                      text: 'Cancel',
                      options: FFButtonOptions(
                        width: 150.0,
                        height: 35.0,
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: Colors.transparent,
                        textStyle:
                            FlutterFlowTheme.of(context).bodyLarge.override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .fontStyle,
                                ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: Color(0x6CE0E3E7),
                        ),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                ].divide(SizedBox(height: 12.0)),
              ),
            ].divide(SizedBox(height: 32.0)),
          ),
        ),
      ),
    );
  }
}
