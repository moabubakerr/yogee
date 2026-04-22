import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DownloadsRecord extends FirestoreRecord {
  DownloadsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "songUrl" field.
  String? _songUrl;
  String get songUrl => _songUrl ?? '';
  bool hasSongUrl() => _songUrl != null;

  // "SongImage" field.
  String? _songImage;
  String get songImage => _songImage ?? '';
  bool hasSongImage() => _songImage != null;

  // "songName" field.
  String? _songName;
  String get songName => _songName ?? '';
  bool hasSongName() => _songName != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "coverimage" field.
  String? _coverimage;
  String get coverimage => _coverimage ?? '';
  bool hasCoverimage() => _coverimage != null;

  // "artist" field.
  String? _artist;
  String get artist => _artist ?? '';
  bool hasArtist() => _artist != null;

  // "num" field.
  int? _num;
  int get num => _num ?? 0;
  bool hasNum() => _num != null;

  // "duration" field.
  String? _duration;
  String get duration => _duration ?? '';
  bool hasDuration() => _duration != null;

  void _initializeFields() {
    _songUrl = snapshotData['songUrl'] as String?;
    _songImage = snapshotData['SongImage'] as String?;
    _songName = snapshotData['songName'] as String?;
    _userId = snapshotData['userId'] as String?;
    _user = snapshotData['user'] as DocumentReference?;
    _coverimage = snapshotData['coverimage'] as String?;
    _artist = snapshotData['artist'] as String?;
    _num = castToType<int>(snapshotData['num']);
    _duration = snapshotData['duration'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Downloads');

  static Stream<DownloadsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DownloadsRecord.fromSnapshot(s));

  static Future<DownloadsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DownloadsRecord.fromSnapshot(s));

  static DownloadsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      DownloadsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DownloadsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DownloadsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DownloadsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DownloadsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDownloadsRecordData({
  String? songUrl,
  String? songImage,
  String? songName,
  String? userId,
  DocumentReference? user,
  String? coverimage,
  String? artist,
  int? num,
  String? duration,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'songUrl': songUrl,
      'SongImage': songImage,
      'songName': songName,
      'userId': userId,
      'user': user,
      'coverimage': coverimage,
      'artist': artist,
      'num': num,
      'duration': duration,
    }.withoutNulls,
  );

  return firestoreData;
}

class DownloadsRecordDocumentEquality implements Equality<DownloadsRecord> {
  const DownloadsRecordDocumentEquality();

  @override
  bool equals(DownloadsRecord? e1, DownloadsRecord? e2) {
    return e1?.songUrl == e2?.songUrl &&
        e1?.songImage == e2?.songImage &&
        e1?.songName == e2?.songName &&
        e1?.userId == e2?.userId &&
        e1?.user == e2?.user &&
        e1?.coverimage == e2?.coverimage &&
        e1?.artist == e2?.artist &&
        e1?.num == e2?.num &&
        e1?.duration == e2?.duration;
  }

  @override
  int hash(DownloadsRecord? e) => const ListEquality().hash([
        e?.songUrl,
        e?.songImage,
        e?.songName,
        e?.userId,
        e?.user,
        e?.coverimage,
        e?.artist,
        e?.num,
        e?.duration
      ]);

  @override
  bool isValidKey(Object? o) => o is DownloadsRecord;
}
