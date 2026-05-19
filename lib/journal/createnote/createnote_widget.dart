import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'createnote_model.dart';
export 'createnote_model.dart';

class CreatenoteWidget extends StatefulWidget {
  const CreatenoteWidget({super.key});

  @override
  State<CreatenoteWidget> createState() => _CreatenoteWidgetState();
}

class _CreatenoteWidgetState extends State<CreatenoteWidget> {
  late CreatenoteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatenoteModel());

    _model.notenameTextController ??= TextEditingController();
    _model.notenameFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 360.0,
        height: 580.0,
        decoration: BoxDecoration(
          color: Color(0xFF0A0A0A),
          boxShadow: [
            BoxShadow(
              blurRadius: 60.0,
              color: Color(0x66D4B8E8),
              offset: Offset(
                0.0,
                0.0,
              ),
              spreadRadius: 4.0,
            )
          ],
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional(1.0, -1.0),
                child: FlutterFlowIconButton(
                  borderRadius: 8.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.close_rounded,
                    color: FlutterFlowTheme.of(context).info,
                    size: 27.0,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                'Select journal type:',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.manrope(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                    ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.state = 'note';
                              safeSetState(() {});
                            },
                            child: Container(
                              width: 140.0,
                              height: 140.0,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 24.0,
                                    color: _model.state == 'note'
                                        ? Color(0x80D4B8E8)
                                        : Color(0x33D4B8E8),
                                    offset: Offset(0.0, 0.0),
                                    spreadRadius: 1.0,
                                  )
                                ],
                                color: _model.state == 'note'
                                    ? FlutterFlowTheme.of(context).primary
                                    : Color(0xFF161616),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.state == 'note'
                                      ? FlutterFlowTheme.of(context).primary
                                      : Color(0x33D6A8D8),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FFIcons.kobjectTraced,
                                    color: valueOrDefault<Color>(
                                      _model.state == 'note'
                                          ? Colors.black
                                          : Color(0xFFE6BCE5),
                                      Color(0xFFE6BCE5),
                                    ),
                                    size: 40.0,
                                  ),
                                  Text(
                                    'New Note',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: valueOrDefault<Color>(
                                            _model.state == 'note'
                                                ? Colors.black
                                                : Colors.white,
                                            Colors.white,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.state = 'voice';
                              safeSetState(() {});
                            },
                            child: Container(
                              width: 140.0,
                              height: 140.0,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 24.0,
                                    color: _model.state == 'voice'
                                        ? Color(0x80D4B8E8)
                                        : Color(0x33D4B8E8),
                                    offset: Offset(0.0, 0.0),
                                    spreadRadius: 1.0,
                                  )
                                ],
                                color: _model.state == 'voice'
                                    ? FlutterFlowTheme.of(context).primary
                                    : Color(0xFF161616),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.state == 'voice'
                                      ? FlutterFlowTheme.of(context).primary
                                      : Color(0x33D6A8D8),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 10.0, 4.0),
                                    child: Icon(
                                      FFIcons.kobject1Traced,
                                      color: valueOrDefault<Color>(
                                        _model.state == 'voice'
                                            ? Colors.black
                                            : Color(0xFFE6BCE5),
                                        Color(0xFFE6BCE5),
                                      ),
                                      size: 34.0,
                                    ),
                                  ),
                                  Text(
                                    'New Voice',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: valueOrDefault<Color>(
                                            _model.state == 'voice'
                                                ? Colors.black
                                                : Colors.white,
                                            Colors.white,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Give your journal a name:',
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x2FF1B2F0),
                                offset: Offset(
                                  0.0,
                                  0.0,
                                ),
                                spreadRadius: 3.0,
                              )
                            ],
                            gradient: LinearGradient(
                              colors: [
                                Colors.black,
                                Colors.black,
                                Color(0xC5000000)
                              ],
                              stops: [0.0, 0.5, 1.0],
                              begin: AlignmentDirectional(0.0, -1.0),
                              end: AlignmentDirectional(0, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(44.0),
                            border: Border.all(
                              color: Color(0xFF636363),
                            ),
                          ),
                          child: Container(
                            width: 250.0,
                            child: TextFormField(
                              controller: _model.notenameTextController,
                              focusNode: _model.notenameFocusNode,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                filled: true,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              cursorColor: FlutterFlowTheme.of(context).primary,
                              enableInteractiveSelection: true,
                              validator: _model.notenameTextControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 20.0)),
                    ),
                    FFButtonWidget(
                        onPressed: () async {
                          if (_model.state != 'notset') {
                            if (_model.state == 'voice') {
                              var writtenNoteRecordReference1 =
                                  WrittenNoteRecord.collection.doc();
                              await writtenNoteRecordReference1
                                  .set(createWrittenNoteRecordData(
                                name: _model.notenameTextController.text,
                                writer: currentUserReference,
                                isVoice: true,
                                time: getCurrentTimestamp,
                              ));
                              _model.voicenote =
                                  WrittenNoteRecord.getDocumentFromData(
                                      createWrittenNoteRecordData(
                                        name:
                                            _model.notenameTextController.text,
                                        writer: currentUserReference,
                                        isVoice: true,
                                        time: getCurrentTimestamp,
                                      ),
                                      writtenNoteRecordReference1);
                              Navigator.pop(context);

                              context.pushNamed(
                                CreatevoicenoteWidget.routeName,
                                queryParameters: {
                                  'note': serializeParam(
                                    _model.voicenote?.reference,
                                    ParamType.DocumentReference,
                                  ),
                                }.withoutNulls,
                              );
                            } else {
                              var writtenNoteRecordReference2 =
                                  WrittenNoteRecord.collection.doc();
                              await writtenNoteRecordReference2
                                  .set(createWrittenNoteRecordData(
                                name: _model.notenameTextController.text,
                                writer: currentUserReference,
                                isVoice: false,
                                time: getCurrentTimestamp,
                              ));
                              _model.note =
                                  WrittenNoteRecord.getDocumentFromData(
                                      createWrittenNoteRecordData(
                                        name:
                                            _model.notenameTextController.text,
                                        writer: currentUserReference,
                                        isVoice: false,
                                        time: getCurrentTimestamp,
                                      ),
                                      writtenNoteRecordReference2);
                              Navigator.pop(context);

                              context.pushNamed(
                                WritenoteWidget.routeName,
                                queryParameters: {
                                  'noteref': serializeParam(
                                    _model.note?.reference,
                                    ParamType.DocumentReference,
                                  ),
                                }.withoutNulls,
                              );
                            }

                            _model.state = 'notset';
                            safeSetState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Choose a journal type first',
                                  style: GoogleFonts.manrope(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                duration: Duration(milliseconds: 3000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 130),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            );
                          }

                          safeSetState(() {});
                        },
                        text: 'Create',
                        options: FFButtonOptions(
                          width: 200.0,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                    ),
                                    color: Colors.black,
                                    fontSize: 17.0,
                                    letterSpacing: 0.3,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                  ].divide(SizedBox(height: 32.0)),
                ),
              ),
            ].divide(SizedBox(height: 12.0)),
          ),
        ),
      ),
    );
  }
}
