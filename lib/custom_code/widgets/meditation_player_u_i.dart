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

// This is the simplified version of the player without the custom diamond slider.
// The parameters you need to define in FlutterFlow remain the same:
//
// NAME              TYPE        REQUIRED
// ---------------------------------------
// totalDuration     Integer     Yes
// currentPosition   Integer     Yes
// isPlaying         Boolean     Yes
// onPlayPauseTapped Action      Yes
// onNextTapped      Action      Yes
// onPreviousTapped  Action      Yes
// onShuffleTapped   Action      Yes
// onRepeatTapped    Action      Yes
// onSeek            Action      Yes (with a 'seekPosition' (Double) parameter)

class MeditationPlayerUI extends StatefulWidget {
  const MeditationPlayerUI({
    Key? key,
    this.width,
    this.height,
    required this.totalDuration,
    required this.currentPosition,
    required this.isPlaying,
    required this.onPlayPauseTapped,
    required this.onNextTapped,
    required this.onPreviousTapped,
    required this.onShuffleTapped,
    required this.onRepeatTapped,
    required this.onSeek,
  }) : super(key: key);

  final double? width;
  final double? height;
  final int totalDuration;
  final int currentPosition;
  final bool isPlaying;
  final Future<dynamic> Function() onPlayPauseTapped;
  final Future<dynamic> Function() onNextTapped;
  final Future<dynamic> Function() onPreviousTapped;
  final Future<dynamic> Function() onShuffleTapped;
  final Future<dynamic> Function() onRepeatTapped;
  final Future<dynamic> Function(double? seekPosition) onSeek;

  @override
  _MeditationPlayerUIState createState() => _MeditationPlayerUIState();
}

class _MeditationPlayerUIState extends State<MeditationPlayerUI> {
  // Helper function to format duration from milliseconds to MM:SS
  String formatDuration(int milliseconds) {
    if (milliseconds < 0) milliseconds = 0;
    final int totalSeconds = milliseconds ~/ 1000;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Convert durations from int (ms) to double (seconds) for the slider
    final double totalDurationSec = widget.totalDuration / 1000.0;
    final double currentPositionSec = widget.currentPosition / 1000.0;
    final int remainingMs = widget.totalDuration - widget.currentPosition;

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Slider and Time Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text(
                  formatDuration(widget.currentPosition),
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.0,
                      activeTrackColor: Color(0xFFE5B4E4).withOpacity(0.8),
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Color(0xFFE5B4E4),
                      overlayColor: Color(0xFFE5B4E4).withAlpha(50),
                    ),
                    child: Slider(
                      value: currentPositionSec.clamp(0.0, totalDurationSec),
                      min: 0.0,
                      max: totalDurationSec > 0 ? totalDurationSec : 1.0,
                      onChanged: (value) {
                        // This callback is used for live dragging visuals
                      },
                      onChangeEnd: (value) {
                        // When user releases the thumb, trigger the seek action
                        widget.onSeek(value);
                      },
                    ),
                  ),
                ),
                Text(
                  '-${formatDuration(remainingMs)}',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Controls Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.shuffle, color: Colors.white70, size: 24),
                  onPressed: widget.onShuffleTapped,
                ),
                IconButton(
                  icon:
                      Icon(Icons.skip_previous, color: Colors.white, size: 36),
                  onPressed: widget.onPreviousTapped,
                ),
                // Play/Pause Button
                GestureDetector(
                  onTap: () => widget.onPlayPauseTapped(),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFE5B4E4),
                          Color(0xFFC8A2C8).withOpacity(0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white, size: 36),
                  onPressed: widget.onNextTapped,
                ),
                IconButton(
                  icon: Icon(Icons.repeat, color: Colors.white70, size: 24),
                  onPressed: widget.onRepeatTapped,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
