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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<ChatsRecord?> identifyExistingChat(
  List<DocumentReference> listOfMembers,
) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContainsAny: listOfMembers)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final List<DocumentReference> users =
          List<DocumentReference>.from(data['users'] ?? []);

      // Ensure the chat contains ONLY these members
      if (users.length == listOfMembers.length &&
          users.toSet().containsAll(listOfMembers)) {
        return ChatsRecord.fromSnapshot(doc);
      }
    }

    return null; // No matching chat found
  } catch (e) {
    print('Error fetching chat: $e');
    return null;
  }
}
