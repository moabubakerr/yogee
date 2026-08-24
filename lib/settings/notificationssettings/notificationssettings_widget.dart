import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'notificationssettings_model.dart';
export 'notificationssettings_model.dart';

class NotificationssettingsWidget extends StatefulWidget {
  const NotificationssettingsWidget({super.key});

  @override
  State<NotificationssettingsWidget> createState() =>
      _NotificationssettingsWidgetState();
}

class _NotificationssettingsWidgetState
    extends State<NotificationssettingsWidget> with WidgetsBindingObserver {
  late NotificationssettingsModel _model;

  /// Null until the first read lands. The row draws nothing while null rather
  /// than guessing -- a wrong guess would flash "turn this on" at a user who
  /// already has it on.
  actions.PushPermission? _push;

  /// True while the OS prompt is up, so the button cannot be tapped twice.
  bool _requesting = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationssettingsModel());

    // READ ONLY. This screen used to fire the OS prompt here, on open, which
    // spent it on anyone who merely came to look at their options: iOS shows
    // that prompt exactly once per install, ever, and a "Don't Allow" tapped
    // to dismiss an unexpected dialog kills push permanently. The prompt now
    // fires from the button in _pushStatusRow, which the user has to choose.
    // See docs/fcm-push-plan.md, Step 6.
    WidgetsBinding.instance.addObserver(this);
    _loadPushStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.maybeDispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-read on resume. Permission can change in the OS settings while the
    // app sits in the background, and that is the ONLY way back from denied --
    // so it is the case that matters most. Nothing notifies the app when it
    // happens; re-reading here is the whole mechanism.
    if (state == AppLifecycleState.resumed) {
      _loadPushStatus();
    }
  }

  Future<void> _loadPushStatus() async {
    final status = await actions.pushPermissionStatus();
    if (!mounted) return;
    safeSetState(() => _push = status);
  }

  Future<void> _turnOnPush() async {
    safeSetState(() => _requesting = true);
    // Ignores the bool this returns on purpose: it reports whether a TOKEN was
    // written, and on iOS the APNs token can lag the grant by a moment. Asking
    // the OS what the permission is now is the honest answer either way.
    await actions.requestPushPermission();
    await _loadPushStatus();
    if (mounted) safeSetState(() => _requesting = false);
  }

  /// Permission state, and the one action that can change it.
  ///
  /// Without this the screen was a silent failure: a user who had refused saw
  /// exactly what a user who had granted saw, two working-looking checkboxes,
  /// and nothing ever arrived.
  Widget _pushStatusRow(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final push = _push;
    if (push == null) return SizedBox.shrink();

    final granted = push == actions.PushPermission.granted;
    final denied = push == actions.PushPermission.denied;

    final label = switch (push) {
      actions.PushPermission.granted => 'Push notifications are on',
      actions.PushPermission.notAsked => 'Push notifications are off',
      actions.PushPermission.denied => 'Blocked in system settings',
    };

    return Container(
      // minHeight, not the fixed 40 the rows below use: "Blocked in system
      // settings" plus a button wraps to two lines on a narrow phone, and a
      // fixed height would clip it.
      constraints: BoxConstraints(minHeight: 40.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x76B5B5B5),
            offset: Offset(-0.5, -0.5),
            spreadRadius: 0.5,
          )
        ],
        gradient: LinearGradient(
          colors: [Color(0xFF181818), Colors.black],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.64, 1.0),
          end: AlignmentDirectional(-0.64, -1.0),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              granted
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: denied ? theme.error : (granted ? theme.primary : theme.secondaryText),
              size: 24.0,
            ),
            Expanded(
              child: Text(
                label,
                style: theme.bodySmall.override(
                  font: GoogleFonts.manrope(),
                  color: denied ? theme.error : null,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            if (granted)
              Icon(Icons.check_rounded, color: theme.primary, size: 20.0)
            else
              FFButtonWidget(
                // notAsked spends the one-shot prompt; denied cannot re-prompt
                // at all, so it can only hand the user off to the OS.
                onPressed: _requesting
                    ? null
                    : (denied ? actions.openPushSettings : _turnOnPush),
                text: denied ? 'Open Settings' : 'Turn on',
                options: FFButtonOptions(
                  height: 28.0,
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Color(0x1DF1B2F0),
                  textStyle: theme.bodySmall.override(
                    font: GoogleFonts.manrope(),
                    letterSpacing: 0.0,
                  ),
                  elevation: 0.0,
                  borderSide: BorderSide(color: Color(0x6CE0E3E7)),
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
          ].divide(SizedBox(width: 4.0)),
        ),
      ),
    );
  }

  /// One preference switch.
  ///
  /// Extracted rather than copied: the markup below existed twice already and
  /// this screen now needs it three times.
  ///
  /// Deliberately stays tappable when push permission is off. The switch is a
  /// stored preference that survives until permission is granted, and the row
  /// directly above already says in as many words that nothing is arriving --
  /// so disabling these would remove a working control to repeat a message
  /// that is on screen anyway.
  Widget _prefRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required Future<void> Function() onToggle,
    String? subtitle,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      // Fixed 40 without a subtitle, so the rows that have none keep the
      // original rhythm; a minimum with one, because two lines do not fit.
      height: subtitle == null ? 40.0 : null,
      constraints: subtitle == null ? null : BoxConstraints(minHeight: 48.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x76B5B5B5),
            offset: Offset(-0.5, -0.5),
            spreadRadius: 0.5,
          )
        ],
        gradient: LinearGradient(
          colors: [Color(0xFF181818), Colors.black],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.64, 1.0),
          end: AlignmentDirectional(-0.64, -1.0),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: theme.primary, size: 24.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.manrope(),
                      letterSpacing: 0.0,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.labelSmall.override(
                        font: GoogleFonts.manrope(),
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                ],
              ),
            ),
            ToggleIcon(
              onPressed: onToggle,
              value: value,
              onIcon: Icon(
                Icons.check_box,
                color: theme.primary,
                size: 24.0,
              ),
              offIcon: Icon(
                Icons.check_box_outline_blank,
                color: theme.secondaryText,
                size: 24.0,
              ),
            ),
          ].divide(SizedBox(width: 4.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 330.0,
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
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 40.0),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.asset(
                  'assets/images/notificationicon.png',
                  height: 72.9,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Notifications',
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
              // Above the preference toggles on purpose: OS permission gates
              // every one of them, so it is the first thing to read.
              _pushStatusRow(context),
              StreamBuilder<UsersRecord>(
                stream: UsersRecord.getDocument(currentUserReference!),
                builder: (context, snapshot) {
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

                  final containerUsersRecord = snapshot.data!;

                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20.0,
                          color: Color(0x3FF1B2F0),
                          offset: Offset(
                            0.0,
                            2.0,
                          ),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // One switch for all four social types, not one each.
                        // They are the same promise from the user's side --
                        // "tell me when someone interacts with me" -- and four
                        // near-identical rows mostly teach people to turn the
                        // lot off. The subtitle is what keeps it honest about
                        // what it covers.
                        _prefRow(
                          context,
                          icon: Icons.favorite_border,
                          label: 'Social notifications',
                          subtitle: 'Likes, replies and new followers',
                          value: containerUsersRecord.notifySocial,
                          onToggle: () =>
                              containerUsersRecord.reference.update({
                            ...mapToFirestore({
                              'notify_social':
                                  !containerUsersRecord.notifySocial,
                            }),
                          }),
                        ),
                        // The original two, kept as they were. Nothing sends
                        // either category yet -- `socialPushMuted` in
                        // firebase/functions/notification_type.js gates only
                        // the four social types -- so these persist a
                        // preference for a sender that does not exist. They
                        // also default to false, unlike the row above, which is
                        // right for a category the user has never been offered.
                        _prefRow(
                          context,
                          icon: Icons.speaker_phone,
                          label: 'New releases and announcements',
                          value: containerUsersRecord.announcementNotification,
                          onToggle: () =>
                              containerUsersRecord.reference.update({
                            ...mapToFirestore({
                              'announcement_notification':
                                  !containerUsersRecord.announcementNotification,
                            }),
                          }),
                        ),
                        _prefRow(
                          context,
                          icon: Icons.speaker_phone,
                          label: 'App updates',
                          value: containerUsersRecord.appupdateNotifications,
                          onToggle: () =>
                              containerUsersRecord.reference.update({
                            ...mapToFirestore({
                              'appupdate_notifications':
                                  !containerUsersRecord.appupdateNotifications,
                            }),
                          }),
                        ),
                      ].divide(SizedBox(height: 4.0)),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF352B36), Color(0xFF745F75)],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.64, 1.0),
                    end: AlignmentDirectional(-0.64, -1.0),
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: FFButtonWidget(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  // Was "Save changes", which implied unsaved state that never
                  // existed -- every switch writes to Firestore on tap, and
                  // this button only ever popped the dialog.
                  text: 'Done',
                  options: FFButtonOptions(
                    height: 35.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: Color(0x1DF1B2F0),
                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                    elevation: 0.0,
                    borderSide: BorderSide(
                      color: Color(0x6CE0E3E7),
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
            ].divide(SizedBox(height: 32.0)),
          ),
        ),
      ),
    );
  }
}
