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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// =====================================================================
// GLOBAL ACCESS — all action files use AudioManager.instance
// =====================================================================
class AudioManager {
  static late AudioPlayerHandler instance;
  static bool isInitialized = false;
  static Completer<void>? _initCompleter;
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
  ConcatenatingAudioSource? _playlist;

  /// The current playback queue (in order). Read-only snapshot.
  List<SongData> get songQueue => List.unmodifiable(_songDataList);

  /// Index of the track currently playing within [queue].
  int get currentQueueIndex => player.currentIndex ?? 0;

  /// Reorder a track in the live queue. [oldIndex]/[newIndex] are absolute
  /// positions within [queue]. Keeps the just_audio source and the metadata
  /// list in sync, and does not interrupt the currently-playing track.
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (_playlist == null) return;
    if (oldIndex < 0 ||
        oldIndex >= _songDataList.length ||
        newIndex < 0 ||
        newIndex >= _songDataList.length ||
        oldIndex == newIndex) {
      return;
    }
    try {
      await _playlist!.move(oldIndex, newIndex);
      final item = _songDataList.removeAt(oldIndex);
      _songDataList.insert(newIndex, item);
    } catch (e, stack) {
      debugPrint('moveQueueItem error: $e');
      await FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'moveQueueItem failed — old=$oldIndex new=$newIndex',
        fatal: false,
      );
    }
  }

  AudioPlayerHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    player.currentIndexStream.listen(
      (index) {
        if (index != null && index < _songDataList.length) {
          FirebaseCrashlytics.instance.log('audio: track changed to index $index');
          _updateNowPlayingInfo(index);
        }
      },
      onError: (e, stack) {
        debugPrint('currentIndexStream error: $e');
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'currentIndexStream error', fatal: false);
      },
    );
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
    FirebaseCrashlytics.instance.log(
        'audio: loadPlaylistWithMetadata — ${songs.length} tracks, initialIndex=$initialIndex, first="${songs.first.songTitle}"');
    _songDataList = songs;
    final playlist = ConcatenatingAudioSource(
      children:
          songs.map((s) => AudioSource.uri(Uri.parse(s.songUrl))).toList(),
    );
    _playlist = playlist;
    try {
      await player.stop();
      await player.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _updateNowPlayingInfo(initialIndex);
      FirebaseCrashlytics.instance.log('audio: playlist loaded, starting playback');
      play();
    } catch (e, stack) {
      debugPrint("Error loading playlist: $e");
      await FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'loadPlaylistWithMetadata failed — ${songs.length} tracks, initialIndex=$initialIndex',
        fatal: false,
      );
    }
  }

  // Playlist loading with just URLs (backward compatible)
  Future<void> loadPlaylist(List<String> urls, {int initialIndex = 0}) async {
    if (urls.isEmpty) return;
    FirebaseCrashlytics.instance.log(
        'audio: loadPlaylist — ${urls.length} URLs, initialIndex=$initialIndex');
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
    _playlist = playlist;
    try {
      await player.stop();
      await player.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _updateNowPlayingInfo(initialIndex);
      FirebaseCrashlytics.instance.log('audio: URL playlist loaded, starting playback');
      play();
    } catch (e, stack) {
      debugPrint("Error loading playlist: $e");
      await FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'loadPlaylist failed — ${urls.length} URLs, initialIndex=$initialIndex',
        fatal: false,
      );
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
    FirebaseCrashlytics.instance.log('audio: downloadMusic started — $fileName');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Download complete: ${file.path}');
        FirebaseCrashlytics.instance.log('audio: downloadMusic complete — ${file.path}');
      } else {
        FirebaseCrashlytics.instance.log(
            'audio: downloadMusic HTTP error ${response.statusCode} — $fileName');
      }
    } catch (e, stack) {
      debugPrint('Download error: $e');
      await FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'downloadMusic failed — $fileName',
        fatal: false,
      );
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

  // If already in progress, wait for that call to finish instead of calling init() again.
  if (AudioManager._initCompleter != null) {
    return AudioManager._initCompleter!.future;
  }
  AudioManager._initCompleter = Completer<void>();

  FirebaseCrashlytics.instance.log('audio: initAudioPlayer starting');

  try {
    AudioManager.instance = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.yoogeeapp.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    FirebaseCrashlytics.instance.log('audio: AudioService.init succeeded');
  } on AssertionError catch (_) {
    // AudioService is already registered (e.g. after hot-restart or when the
    // Android background service survives an app foreground/background cycle).
    // AudioManager.instance was set during the first successful init — reuse it.
    debugPrint('AudioService already initialized — skipping re-init.');
    FirebaseCrashlytics.instance.log('audio: AudioService already registered — reusing existing instance');
    AudioManager.isInitialized = true;
    AudioManager._initCompleter!.complete();
    AudioManager._initCompleter = null;
    return;
  } catch (e, stack) {
    // Non-fatal: fall back to a bare handler (no OS media controls / lock screen).
    // Common cause on Android: MainActivity must extend FlutterFragmentActivity.
    debugPrint('AudioService init failed, using fallback handler: $e');
    await FirebaseCrashlytics.instance.recordError(
      e, stack,
      reason: 'AudioService.init failed — falling back to bare AudioPlayerHandler (no OS controls)',
      fatal: false,
    );
    AudioManager.instance = AudioPlayerHandler();
  }

  AudioManager.isInitialized = true;
  AudioManager._initCompleter!.complete();
  AudioManager._initCompleter = null;

  FirebaseCrashlytics.instance.log('audio: initAudioPlayer complete, subscribing to streams');

  AudioManager.instance.player.positionStream.listen(
    (pos) => FFAppState().currentPosition = pos.inSeconds.toDouble(),
    onError: (e, stack) {
      debugPrint('positionStream error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'positionStream error', fatal: false);
    },
  );

  AudioManager.instance.player.durationStream.listen(
    (dur) => FFAppState().totalDuration = dur?.inSeconds.toDouble() ?? 0.0,
    onError: (e, stack) {
      debugPrint('durationStream error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'durationStream error', fatal: false);
    },
  );

  AudioManager.instance.player.playerStateStream.listen(
    (state) => FFAppState().isPlaying = state.playing,
    onError: (e, stack) {
      debugPrint('playerStateStream error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'playerStateStream error', fatal: false);
    },
  );
}
