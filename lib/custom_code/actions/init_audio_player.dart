// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// =====================================================================
// GLOBAL ACCESS — all action files use AudioManager.instance
// =====================================================================
class AudioManager {
  static late AudioPlayerHandler instance;
  static bool isInitialized = false;
}

// =====================================================================
// SONG DATA MODEL
// =====================================================================
class SongData {
  final String songTitle;
  final String coverUrl;
  final String authorName;
  final String duration;
  final String songUrl;

  const SongData({
    required this.songTitle,
    required this.coverUrl,
    required this.authorName,
    required this.duration,
    required this.songUrl,
  });

  factory SongData.fromMap(Map<String, dynamic> map) {
    return SongData(
      songTitle: map['songTitle'] as String? ?? 'Unknown Title',
      coverUrl: map['posterUrl'] as String? ?? '',
      authorName: map['authorName'] as String? ?? 'Unknown Artist',
      duration: map['durationMs'] ?? '',
      songUrl: map['songUrl'] as String? ?? '',
    );
  }
}

// =====================================================================
// AUDIO PLAYER HANDLER
// =====================================================================
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<bool> isShufflingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isRepeatingNotifier = ValueNotifier<bool>(false);
  List<SongData> _songDataList = [];

  AudioPlayerHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    player.currentIndexStream.listen((index) {
      if (index != null && index < _songDataList.length) {
        _updateNowPlayingInfo(index);
      }
    });
  }

  void _updateNowPlayingInfo(int index) {
    final song = _songDataList[index];
    final item = MediaItem(
      id: song.songUrl,
      title: song.songTitle,
      artist: song.authorName,
      artUri: song.coverUrl.isNotEmpty ? Uri.parse(song.coverUrl) : null,
    );
    mediaItem.add(item);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // OS control overrides — called by lock screen / Control Center
  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() => player.seekToNext();

  @override
  Future<void> skipToPrevious() => player.seekToPrevious();

  // Playlist loading with metadata (lock screen shows title/artist/art)
  Future<void> loadPlaylistWithMetadata(
    List<SongData> songs, {
    int initialIndex = 0,
  }) async {
    if (songs.isEmpty) return;
    _songDataList = songs;
    final playlist = ConcatenatingAudioSource(
      children:
          songs.map((s) => AudioSource.uri(Uri.parse(s.songUrl))).toList(),
    );
    try {
      await player.stop();
      await player.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _updateNowPlayingInfo(initialIndex);
      play();
    } catch (e) {
      debugPrint("Error loading playlist: $e");
    }
  }

  // Playlist loading with just URLs (backward compatible)
  Future<void> loadPlaylist(List<String> urls, {int initialIndex = 0}) async {
    if (urls.isEmpty) return;
    _songDataList = urls
        .asMap()
        .entries
        .map((entry) => SongData(
              songTitle: 'Track ${entry.key + 1}',
              coverUrl: '',
              authorName: 'Unknown Artist',
              duration: '',
              songUrl: entry.value,
            ))
        .toList();
    final playlist = ConcatenatingAudioSource(
      children: urls.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
    );
    try {
      await player.stop();
      await player.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _updateNowPlayingInfo(initialIndex);
      play();
    } catch (e) {
      debugPrint("Error loading playlist: $e");
    }
  }

  // Seek controls
  Future<void> seekTo(Duration position) async => await player.seek(position);

  Future<void> seekToNext() async => await player.seekToNext();

  Future<void> seekToPrevious() async => await player.seekToPrevious();

  Future<void> skipForward({int seconds = 10}) async {
    final dur = player.duration ?? Duration.zero;
    if (dur == Duration.zero) return;
    final newPos = player.position + Duration(seconds: seconds);
    await player.seek(newPos < dur ? newPos : dur);
  }

  Future<void> skipBackward({int seconds = 10}) async {
    final dur = player.duration ?? Duration.zero;
    if (dur == Duration.zero) return;
    final newPos = player.position - Duration(seconds: seconds);
    await player.seek(newPos > Duration.zero ? newPos : Duration.zero);
  }

  // Shuffle & repeat
  Future<void> toggleShuffle() async {
    final newState = !isShufflingNotifier.value;
    isShufflingNotifier.value = newState;
    await player.setShuffleModeEnabled(newState);
  }

  Future<void> toggleRepeat() async {
    final newState = !isRepeatingNotifier.value;
    isRepeatingNotifier.value = newState;
    await player.setLoopMode(newState ? LoopMode.one : LoopMode.off);
  }

  // Downloads
  Future<void> downloadMusic(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Download complete: ${file.path}');
      }
    } catch (e) {
      debugPrint('Download error: $e');
    }
  }

  void disposePlayer() {
    player.dispose();
    isShufflingNotifier.dispose();
    isRepeatingNotifier.dispose();
  }

  // Getters & streams
  bool get isPlaying => player.playing;
  Duration get position => player.position;
  Duration get duration => player.duration ?? Duration.zero;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
}

// =====================================================================
// MAIN INIT FUNCTION — called on app start
// =====================================================================
Future<void> initAudioPlayer() async {
  if (AudioManager.isInitialized) return;

  AudioManager.instance = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.yoogeeapp.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  AudioManager.isInitialized = true;

  AudioManager.instance.player.positionStream.listen((pos) {
    FFAppState().currentPosition = pos.inSeconds.toDouble();
  });

  AudioManager.instance.player.durationStream.listen((dur) {
    FFAppState().totalDuration = dur?.inSeconds.toDouble() ?? 0.0;
  });

  AudioManager.instance.player.playerStateStream.listen((state) {
    FFAppState().isPlaying = state.playing;
  });
}
