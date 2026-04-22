// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SongDataStruct extends FFFirebaseStruct {
  SongDataStruct({
    String? songTitle,
    String? authorName,
    String? duration,
    String? songUrl,
    String? coverUrl,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _songTitle = songTitle,
        _authorName = authorName,
        _duration = duration,
        _songUrl = songUrl,
        _coverUrl = coverUrl,
        super(firestoreUtilData);

  // "songTitle" field.
  String? _songTitle;
  String get songTitle => _songTitle ?? '';
  set songTitle(String? val) => _songTitle = val;

  bool hasSongTitle() => _songTitle != null;

  // "authorName" field.
  String? _authorName;
  String get authorName => _authorName ?? '';
  set authorName(String? val) => _authorName = val;

  bool hasAuthorName() => _authorName != null;

  // "duration" field.
  String? _duration;
  String get duration => _duration ?? '';
  set duration(String? val) => _duration = val;

  bool hasDuration() => _duration != null;

  // "songUrl" field.
  String? _songUrl;
  String get songUrl => _songUrl ?? '';
  set songUrl(String? val) => _songUrl = val;

  bool hasSongUrl() => _songUrl != null;

  // "coverUrl" field.
  String? _coverUrl;
  String get coverUrl => _coverUrl ?? '';
  set coverUrl(String? val) => _coverUrl = val;

  bool hasCoverUrl() => _coverUrl != null;

  static SongDataStruct fromMap(Map<String, dynamic> data) => SongDataStruct(
        songTitle: data['songTitle'] as String?,
        authorName: data['authorName'] as String?,
        duration: data['duration'] as String?,
        songUrl: data['songUrl'] as String?,
        coverUrl: data['coverUrl'] as String?,
      );

  static SongDataStruct? maybeFromMap(dynamic data) =>
      data is Map ? SongDataStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'songTitle': _songTitle,
        'authorName': _authorName,
        'duration': _duration,
        'songUrl': _songUrl,
        'coverUrl': _coverUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'songTitle': serializeParam(
          _songTitle,
          ParamType.String,
        ),
        'authorName': serializeParam(
          _authorName,
          ParamType.String,
        ),
        'duration': serializeParam(
          _duration,
          ParamType.String,
        ),
        'songUrl': serializeParam(
          _songUrl,
          ParamType.String,
        ),
        'coverUrl': serializeParam(
          _coverUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static SongDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      SongDataStruct(
        songTitle: deserializeParam(
          data['songTitle'],
          ParamType.String,
          false,
        ),
        authorName: deserializeParam(
          data['authorName'],
          ParamType.String,
          false,
        ),
        duration: deserializeParam(
          data['duration'],
          ParamType.String,
          false,
        ),
        songUrl: deserializeParam(
          data['songUrl'],
          ParamType.String,
          false,
        ),
        coverUrl: deserializeParam(
          data['coverUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'SongDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SongDataStruct &&
        songTitle == other.songTitle &&
        authorName == other.authorName &&
        duration == other.duration &&
        songUrl == other.songUrl &&
        coverUrl == other.coverUrl;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([songTitle, authorName, duration, songUrl, coverUrl]);
}

SongDataStruct createSongDataStruct({
  String? songTitle,
  String? authorName,
  String? duration,
  String? songUrl,
  String? coverUrl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SongDataStruct(
      songTitle: songTitle,
      authorName: authorName,
      duration: duration,
      songUrl: songUrl,
      coverUrl: coverUrl,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SongDataStruct? updateSongDataStruct(
  SongDataStruct? songData, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    songData
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSongDataStructData(
  Map<String, dynamic> firestoreData,
  SongDataStruct? songData,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (songData == null) {
    return;
  }
  if (songData.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && songData.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final songDataData = getSongDataFirestoreData(songData, forFieldValue);
  final nestedData = songDataData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = songData.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSongDataFirestoreData(
  SongDataStruct? songData, [
  bool forFieldValue = false,
]) {
  if (songData == null) {
    return {};
  }
  final firestoreData = mapToFirestore(songData.toMap());

  // Add any Firestore field values
  mapToFirestore(songData.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSongDataListFirestoreData(
  List<SongDataStruct>? songDatas,
) =>
    songDatas?.map((e) => getSongDataFirestoreData(e, true)).toList() ?? [];
