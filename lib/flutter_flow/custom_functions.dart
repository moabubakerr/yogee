import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

int dayscounter(
  DateTime firstday,
  DateTime current,
) {
// calculate the days between firstday and current
  return current.difference(firstday).inDays;
}

String? hoursMinutesCounter(
  DateTime firstday,
  DateTime current,
) {
  Duration diff = current.difference(firstday);

  int hours = diff.inHours % 24;
  int minutes = diff.inMinutes % 60;

  // Format with leading zeros (e.g., "05" instead of "5")
  String h = hours.toString().padLeft(2, '0');
  String m = minutes.toString().padLeft(2, '0');

  // Returns "05     30" (with 5 spaces in between)
  return "$h     $m";
}

String? extractFirstLink(String? postText) {
// 1. Handle the case where input is null right away
  if (postText == null) {
    return null;
  }

// 2. Your Regex logic (No inner function definition)
  final urlRegExp = RegExp(
    r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*)?",
    caseSensitive: false,
    multiLine: true,
  );

  final match = urlRegExp.firstMatch(postText);

  if (match != null) {
    String foundUrl = match.group(0)!;

    // TRICK: Force add prefix if needed
    if (foundUrl.toLowerCase().startsWith('www.')) {
      return 'https://$foundUrl';
    }

    return foundUrl;
  }

  return null;
}

bool? isValidUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    print('YOGEE_DEBUG: Image URL is null or empty');
    return false;
  }
  if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
    print('YOGEE_DEBUG: Bad image URL -> $imageUrl');
    return false;
  }
  print('YOGEE_DEBUG: Valid image URL -> $imageUrl');
  return true;
}
