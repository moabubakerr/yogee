import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/tag_pill.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'selectatag_model.dart';
export 'selectatag_model.dart';

class SelectatagWidget extends StatefulWidget {
  const SelectatagWidget({super.key});

  @override
  State<SelectatagWidget> createState() => _SelectatagWidgetState();
}

class _SelectatagWidgetState extends State<SelectatagWidget> {
  late SelectatagModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectatagModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 300.0,
        decoration: BoxDecoration(
          color: Color(0xAF000000),
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
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFF939393),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Icon(
                Icons.local_offer,
                color: FlutterFlowTheme.of(context).primary,
                size: 64.0,
              ),
              Text(
                'Choose \none tag',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                    ),
              ),
              Container(
                width: 530.0,
                decoration: BoxDecoration(),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 10.0, 10.0),
                  child: Builder(
                    builder: (context) {
                      final tags = FFAppState().tags.toList();

                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(tags.length, (tagsIndex) {
                          final tagsItem = tags[tagsIndex];
                          return TagPill(
                            tagsItem,
                            selected:
                                FFAppState().selectedtags.contains(tagsItem),
                            onTap: () async {
                              if (FFAppState()
                                  .selectedtags
                                  .contains(tagsItem)) {
                                FFAppState().removeFromSelectedtags(tagsItem);
                                safeSetState(() {});
                              } else {
                                FFAppState().addToSelectedtags(tagsItem);
                                safeSetState(() {});
                              }
                            },
                          );
                        }).divide(SizedBox(height: 12.0)),
                      );
                    },
                  ),
                ),
              ),
            ].divide(SizedBox(height: 20.0)),
          ),
        ),
      ),
    );
  }
}
