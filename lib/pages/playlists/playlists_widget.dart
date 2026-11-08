import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/meditation/secondaudioplayer/secondaudioplayer_widget.dart';
import '/pages/nav/nav_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'playlists_model.dart';
import '/custom_code/net_image.dart';
import '/custom_code/page_background.dart';
export 'playlists_model.dart';

class PlaylistsWidget extends StatefulWidget {
  const PlaylistsWidget({
    super.key,
    required this.playlist,
  });

  final DocumentReference? playlist;

  static String routeName = 'playlists';
  static String routePath = '/playlists';

  @override
  State<PlaylistsWidget> createState() => _PlaylistsWidgetState();
}

class _PlaylistsWidgetState extends State<PlaylistsWidget> {
  late PlaylistsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Same tokens as LibraryWidget, so a playlist opened from the Library looks
  // like it belongs to it.
  static const _lavender = Color(0xFFC39FC2);
  static const _accentPink = Color(0xFFFDC2FE);
  static const _pillBorder = Color(0xC2D4D2D2);
  static const _cardGlow = Color(0x3DCAA6CC);

  static const _fallbackCover =
      'https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/thumb.png?alt=media&token=e6577b33-e529-48be-8df3-6a94f5b68e16';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlaylistsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  TextStyle _manrope(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    Color? color,
    double letterSpacing = 0.0,
  }) =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.manrope(
              fontWeight: weight,
              fontStyle: FontStyle.normal,
            ),
            color: color,
            fontSize: size,
            letterSpacing: letterSpacing,
            fontWeight: weight,
            fontStyle: FontStyle.normal,
          );

  Widget _tappable({required Widget child, VoidCallback? onTap}) => InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: child,
      );

  /// Opens the queue player on this playlist. Used by "Play all" and by
  /// tapping any row.
  Future<void> _playPlaylist(PlaylistsRecord playlist) async {
    FFAppState().isPlaying = true;
    FFAppState().isSongPlaying = true;
    FFAppState().songslist = playlist.songsnum.toList().cast<int>();
    safeSetState(() {});
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: SecondaudioplayerWidget(songs: playlist.songsnum),
        ),
      ),
    ).then((value) => safeSetState(() {}));
  }

  Widget _backButton(BuildContext context) => _tappable(
        onTap: () => context.safePop(),
        // Plain row rather than FFButtonWidget: the button's 16pt internal
        // padding pushed "Back" in from the page gutter, out of line with
        // everything below it.
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 12.0, 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xDDFFFFFF),
                size: 16.0,
              ),
              const SizedBox(width: 6.0),
              Text(
                'Back',
                style: _manrope(
                  context,
                  size: 16.0,
                  weight: FontWeight.w500,
                  color: const Color(0xDDFFFFFF),
                ),
              ),
            ],
          ),
        ),
      );

  /// Matches LibraryWidget._actionPill, stretched to share the row.
  Widget _actionPill(
    BuildContext context, {
    required Widget icon,
    required String label,
    VoidCallback? onTap,
  }) =>
      _tappable(
        onTap: onTap,
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3A2F3B),
                Color(0xFF0B0B0C),
                Color(0xFF181818),
                Color(0xFF3A2F3B)
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: _pillBorder),
            boxShadow: const [
              BoxShadow(color: _cardGlow, blurRadius: 65.0),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8.0),
              Text(
                label,
                style: _manrope(
                  context,
                  size: 14.0,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      );

  /// Same proportions and type as the Library song rows.
  Widget _songRow(
    BuildContext context,
    SongsRecord song,
    PlaylistsRecord playlist,
  ) =>
      _tappable(
        onTap: () => _playPlaylist(playlist),
        child: Row(
          children: [
            if (functions.isValidUrl(song.songCoverImage) ?? true)
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: const Color(0xFF979797)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: NetImage(
                    valueOrDefault<String>(song.songCoverImage, _fallbackCover),
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _manrope(
                      context,
                      size: 15.0,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _manrope(
                      context,
                      size: 12.5,
                      weight: FontWeight.w300,
                      color: _lavender,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Color(0x99FFFFFF),
                        size: 11.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        song.duration,
                        style: _manrope(
                          context,
                          size: 10.5,
                          weight: FontWeight.w300,
                          color: const Color(0x99FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 0.0, 10.0),
              child: const Icon(
                Icons.more_horiz,
                color: Color(0xFFD9D9D9),
                size: 18.0,
              ),
            ),
          ],
        ),
      );

  Widget _loader(BuildContext context) => Center(
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

  @override
  Widget build(BuildContext context) {
    // Rebuild when the mini player opens/closes so the bottom inset follows.
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: StreamBuilder<PlaylistsRecord>(
          stream: PlaylistsRecord.getDocument(widget.playlist!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _loader(context);
            }

            final playlist = snapshot.data!;

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                image: kPageBackgroundImage,
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    primary: false,
                    // Bottom inset clears the nav (120) or nav + mini player
                    // (190), plus breathing room.
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.0,
                      48.0,
                      16.0,
                      FFAppState().miniplayer ? 210.0 : 140.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(top: 12.0),
                              child: _backButton(context),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Objectl.png',
                                // 173, same as the Library header logo.
                                width: 173.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28.0),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/playlists.png',
                              width: 110.0,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 20.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist.playlistName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: _manrope(
                                      context,
                                      size: 22.0,
                                      weight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Chew Lay',
                                    style: _manrope(
                                      context,
                                      size: 14.0,
                                      weight: FontWeight.w300,
                                      color: _lavender,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28.0),
                        Row(
                          children: [
                            Expanded(
                              child: _actionPill(
                                context,
                                icon: Image.asset(
                                  'assets/images/Object.png',
                                  width: 20.0,
                                  fit: BoxFit.contain,
                                ),
                                label: 'Play all',
                                onTap: () => _playPlaylist(playlist),
                              ),
                            ),
                            const SizedBox(width: 14.0),
                            Expanded(
                              child: _actionPill(
                                context,
                                icon: const Icon(
                                  Icons.file_download_outlined,
                                  color: _accentPink,
                                  size: 22.0,
                                ),
                                label: 'All',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28.0),
                        StreamBuilder<List<SongsRecord>>(
                          stream: querySongsRecord(
                            queryBuilder: (songsRecord) =>
                                songsRecord.whereIn('num', playlist.songsnum),
                            limit: 100,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return _loader(context);
                            }
                            final songs = snapshot.data!;
                            return Column(
                              children: [
                                for (final song in songs)
                                  _songRow(context, song, playlist),
                              ].divide(const SizedBox(height: 14.0)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: wrapWithModel(
                      model: _model.navModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const NavWidget(
                        pageindex: 5,
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
