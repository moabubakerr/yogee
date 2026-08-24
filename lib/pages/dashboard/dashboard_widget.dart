import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/courses/courses_widget.dart';
import '/pages/nav/nav_widget.dart';
import '/settings/notificationssettings/notificationssettings_widget.dart';
import '/settings/usernameset/usernameset_widget.dart';
import 'dart:ui';
import '/custom_code/card_stroke.dart';
import '/custom_code/album_card.dart';
import '/custom_code/ui_preview.dart';
import '/custom_code/net_image.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';

/// Figma: page base fill, #000000 -> #181818 top to bottom.
const _kPageBase = LinearGradient(
  begin: AlignmentDirectional(0.0, -1.0),
  end: AlignmentDirectional(0.0, 1.0),
  colors: [Color(0xFF000000), Color(0xFF181818)],
);

/// Figma: 49% plum vignette — dark through the middle, lifting at both edges.
const _kPageVignette = LinearGradient(
  begin: AlignmentDirectional(0.0, -1.0),
  end: AlignmentDirectional(0.0, 1.0),
  colors: [
    Color(0x7DC7A4C9),
    Color(0x6D957B97),
    Color(0x5E645265),
    Color(0x4E322932),
    Color(0x3E000000),
    Color(0x4E322932),
    Color(0x5E645265),
    Color(0x6D957B97),
    Color(0x7DC7A4C9),
  ],
  stops: [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0],
);

/// "Shade" layer that blacks the artwork out except for a narrow diagonal
/// window. This is what keeps the swirl from reading as a pale haze behind the
/// content.
///
/// Figma draws this at 239.5deg, running top-right to bottom-left. Mirrored
/// here, so the axis runs top-left to bottom-right instead: the artwork above
/// is no longer flipped, and the window has to lie along the same diagonal as
/// the swirl it is cutting. Flip the two x values back if the artwork's
/// mirror ever returns.
const _kPageShade = LinearGradient(
  begin: AlignmentDirectional(-1.0, -0.59),
  end: AlignmentDirectional(1.0, 0.59),
  colors: [
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0xDE000000),
    Color(0x8B000000),
    Color(0x05000000),
    Color(0x3A000000),
    Color(0x43000000),
    Color(0xF0000000),
    Color(0xFF000000),
    Color(0xFF000000),
  ],
  stops: [0.0, 0.099, 0.155, 0.242, 0.293, 0.424, 0.582, 0.81, 0.919, 1.0],
);

/// Figma: card fill is a vertical #000000 -> #181818 gradient.
const _kCardGradient = LinearGradient(
  begin: AlignmentDirectional(0.0, -1.0),
  end: AlignmentDirectional(0.0, 1.0),
  colors: [Color(0xFF000000), Color(0xFF181818)],
);

/// Figma: white -> pink sweep used on the streak card's unit labels.
const _kAccentGradient = LinearGradient(
  colors: [Color(0xFFFFFFFF), Color(0xFFF1B1EF)],
  stops: [0.081, 0.606],
);

// ---------------------------------------------------------------------------
// Layout metrics
//
// These come from the Figma frame. They are absolute because the design is
// absolute: the block keeps its size on every screen and is centred, rather
// than stretching (which would change the gap-to-card ratio the design
// depends on). Only _kShortcutRowHeight is derived -- see the note there.
// ---------------------------------------------------------------------------

/// The 2x2 shortcut grid beside the streak card.
const double _kShortcutGridWidth = 230.0;

/// The streak ("You Meditated") card beside the grid.
const double _kStreakCardWidth = 120.0;

/// Gap between the grid and the streak card. Must match the
/// `.divide(SizedBox(width: ...))` applied to that Row.
const double _kShortcutRowGap = 14.0;

/// Spacing between grid cells.
const double _kCellCrossSpacing = 7.0;
const double _kCellMainSpacing = 9.0;

/// Each shortcut card. The grid's childAspectRatio is width/height.
const double _kShortcutCardWidth = 125.0;
const double _kShortcutCardHeight = 112.0;
const double _kCellAspect = _kShortcutCardWidth / _kShortcutCardHeight;

/// Height the icon and label sizes below were drawn against.
///
/// The block is zoomed to the screen width by a FittedBox, so widening it
/// scales everything inside automatically. Height is the one dimension that
/// does not: a taller card at the same width just gains slack around its
/// contents. [_kShortcutContentScale] closes that gap -- every icon and label
/// in the grid is expressed as its design size times this factor, so changing
/// [_kShortcutCardHeight] moves the artwork and type with the card instead of
/// leaving them stranded at their old size.
const double _kShortcutContentDesignHeight = 107.0;
const double _kShortcutContentScale =
    _kShortcutCardHeight / _kShortcutContentDesignHeight;

