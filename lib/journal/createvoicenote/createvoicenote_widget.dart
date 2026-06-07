import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/journal/deletenote/deletenote_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'createvoicenote_model.dart';
export 'createvoicenote_model.dart';

class CreatevoicenoteWidget extends StatefulWidget {
  const CreatevoicenoteWidget({
    super.key,
    required this.note,
  });

  final DocumentReference? note;

  static String routeName = 'createvoicenote';
  static String routePath = '/createvoicenote';

  @override
  State<CreatevoicenoteWidget> createState() => _CreatevoicenoteWidgetState();
}

class _CreatevoicenoteWidgetState extends State<CreatevoicenoteWidget> {
  late CreatevoicenoteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatevoicenoteModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await requestPermission(microphonePermission);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildVoiceMessage(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                font: GoogleFonts.manrope(fontWeight: FontWeight.w500),
                color: Colors.white,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: widget.note == null
            ? _buildVoiceMessage(context, 'This voice note could not be found.')
            : StreamBuilder<WrittenNoteRecord>(
          stream: WrittenNoteRecord.getDocument(widget.note!),
          builder: (context, snapshot) {
            // Surface stream errors instead of spinning forever.
            if (snapshot.hasError) {
              return _buildVoiceMessage(
                  context, 'Couldn\'t load this voice note. Please try again.');
            }
            // Customize what your widget looks like when it's loading.
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              );
            }

            final containerWrittenNoteRecord = snapshot.data!;

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(
                    'assets/images/journal_background.png',
                  ).image,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(JournalWidget.routeName);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chevron_left_rounded,
                                      color: Colors.white,
                                      size: 28.0,
                                    ),
                                    Text(
                                      'Back',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            font: GoogleFonts.manrope(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLarge
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Container(
                              width: 325.0,
                              height: 260.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Color(0xAE000000),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 30.0,
                                    color: Color(0x66D4B8E8),
                                    offset: Offset(0.0, 0.0),
                                    spreadRadius: 4.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.0, -1.0),
                                    child: Container(
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF392E39),
                                            Color(0xFF544454)
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.03, -1.0),
                                          end: AlignmentDirectional(-0.03, 1.0),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40.0),
                                          topRight: Radius.circular(40.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(40.0),
                                            ),
                                            child: Image.asset(
                                              'assets/images/Abstract_Shape_55_(white_on_transparent).png',
                                              width: 80.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              containerWrittenNoteRecord.name,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge
                                                                .fontStyle,
                                                      ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(1.0, 0.0),
                                            child: FlutterFlowIconButton(
                                              borderRadius: 8.0,
                                              buttonSize: 40.0,
                                              icon: FaIcon(
                                                FontAwesomeIcons.solidTrashAlt,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                                size: 20.0,
                                              ),
                                              onPressed: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  enableDrag: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: DeletenoteWidget(
                                                          note:
                                                              containerWrittenNoteRecord
                                                                  .reference,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                            ),
                                          ),
                                        ]
                                            .divide(SizedBox(width: 16.0))
                                            .addToEnd(SizedBox(width: 16.0)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF5A3E70),
                                            Color(0xFF2A1A35),
                                            Color(0xFF0A0A0A),
                                          ],
                                          stops: [0.0, 0.55, 1.0],
                                          begin: AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0.0, 1.0),
                                        ),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Transparent spacer to preserve the
                                          // Stack's two-child structure without
                                          // depending on the broken background
                                          // asset (had white padding baked in).
                                          SizedBox.expand(),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (_model.isrecording == true)
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Container(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFFE781E9),
                                                            Color(0xFFB7ABB7)
                                                          ],
                                                          stops: [0.2, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  1.0, 0.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  -1.0, 0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Text(
                                                          'REC',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (_model.isrecording == false)
                                                  Text(
                                                    'Press Record',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleLarge
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleLarge
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                if (_model.isrecording == true)
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: FlutterFlowTimer(
                                                      initialTime: _model
                                                          .timerInitialTimeMs,
                                                      getDisplayTime: (value) =>
                                                          StopWatchTimer
                                                              .getDisplayTime(
                                                                  value,
                                                                  milliSecond:
                                                                      false),
                                                      controller: _model
                                                          .timerController,
                                                      updateStateInterval:
                                                          Duration(
                                                              milliseconds:
                                                                  1000),
                                                      onChanged: (value,
                                                          displayTime,
                                                          shouldUpdate) {
                                                        _model.timerMilliseconds =
                                                            value;
                                                        _model.timerValue =
                                                            displayTime;
                                                        if (shouldUpdate)
                                                          safeSetState(() {});
                                                      },
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineSmall
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineSmall
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (_model.isrecording ==
                                                        false)
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          final hasExisting =
                                                              containerWrittenNoteRecord
                                                                      .voicenote !=
                                                                  '';
                                                          if (hasExisting) {
                                                            final confirm =
                                                                await showDialog<
                                                                    bool>(
                                                              context: context,
                                                              barrierColor: Color(
                                                                  0xCC000000),
                                                              builder: (ctx) {
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      Color(0xFF0A0A0A),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(28.0),
                                                                    side: BorderSide(
                                                                        color: Color(
                                                                            0x33D4B8E8),
                                                                        width:
                                                                            1.0),
                                                                  ),
                                                                  title: Text(
                                                                    'Replace existing recording?',
                                                                    style: GoogleFonts
                                                                        .plusJakartaSans(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      fontSize:
                                                                          20.0,
                                                                    ),
                                                                  ),
                                                                  content: Text(
                                                                    'Recording again will overwrite the saved audio for this note.',
                                                                    style: GoogleFonts
                                                                        .manrope(
                                                                      color: Color(
                                                                          0xFFD6A8D8),
                                                                      fontSize:
                                                                          14.0,
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              ctx,
                                                                              false),
                                                                      child:
                                                                          Text(
                                                                        'Cancel',
                                                                        style: GoogleFonts.manrope(
                                                                            color:
                                                                                Colors.white70,
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              ctx,
                                                                              true),
                                                                      child:
                                                                          Text(
                                                                        'Replace',
                                                                        style: GoogleFonts.manrope(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            fontWeight: FontWeight.w700),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                            if (confirm != true)
                                                              return;
                                                          }
                                                          await actions
                                                              .stopSong();
                                                          FFAppState()
                                                                  .isSongPlaying =
                                                              false;
                                                          safeSetState(() {});
                                                          await startAudioRecording(
                                                            context,
                                                            audioRecorder: _model
                                                                .audioRecorder ??= AudioRecorder(),
                                                          );

                                                          _model.isrecording =
                                                              true;
                                                          safeSetState(() {});
                                                          _model.timerController
                                                              .onResetTimer();
                                                          _model.timerController
                                                              .onStartTimer();
                                                        },
                                                        child: Container(
                                                          width: 88.0,
                                                          height: 88.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            color: Color(
                                                                0x33000000),
                                                            border: Border.all(
                                                              color: FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                              width: 3.0,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius:
                                                                    24.0,
                                                                color: Color(
                                                                    0x80D4B8E8),
                                                                offset: Offset(
                                                                    0.0, 0.0),
                                                                spreadRadius:
                                                                    2.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              width: 56.0,
                                                              height: 56.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                        0xFFE5C9F0),
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          1.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (_model.isrecording ==
                                                        true)
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          await stopAudioRecording(
                                                            audioRecorder: _model
                                                                .audioRecorder,
                                                            audioName:
                                                                'recordedFileBytes',
                                                            onRecordingComplete:
                                                                (audioFilePath,
                                                                    audioBytes) {
                                                              _model.voicenote =
                                                                  audioFilePath;
                                                              _model.recordedFileBytes =
                                                                  audioBytes;
                                                            },
                                                          );

                                                          _model.timerController
                                                              .onStopTimer();
                                                          _model.isrecording =
                                                              false;
                                                          safeSetState(() {});

                                                          await containerWrittenNoteRecord
                                                              .reference
                                                              .update(
                                                                  createWrittenNoteRecordData(
                                                            voicenote: _model
                                                                .voicenote,
                                                          ));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Voice note saved',
                                                                style:
                                                                    GoogleFonts
                                                                        .manrope(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      3000),
                                                              backgroundColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              margin: EdgeInsets
                                                                  .fromLTRB(
                                                                      16,
                                                                      0,
                                                                      16,
                                                                      130),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                              ),
                                                            ),
                                                          );

                                                          safeSetState(() {});
                                                        },
                                                        child: Container(
                                                          width: 88.0,
                                                          height: 88.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            color: Color(
                                                                0x33000000),
                                                            border: Border.all(
                                                              color: FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                              width: 3.0,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius:
                                                                    24.0,
                                                                color: Color(
                                                                    0x80D4B8E8),
                                                                offset: Offset(
                                                                    0.0, 0.0),
                                                                spreadRadius:
                                                                    2.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              width: 32.0,
                                                              height: 32.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6.0),
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                        0xFFE5C9F0),
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          1.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 8.0)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 20.0)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
