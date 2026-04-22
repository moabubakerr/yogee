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
import 'dart:convert';
import '/custom_code/actions/init_audio_player.dart';

class RecordingPlayerWidget extends StatefulWidget {
  final String audioPath;
  final double width;
  final double height;

  const RecordingPlayerWidget({
    Key? key,
    required this.audioPath,
    this.width = double.infinity,
    this.height = 250,
  }) : super(key: key);

  @override
  State<RecordingPlayerWidget> createState() => _RecordingPlayerWidgetState();
}

class _RecordingPlayerWidgetState extends State<RecordingPlayerWidget> {
  // FIX: Do NOT access AudioManager.instance as a field initializer —
  // it is `static late` and throws LateInitializationError if
  // initAudioPlayer() hasn't run yet. Use nullable + async setup.
  AudioPlayerHandler? _audio;

  // ------------------------------------------------------
  // PASTE YOUR PYRAMID BASE64 STRING HERE
  // ------------------------------------------------------
  final String _base64Image =
      "data:image/png;base64,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";

  late final _decodedBytes;

  @override
  void initState() {
    super.initState();
    _decodeIcon();
    _setup();
  }

  Future<void> _setup() async {
    if (!AudioManager.isInitialized) {
      await initAudioPlayer();
    }
    if (!mounted) return;
    setState(() {
      _audio = AudioManager.instance;
    });
    _initPlayer();
  }

  void _decodeIcon() {
    try {
      String cleanBase64 = _base64Image;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      _decodedBytes = base64Decode(cleanBase64);
    } catch (e) {
      _decodedBytes = null;
    }
  }

  Future<void> _initPlayer() async {
    if (_audio == null) return;
    if (widget.audioPath.isEmpty || widget.audioPath == 'null') {
      print("Audio Path is empty or null");
      return;
    }

    try {
      final uri = Uri.parse(widget.audioPath.trim());
      await _audio!.player.setAudioSource(AudioSource.uri(uri));
      print("Successfully loaded: ${widget.audioPath}");
    } catch (e) {
      print("Error loading recording: $e");
    }
  }

  @override
  void dispose() {
    _audio?.player.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_audio == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE0A4F0)),
        ),
      );
    }

    final primaryColor = const Color(0xFFE0A4F0);

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<Duration>(
            stream: _audio!.player.positionStream,
            builder: (_, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final dur = _audio!.player.duration ?? Duration.zero;
              final double currentSec = pos.inSeconds.toDouble();
              final double totalSec = dur.inSeconds.toDouble();

              double alignX = -1.0;
              if (totalSec > 0) alignX = (currentSec / totalSec * 2) - 1;
              alignX = alignX.clamp(-1.0, 1.0);

              return Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                          ),
                          child: Slider(
                            min: 0,
                            max: totalSec > 0 ? totalSec : 1.0,
                            value: currentSec.clamp(
                                0, totalSec > 0 ? totalSec : 1.0),
                            onChanged: (v) => _audio!.player
                                .seek(Duration(seconds: v.toInt())),
                          ),
                        ),
                        IgnorePointer(
                          child: Align(
                            alignment: Alignment(alignX, 0.0),
                            child: _decodedBytes != null
                                ? Image.memory(_decodedBytes,
                                    width: 32, height: 32, fit: BoxFit.contain)
                                : Container(
                                    width: 20, height: 20, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(pos),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      Text("-${_formatDuration(dur - pos)}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded,
                    color: Colors.white, size: 30),
                onPressed: () => _audio!.player.seek(
                    _audio!.player.position - const Duration(seconds: 10)),
              ),
              const SizedBox(width: 15),
              StreamBuilder<PlayerState>(
                stream: _audio!.player.playerStateStream,
                builder: (_, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;
                  return GestureDetector(
                    onTap: () => isPlaying
                        ? _audio!.player.pause()
                        : _audio!.player.play(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded,
                    color: Colors.white, size: 30),
                onPressed: () => _audio!.player.seek(
                    _audio!.player.position + const Duration(seconds: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