/// Height of the grid + streak card row.
///
/// Derived, not hard-coded: two rows of cells at [_kCellAspect] plus the gap
/// between them. The streak card used to carry a hand-tuned 203 that stopped
/// matching the grid as soon as anything else moved.
const double _kShortcutCellWidth =
    (_kShortcutGridWidth - _kCellCrossSpacing) / 2.0;
const double _kShortcutRowHeight =
    _kShortcutCellWidth / _kCellAspect * 2.0 + _kCellMainSpacing;

/// Full design width of that row: grid + gap + streak card.
const double _kShortcutRowWidth =
    _kShortcutGridWidth + _kShortcutRowGap + _kStreakCardWidth;

/// Ceiling on how wide the block is allowed to grow, ~1.3x the design.
///
/// The row scales to whatever width it is given, so without a cap an iPad's
/// ~990pt of content width would render it at 2.7x -- correct proportions,
/// absurd size. At 480 a tablet shows a comfortably large block with margin,
/// while every phone (320-440pt) stays under the cap and fills the width.
const double _kShortcutRowMaxWidth = 480.0;

/// Header avatar.
const double _kAvatarSize = 70.0;

/// Cube artwork on the streak card.
const double _kStreakCubeWidth = 75.0;

/// Breathing room under "Hours"/"Mins" inside the streak card.
const double _kStreakCardBottomPad = 14.0;

/// "New Meditations" carousel.
///
/// There is deliberately no height constant. The row sizes itself to the
/// tallest card, so changing the album-name font size moves the card height
/// with it. A fixed 160 used to clip the labels the moment the title grew.
const double _kCarouselItemWidth = 145.0;

// The stroke weight, cover inset, cover size and text gap that used to live
// here now belong to AlbumCard (lib/custom_code/album_card.dart), which the
// Meditate page shares. Width is still set per page, and the art derives from
// it via albumCoverSize().

/// Cover inset for the carousel, wider than [kAlbumCoverInset] by 2.5 a side.
///
/// That is 5pt off the artwork's edge with the card unchanged: these tiles sit
/// against the page's own artwork rather than in a grid of their own, and the
/// extra margin keeps them from reading as edge-to-edge photos. The Meditate
/// grid keeps the shared default.
const double _kCarouselCoverInset = kAlbumCoverInset + 2.5;

/// Height reserved while the albums query is in flight, so the section does
/// not visibly jump when the real cards replace the spinner. Approximate on
/// purpose -- it is a placeholder, not a layout constraint.
const double _kCarouselLoadingHeight = 159.0;

/// The column every top-level block on this page sits in.
///
/// Full width up to [_kShortcutRowMaxWidth], then centred. The header row and
/// the shortcut block both use it, which is what keeps the avatar's left edge
/// on the first shortcut card's left edge: the shortcut block is capped and
/// centred, so a header that merely padded by the same amount would line up on
/// a phone and drift apart on anything wider than 512pt (480 + 2 * 16).
///
/// Pair it with the same horizontal padding at both call sites.
class _PageColumn extends StatelessWidget {
  const _PageColumn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SizedBox(
            width: constraints.maxWidth.clamp(0.0, _kShortcutRowMaxWidth),
            child: child,
          ),
        ),
      );
}

