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

import 'package:cloud_firestore/cloud_firestore.dart';

/// Deletes every notification addressed to [userRef].
///
/// The "clear all" button used to call `.delete()` on a single document taken
/// from a `singleRecord: true` stream, so it only ever removed one notification.
Future clearAllNotifications(DocumentReference userRef) async {
  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore
      .collection('notifications')
      .where('madeto', isEqualTo: userRef)
      .get();

  if (querySnapshot.docs.isEmpty) return;

  // Firestore caps a batch at 500 writes, so commit in chunks.
  const int batchLimit = 500;
  for (int start = 0; start < querySnapshot.docs.length; start += batchLimit) {
    final chunk = querySnapshot.docs.skip(start).take(batchLimit);
    final batch = firestore.batch();
    for (final doc in chunk) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
