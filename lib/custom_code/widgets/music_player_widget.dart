// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import '/app_state.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import '/custom_code/actions/init_audio_player.dart';

class MusicPlayerWidget extends StatefulWidget {
  final List<SongsRecord> playlist;
  final int initialIndex;
  final double width;
  final double height;
  final String sliderThumbAssetPath;

  const MusicPlayerWidget({
    Key? key,
    required this.playlist,
    required this.initialIndex,
    this.width = double.infinity,
    this.height = 500,
    required this.sliderThumbAssetPath,
  }) : super(key: key);

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  // FIX 1: Do NOT access AudioManager.instance as a field initializer.
  // It is `static late` and throws LateInitializationError if initAudioPlayer()
  // hasn't finished yet, causing a white screen. Use nullable + async setup instead.
  AudioPlayerHandler? _audio;
  SongsRecord? _currentSong;
  StreamSubscription? _indexSubscription;
  final Color _primaryColor = const Color(0xFFE0A4F0);

  final String pyramidImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/thumb.png?alt=media&token=e6577b33-e529-48be-8df3-6a94f5b68e16';

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    // Initialize the audio service if the FlutterFlow action hasn't run yet
    if (!AudioManager.isInitialized) {
      await initAudioPlayer();
    }
    if (!mounted) return;
    setState(() {
      _audio = AudioManager.instance;
    });
    _initPlayer();
  }

  void _initPlayer() {
    if (widget.playlist.isEmpty || _audio == null) return;

    setState(() {
      _currentSong = widget.playlist[widget.initialIndex];
    });

    // Load the full playlist so prev/next work
    final urls = widget.playlist.map((s) => s.songUrl).toList();
    _audio!.loadPlaylist(urls, initialIndex: widget.initialIndex);

    // Update the displayed song when the track changes
    _indexSubscription?.cancel();
    _indexSubscription = _audio!.player.currentIndexStream.listen((index) {
      if (index != null && index < widget.playlist.length && mounted) {
        setState(() {
          _currentSong = widget.playlist[index];
          FFAppState().activeSongRef = _currentSong!.reference;
        });
      }
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String minutes = duration.inMinutes.toString();
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX 2: Show a loading state while the audio service initialises.
    // This prevents any access to uninitialised variables.
    if (_audio == null || _currentSong == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        // FIX 3: dark background so white/purple text is visible
        color: const Color(0xFF1A0033),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE0A4F0)),
        ),
      );
    }

    final audio = _audio!;
    final currentSong = _currentSong!;

    return Container(
      width: widget.width,
      height: widget.height,
      // FIX 3: dark background so white/purple text is visible
      color: const Color(0xFF1A0033),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SONG INFO
          Text(
            currentSong.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            currentSong.artist,
            style: TextStyle(color: _primaryColor.withOpacity(0.7)),
          ),

          const SizedBox(height: 20),

          // TAGS
          SizedBox(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentSong.tags.length,
              itemBuilder: (context, index) {
                final tagName = currentSong.tags[index];
                return Container(
                  width: 90,
                  height: 25,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: const NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/capsule.png?alt=media&token=b46d4b47-a800-4959-af1c-dcf0118ec5c0'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topLeft,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.darken),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tagName,
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ALBUM ART
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  // FIX: songCoverImage can be "" (empty string), not just null.
                  // "" bypasses ?? so we must also check isNotEmpty.
                  (currentSong.songCoverImage?.isNotEmpty == true)
                      ? currentSong.songCoverImage!
                      : pyramidImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.network(
                    pyramidImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SEEK SLIDER WITH PYRAMID THUMB
          StreamBuilder<Duration>(
            stream: audio.positionStream,
            builder: (context, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final dur = audio.duration;
              final double maxVal = (dur.inMilliseconds.toDouble() > 0)
                  ? dur.inMilliseconds.toDouble()
                  : 1.0;
              final double currentVal =
                  pos.inMilliseconds.toDouble().clamp(0.0, maxVal);
              final double alignX =
                  (maxVal > 0) ? (currentVal / maxVal * 2) - 1 : -1.0;
              final double progressFraction =
                  (currentVal / maxVal).clamp(0.0, 1.0);

              return Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Background track
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 0.5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressFraction,
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        // Invisible slider for touch interaction
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 12,
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 20),
                          ),
                          child: Slider(
                            min: 0,
                            max: maxVal,
                            value: currentVal,
                            onChanged: (v) =>
                                audio.seekTo(Duration(milliseconds: v.toInt())),
                          ),
                        ),
                        // Pyramid thumb image
                        IgnorePointer(
                          child: Align(
                            alignment: Alignment(alignX.clamp(-1.0, 1.0), 0.0),
                            child: Image.network(
                              pyramidImageUrl,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                      width: 20,
                                      height: 20,
                                      color: _primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(pos),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                        Text("-${_formatDuration(dur - pos)}",
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // FIX 2: PLAYBACK CONTROLS — these were completely missing
          StreamBuilder<PlayerState>(
            stream: audio.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous track
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white, size: 40),
                    onPressed: () => audio.seekToPrevious(),
                  ),
                  const SizedBox(width: 20),
                  // Play / Pause
                  GestureDetector(
                    onTap: () => playing ? audio.pause() : audio.play(),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Next track
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white, size: 40),
                    onPressed: () => audio.seekToNext(),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
