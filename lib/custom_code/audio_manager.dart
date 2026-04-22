import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '/flutter_flow/flutter_flow_util.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'songTitle': songTitle,
      'posterUrl': coverUrl,
      'authorName': authorName,
      'durationMs': duration,
      'songUrl': songUrl,
    };
  }
}

// =====================================================================
// AUDIO PLAYER HANDLER — replaces the old AudioManager singleton
// This class talks to iOS/Android OS for lock screen & Control Center
// =====================================================================
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  // Public player — same as before, your widgets can access streams
  final AudioPlayer player = AudioPlayer();

  // Shuffle & repeat notifiers — same as before
  final ValueNotifier<bool> _isShufflingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isRepeatingNotifier = ValueNotifier<bool>(false);

  // Store song metadata for lock screen display
  List<SongData> _songDataList = [];

  AudioPlayerHandler() {
    // ---- Bridge just_audio state → OS media controls ----
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // When the current track index changes, update lock screen info
    player.currentIndexStream.listen((index) {
      if (index != null && index < _songDataList.length) {
        _updateNowPlayingInfo(index);
      }
    });
  }

  // =====================================================================
  // LOCK SCREEN / CONTROL CENTER — the new part
  // =====================================================================

  /// Updates the lock screen with track title, artist, and cover art
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

  /// Converts just_audio events into the format iOS/Android expects
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

  // =====================================================================
  // OS CONTROL OVERRIDES — called when user taps lock screen buttons
  // =====================================================================

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

  // =====================================================================
  // PLAYLIST & PLAYER CONTROL — same as your original AudioManager
  // =====================================================================

  /// Load playlist WITH metadata (lock screen shows title/artist/art)
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

  /// Load playlist with just URLs (backward compatible with your old code)
  /// Lock screen will show "Track 1" / "Unknown Artist" since no metadata
  Future<void> loadPlaylist(List<String> urls, {int initialIndex = 0}) async {
    if (urls.isEmpty) return;

    // Create placeholder SongData so lock screen still works (with defaults)
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

  // =====================================================================
  // SEEK CONTROLS
  // =====================================================================

  Future<void> seekTo(Duration position) async => await player.seek(position);

  Future<void> seekToNext() async => await player.seekToNext();

  Future<void> seekToPrevious() async => await player.seekToPrevious();

  /// Renamed from seekForward to avoid conflict with BaseAudioHandler.seekForward(bool)
  Future<void> skipForward({int seconds = 10}) async {
    final dur = player.duration ?? Duration.zero;
    if (dur == Duration.zero) return;
    final newPos = player.position + Duration(seconds: seconds);
    await player.seek(newPos < dur ? newPos : dur);
  }

  /// Renamed from seekBackward to avoid conflict with BaseAudioHandler.seekBackward(bool)
  Future<void> skipBackward({int seconds = 10}) async {
    final dur = player.duration ?? Duration.zero;
    if (dur == Duration.zero) return;
    final newPos = player.position - Duration(seconds: seconds);
    await player.seek(newPos > Duration.zero ? newPos : Duration.zero);
  }

  // =====================================================================
  // SHUFFLE & REPEAT — same as before
  // =====================================================================

  Future<void> toggleShuffle() async {
    final newState = !_isShufflingNotifier.value;
    _isShufflingNotifier.value = newState;
    await player.setShuffleModeEnabled(newState);
  }

  Future<void> toggleRepeat() async {
    final newState = !_isRepeatingNotifier.value;
    _isRepeatingNotifier.value = newState;
    await player.setLoopMode(newState ? LoopMode.one : LoopMode.off);
  }

  // =====================================================================
  // DOWNLOADS — same as before
  // =====================================================================

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

  // =====================================================================
  // CLEANUP
  // =====================================================================

  void disposePlayer() {
    player.dispose();
    _isShufflingNotifier.dispose();
    _isRepeatingNotifier.dispose();
  }

  // =====================================================================
  // GETTERS & STREAMS — same as before
  // =====================================================================

  ValueListenable<bool> get isShuffling => _isShufflingNotifier;
  ValueListenable<bool> get isRepeating => _isRepeatingNotifier;

  bool get isPlaying => player.playing;
  Duration get position => player.position;
  Duration get duration => player.duration ?? Duration.zero;

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
}

// =====================================================================
// GLOBAL ACCESS — replaces AudioManager.instance
// =====================================================================

late AudioPlayerHandler audioHandler;

/// Call this ONCE on app start (e.g. in main.dart or your first page onInit)
Future<void> initAudioService() async {
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.yourapp.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}
