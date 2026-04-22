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

Future markAllNotificationsAsRead(DocumentReference userRef) async {
  // Get a reference to the Firestore instance
  final firestore = FirebaseFirestore.instance;

  // 1. Query all notifications for this user that are NOT seen yet
  // Make sure your field names match exactly what is in your database!
  final querySnapshot = await firestore
      .collection('notifications')
      .where('madeto',
          isEqualTo: userRef) // Check your field name for user reference
      .where('isread',
          isEqualTo: false) // Check your field name for the boolean
      .get();

  // 2. Create a Batch (this allows us to do many updates at once)
  WriteBatch batch = firestore.batch();

  // 3. Loop through the unread notifications and add them to the batch
  for (var doc in querySnapshot.docs) {
    batch.update(doc.reference, {'is_seen': true});
  }

  // 4. Commit the batch (send all updates to Firebase in one go)
  await batch.commit();
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
