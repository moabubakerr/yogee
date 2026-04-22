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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import '/custom_code/actions/init_audio_player.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> playSongBtn() async {
  FirebaseCrashlytics.instance.log('audio: playSongBtn called');
  if (!AudioManager.isInitialized) {
    FirebaseCrashlytics.instance.log('audio: playSongBtn called before init — aborting');
    debugPrint('playSongBtn: AudioManager not initialised');
    return;
  }
  try {
    await AudioManager.instance.play();
    FFAppState().isPlaying = true;
  } catch (e, stack) {
    debugPrint('playSongBtn error: $e');
    await FirebaseCrashlytics.instance.recordError(
      e, stack,
      reason: 'playSongBtn failed',
      fatal: false,
    );
  }
}
