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

Future<void> seekForward() async {
  FirebaseCrashlytics.instance.log('audio: seekForward +10s called');
  if (!AudioManager.isInitialized) {
    FirebaseCrashlytics.instance.log('audio: seekForward called before init — aborting');
    debugPrint('seekForward: AudioManager not initialised');
    return;
  }
  try {
    await AudioManager.instance.skipForward(seconds: 10);
  } catch (e, stack) {
    debugPrint('seekForward error: $e');
    await FirebaseCrashlytics.instance.recordError(
      e, stack,
      reason: 'seekForward failed',
      fatal: false,
    );
  }
}