/// Paints [text] with [_kAccentGradient] instead of a flat colour.
class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => _kAccentGradient.createShader(
          Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height),
        ),
        child: Text(text, style: style),
      );
}

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'Dashboard';
  static String routePath = '/dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // In UI-preview builds there is no signed-in user, so the username
      // prompt would fire every launch and cover the page being inspected.
      if (!kUiPreview &&
          (valueOrDefault(currentUserDocument?.username, '') == null ||
              valueOrDefault(currentUserDocument?.username, '') == '')) {
        await actions.initAudioPlayer();
        await showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.black,
          barrierColor: Colors.black,
          enableDrag: false,
          context: context,
          builder: (context) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Padding(
                padding: MediaQuery.viewInsetsOf(context),
                child: UsernamesetWidget(),
              ),
            );
          },
        ).then((value) => safeSetState(() {}));

        safeSetState(() {});
      } else {
        await actions.initAudioPlayer();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _kPageBase,
          ),
          child: Stack(
            children: [
              // The asset's own orientation, no longer mirrored: the stripe
              // reads right-to-left, which is the direction asked for. The
              // scaleX: -1 that used to sit here flipped it left-to-right.
              //
              // If this comes back, _kPageShade has to flip with it -- its
              // window is cut on the same diagonal, and mirroring one layer
              // without the other leaves the bright band off the swirl.
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Background2.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: _kPageVignette),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: _kPageShade),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 90.0),
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              MediaQuery.paddingOf(context).top + 12.0,
                              16.0,
                              0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FlutterFlowIconButton(
                                borderRadius: 8.0,
                                buttonSize: 30.0,
                                icon: Icon(
                                  FFIcons.knotificationSvg,
                                  color: Color(0xFFC19EC3),
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Color(0xB2000000),
                                    barrierColor: Color(0xB4000000),
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: NotificationssettingsWidget(),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                              ),
                              FlutterFlowIconButton(
                                borderRadius: 8.0,
                                buttonSize: 30.0,
                                icon: Icon(
                                  FFIcons.kobject,
                                  color: Color(0xFFC19EC3),
                                  size: 20.0,
                                ),
                                onPressed: () async {
                                  context.pushNamed(SettingsWidget.routeName);
                                },
                              ),
                            ].divide(SizedBox(width: 2.0)),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          // 16, matching the shortcut block below, not the 24
                          // this used to carry: the avatar's left edge has to
                          // land on the first shortcut card's.
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: _PageColumn(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context
                                    .pushNamed(MyprofilepageWidget.routeName);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 30.0,
                                              color: Color(0x8DF1B2F0),
                                              offset: Offset(
                                                0.0,
                                                0.0,
                                              ),
                                            )
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Visibility(
                                          visible: functions.isValidUrl(
                                                  currentUserPhoto) ??
                                              true,
                                          child: AuthUserStreamWidget(
                                            builder: (context) => Container(
                                              width: _kAvatarSize,
                                              height: _kAvatarSize,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: NetImage(
                                                valueOrDefault<String>(
                                                  currentUserPhoto,
                                                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                                ),
                                                // Matches the 68x68 Container
                                                // above. Stated explicitly so the
                                                // decode cap is derived from the
                                                // real size, not the fallback
                                                // ceiling.
                                                width: _kAvatarSize,
                                                height: _kAvatarSize,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.asset(
                                              'assets/images/ppppppp.png',
                                              width: 80.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          AuthUserStreamWidget(
                                            builder: (context) => Text(
                                              valueOrDefault<String>(
                                                currentUserDisplayName,
                                                'Displayname',
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .headlineSmall
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineSmall
                                                              .fontStyle,
                                                    ),
                                                    fontSize: 17.0,
                                                    letterSpacing: 0.25,
                                                    fontWeight: FontWeight.w800,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .headlineSmall
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                          AuthUserStreamWidget(
                                            builder: (context) => Text(
                                              valueOrDefault<String>(
                                                valueOrDefault(
                                                    currentUserDocument
                                                        ?.username,
                                                    ''),
                                                'Username',
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontStyle,
                                                    ),
                                                    color: Color(0xFFC8A2C8),
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w300,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ].divide(SizedBox(width: 8.0)),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: Image.asset(
                                        'assets/images/soverin_badge2.png',
                                        width: 230.0,
                                        fit: BoxFit.cover,
                                        alignment: Alignment(-1.0, -1.0),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 6.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 36.0, 16.0, 0.0),
                          // The design is absolute: 364pt wide, fixed gaps.
                          // Letting the halves flex would keep the block
                          // filling the screen but change the gap-to-card
                          // ratio the design depends on -- gaps stay 7/9/14
                          // while cards grow, so at tablet width the cards
                          // nearly touch.
                          //
                          // So instead the whole block is zoomed: laid out at
                          // its design size, then scaled to whatever width is
                          // available, up or down. Every proportion inside --
                          // gaps, radii, artwork, type -- moves together, so
                          // the block reads the same on a 320pt phone as on a
                          // 430pt one, always filling the width between the
                          // 16pt margins and always centred.
                          //
                          // The cap stops it running away on tablets, where
                          // filling ~990pt would mean a 2.7x zoom.
                          //
                          // Nothing can overflow: no clipping, no horizontal
                          // scroll, the geometry is identical at every size.
                          //
                          // Only the row height is derived, from the grid's own
                          // childAspectRatio, so the card always matches the
                          // grid beside it instead of the hand-tuned 203 it
                          // used to carry.
                          child: _PageColumn(
                            child:
                                // A fixed-size design cannot absorb a 2x system
                                // font scale; clamp it so the cell labels stay
                                // inside their cards.
                                // ponytail: clamp at 1.3, revisit if a real user
                                // needs larger -- that means a reflowing layout.
                                MediaQuery.withClampedTextScaling(
                              maxScaleFactor: 1.3,
                              child: FittedBox(
                                // fitWidth, not scaleDown: it scales up as
                                // well, so wide screens get a bigger block
                                // rather than a small one adrift in margin.
                                fit: BoxFit.fitWidth,
                                child: SizedBox(
                                  width: _kShortcutRowWidth,
                                  height: _kShortcutRowHeight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // Bounded height above, so the card is
                                    // stretched to match the grid exactly.
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        width: _kShortcutGridWidth,
                                        child: GridView(
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing:
                                                _kCellCrossSpacing,
                                            mainAxisSpacing: _kCellMainSpacing,
                                            childAspectRatio: _kCellAspect,
                                          ),
                                          primary: false,
                                          shrinkWrap: true,
                                          // The height is exact, so the grid must
                                          // not also become a scrollable that
                                          // competes with the page.
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                      MeditationWidget
                                                          .routeName);
                                                },
                                                child: Container(
                                                  width: _kShortcutCardWidth,
                                                  height: _kShortcutCardHeight,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 24.0,
                                                        color:
                                                            Color(0x33D4B8E8),
                                                        offset:
                                                            Offset(0.0, 0.0),
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    gradient: _kCardGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                  foregroundDecoration:
                                                      const GradientStroke(
                                                          radius: 6.0),
                                                  padding: const EdgeInsets.all(
                                                      kCardStrokeWidth),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.asset(
                                                          'assets/images/mediate.png',
                                                          width: 35.0 *
                                                              _kShortcutContentScale,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Meditations',
                                                        // Fixed-width cell: one line, never wrap.
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize: 12.0 *
                                                                      _kShortcutContentScale,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 4.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                      JournalWidget.routeName);
                                                },
                                                child: Container(
                                                  width: _kShortcutCardWidth,
                                                  height: _kShortcutCardHeight,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 24.0,
                                                        color:
                                                            Color(0x33D4B8E8),
                                                        offset:
                                                            Offset(0.0, 0.0),
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    gradient: _kCardGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                  foregroundDecoration:
                                                      const GradientStroke(
                                                          radius: 6.0),
                                                  padding: const EdgeInsets.all(
                                                      kCardStrokeWidth),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.asset(
                                                          'assets/images/jornal.png',
                                                          width: 30.0 *
                                                              _kShortcutContentScale,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Journal',
                                                        // Fixed-width cell: one line, never wrap.
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize: 12.0 *
                                                                      _kShortcutContentScale,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 4.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                      CommunityWidget
                                                          .routeName);
                                                },
                                                child: Container(
                                                  width: _kShortcutCardWidth,
                                                  height: _kShortcutCardHeight,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 24.0,
                                                        color:
                                                            Color(0x33D4B8E8),
                                                        offset:
                                                            Offset(0.0, 0.0),
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    gradient: _kCardGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                  foregroundDecoration:
                                                      const GradientStroke(
                                                          radius: 6.0),
                                                  padding: const EdgeInsets.all(
                                                      kCardStrokeWidth),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.asset(
                                                          'assets/images/community.png',
                                                          width: 32.0 *
                                                              _kShortcutContentScale,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Community',
                                                        // Fixed-width cell: one line, never wrap.
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize: 12.0 *
                                                                      _kShortcutContentScale,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 4.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Color(0x81000000),
                                                    barrierColor:
                                                        Color(0x7E000000),
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
                                                          child:
                                                              CoursesWidget(),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                },
                                                child: Container(
                                                  width: _kShortcutCardWidth,
                                                  height: _kShortcutCardHeight,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 24.0,
                                                        color:
                                                            Color(0x33D4B8E8),
                                                        offset:
                                                            Offset(0.0, 0.0),
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    gradient: _kCardGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                  foregroundDecoration:
                                                      const GradientStroke(
                                                          radius: 6.0),
                                                  padding: const EdgeInsets.all(
                                                      kCardStrokeWidth),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.asset(
                                                          'assets/images/courses.png',
                                                          width: 27.0 *
                                                              _kShortcutContentScale,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Courses',
                                                        // Fixed-width cell: one line, never wrap.
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize: 12.0 *
                                                                      _kShortcutContentScale,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 4.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: _kStreakCardWidth,
                                        child: Container(
                                          // Height comes from the Row's stretch,
                                          // i.e. rowHeight above -- derived from
                                          // the grid's aspect ratio rather than
                                          // the hand-tuned 203 this used to
                                          // hard-code.
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 32.0,
                                                color: Color(0x66D4B8E8),
                                                offset: Offset(0.0, 0.0),
                                                spreadRadius: 1.0,
                                              ),
                                            ],
                                            // Figma: 172.8deg translucent plum wash.
                                            gradient: LinearGradient(
                                              begin: AlignmentDirectional(
                                                  -0.13, -1.0),
                                              end: AlignmentDirectional(
                                                  0.13, 1.0),
                                              colors: [
                                                Color(0x911E131E),
                                                Color(0x916B546B)
                                              ],
                                              stops: [0.172, 1.0],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          foregroundDecoration:
                                              const GradientStroke(
                                                  radius: 12.0),
                                          padding: const EdgeInsets.all(
                                              kCardStrokeWidth),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Container(
                                              // Figma (streakcard_gradient.png):
                                              // #0C8185 and #0D7F83, both at
                                              // 0.01% opacity, ramping into
                                              // solid #3D2C3C. The teals are
                                              // invisible in themselves but
                                              // steer the interpolation, so
                                              // the fade carries a cool cast
                                              // rather than being plum all
                                              // the way down, which is what
                                              // this used to paint.
                                              //
                                              // Caveat, if this reads too
                                              // green on device: Flutter
                                              // interpolates gradient stops
                                              // UNPREMULTIPLIED (Skia's
                                              // kInterpolateColorsInPremul is
                                              // not set by ui.Gradient), so a
                                              // 0-alpha stop still tints the
                                              // midtones. Figma and CSS
                                              // interpolate premultiplied,
                                              // where it contributes no hue
                                              // at all. Same numbers, two
                                              // different pictures. Revert to
                                              // Color(0x003D2C3C) as the
                                              // first stop to get the old
                                              // plum-to-plum ramp back.
                                              //
                                              // The second teal is dropped:
                                              // the panel gives stop opacity,
                                              // not position, and at the same
                                              // hue and alpha as the first it
                                              // has nothing to add.
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: AlignmentDirectional(
                                                      0.0, 1.0),
                                                  end: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  colors: [
                                                    Color(0x000C8185),
                                                    Color(0xFF3D2C3C)
                                                  ],
                                                  stops: [0.118, 0.736],
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0.0, 4.0, 0.0,
                                                        _kStreakCardBottomPad),
                                                // Bottom padding 14, not 0: the mockup leaves
                                                // about that much room under "Hours"/"Mins".
                                                // It sits OUTSIDE the FittedBox, so it is real
                                                // space rather than something the scale-down
                                                // eats -- the content shrinks slightly to make
                                                // room instead of running to the card's edge.
                                                //
                                                // The contents used to fit this card by
                                                // about four pixels, and the ClipRRect
                                                // above silently sliced off anything
                                                // over -- which is why "Hours"/"Mins"
                                                // appeared cut in half instead of
                                                // showing an overflow warning.
                                                // scaleDown shrinks the whole block
                                                // uniformly only when it does not fit,
                                                // so the design's internal proportions
                                                // survive and nothing is ever clipped.
                                                child: LayoutBuilder(
                                                  builder: (context,
                                                          cardConstraints) =>
                                                      FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    // FittedBox hands its child
                                                    // unbounded constraints. The
                                                    // SizedBox restores a real width so
                                                    // the spaceEvenly Row below still
                                                    // distributes across the card
                                                    // instead of collapsing onto itself.
                                                    child: SizedBox(
                                                      width: cardConstraints
                                                          .maxWidth,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.asset(
                                                              'assets/images/cube2.png',
                                                              width:
                                                                  _kStreakCubeWidth,
                                                              fit: BoxFit.cover,
                                                              alignment:
                                                                  Alignment(0.0,
                                                                      -1.0),
                                                            ),
                                                          ),
                                                          Text(
                                                            'You Meditated',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      10.0,
                                                                  letterSpacing:
                                                                      0.15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        8.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              // .min, not .max: height is
                                                              // unbounded inside the FittedBox
                                                              // above, and .max against an
                                                              // infinite height is a layout
                                                              // error.
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                AuthUserStreamWidget(
                                                                  builder:
                                                                      (context) =>
                                                                          Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      // currentUserDocument is
                                                                      // null until the first
                                                                      // authenticatedUserStream
                                                                      // emission. That stream is
                                                                      // a broadcast stream, so it
                                                                      // does not replay to late
                                                                      // listeners, and this
                                                                      // builder runs before the
                                                                      // first event. Fall through
                                                                      // to the default instead of
                                                                      // asserting non-null.
                                                                      currentUserDocument?.createdTime ==
                                                                              null
                                                                          ? null
                                                                          : formatNumber(
                                                                              functions.dayscounter(currentUserDocument!.createdTime!, getCurrentTimestamp),
                                                                              formatType: FormatType.compact,
                                                                            ),
                                                                      '24',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .displaySmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.plusJakartaSans(
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).displaySmall.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              38.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w800,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .displaySmall
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                                _GradientText(
                                                                  'Days',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .fontStyle,
                                                                        lineHeight:
                                                                            1.0,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          AuthUserStreamWidget(
                                                            builder:
                                                                (context) =>
                                                                    Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                // Same null-until-first-emission
                                                                // guard as the day counter above.
                                                                currentUserDocument
                                                                            ?.createdTime ==
                                                                        null
                                                                    ? null
                                                                    : functions.hoursMinutesCounter(
                                                                        currentUserDocument!
                                                                            .createdTime!,
                                                                        getCurrentTimestamp),
                                                                '07     25',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleLarge
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleLarge
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        19.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleLarge
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              _GradientText(
                                                                'Hours',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          11.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.0,
                                                                    ),
                                                              ),
                                                              _GradientText(
                                                                'Mins',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          11.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.0,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: _kShortcutRowGap)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  'New Meditations',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .fontStyle,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0,
                                        letterSpacing: 0.2,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              // No height: the Row below reports the tallest
                              // card, so the section grows with its text.
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 40.0,
                                    color: Color(0x30D4B8E8),
                                    offset: Offset(0.0, 2.0),
                                  ),
                                ],
                              ),
                              child: StreamBuilder<List<AlbumsRecord>>(
                                stream: queryAlbumsRecord(
                                  limit: 5,
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return SizedBox(
                                      // The parent no longer fixes a height,
                                      // so the placeholder has to state one.
                                      height: _kCarouselLoadingHeight,
                                      child: Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<AlbumsRecord> listViewAlbumsRecordList =
                                      snapshot.data!;

                                  // A Row, not a ListView: a horizontal
                                  // ListView demands a bounded height from its
                                  // parent, which is exactly the fixed height
                                  // that clipped the labels. A Row reports the
                                  // tallest card instead, so the section
                                  // follows its own text. The query is
                                  // limit: 5, so building all of them eagerly
                                  // costs nothing.
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.fromLTRB(
                                      16.0,
                                      0,
                                      0,
                                      0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: listViewAlbumsRecordList
                                          .map((listViewAlbumsRecord) {
                                            return Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(3.0, 3.0, 3.0, 3.0),
                                              child: AlbumCard(
                                                width: _kCarouselItemWidth,
                                                coverInset:
                                                    _kCarouselCoverInset,
                                                title: listViewAlbumsRecord
                                                    .albumName,
                                                artist:
                                                    listViewAlbumsRecord.artist,
                                                coverUrl:
                                                    valueOrDefault<String>(
                                                  listViewAlbumsRecord
                                                      .coverImage,
                                                  'https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/Square.jpeg?alt=media&token=6bb95a92-ae29-4638-9326-8ad36bcfaff0',
                                                ),
                                                onTap: () => context.pushNamed(
                                                  DetailPageWidget.routeName,
                                                  queryParameters: {
                                                    'album': serializeParam(
                                                      listViewAlbumsRecord
                                                          .reference,
                                                      ParamType
                                                          .DocumentReference,
                                                    ),
                                                  }.withoutNulls,
                                                ),
                                              ),
                                            );
                                          })
                                          .toList()
                                          .divide(SizedBox(width: 1.0)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ].divide(SizedBox(height: 6.0)),
                        ),
                      ),
                    ]
                        .addToStart(SizedBox(height: 8.0))
                        .addToEnd(SizedBox(height: 120.0)),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NavWidget(
                    pageindex: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
