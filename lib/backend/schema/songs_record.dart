import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SongsRecord extends FirestoreRecord {
  SongsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "artist" field.
  String? _artist;
  String get artist => _artist ?? '';
  bool hasArtist() => _artist != null;

  // "duration" field.
  String? _duration;
  String get duration => _duration ?? '';
  bool hasDuration() => _duration != null;

  // "songUrl" field.
  String? _songUrl;
  String get songUrl => _songUrl ?? '';
  bool hasSongUrl() => _songUrl != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "songCoverImage" field.
  String? _songCoverImage;
  String get songCoverImage => _songCoverImage ?? '';
  bool hasSongCoverImage() => _songCoverImage != null;

  // "poster" field.
  String? _poster;
  String get poster => _poster ?? '';
  bool hasPoster() => _poster != null;

  // "album" field.
  DocumentReference? _album;
  DocumentReference? get album => _album;
  bool hasAlbum() => _album != null;

  // "liked_by" field.
  List<DocumentReference>? _likedBy;
  List<DocumentReference> get likedBy => _likedBy ?? const [];
  bool hasLikedBy() => _likedBy != null;

  // "ID" field.
  String? _id;
  String get id => _id ?? '';
  bool hasId() => _id != null;

  // "num" field.
  int? _num;
  int get num => _num ?? 0;
  bool hasNum() => _num != null;

  // "tags" field.
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  void _initializeFields() {
    _artist = snapshotData['artist'] as String?;
    _duration = snapshotData['duration'] as String?;
    _songUrl = snapshotData['songUrl'] as String?;
    _title = snapshotData['title'] as String?;
    _songCoverImage = snapshotData['songCoverImage'] as String?;
    _poster = snapshotData['poster'] as String?;
    _album = snapshotData['album'] as DocumentReference?;
    _likedBy = getDataList(snapshotData['liked_by']);
    _id = snapshotData['ID'] as String?;
    _num = castToType<int>(snapshotData['num']);
    _tags = getDataList(snapshotData['tags']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('songs');

  static Stream<SongsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SongsRecord.fromSnapshot(s));

  static Future<SongsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SongsRecord.fromSnapshot(s));

  static SongsRecord fromSnapshot(DocumentSnapshot snapshot) => SongsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SongsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SongsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SongsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SongsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSongsRecordData({
  String? artist,
  String? duration,
  String? songUrl,
  String? title,
  String? songCoverImage,
  String? poster,
  DocumentReference? album,
  String? id,
  int? num,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'artist': artist,
      'duration': duration,
      'songUrl': songUrl,
      'title': title,
      'songCoverImage': songCoverImage,
      'poster': poster,
      'album': album,
      'ID': id,
      'num': num,
    }.withoutNulls,
  );

  return firestoreData;
}

class SongsRecordDocumentEquality implements Equality<SongsRecord> {
  const SongsRecordDocumentEquality();

  @override
  bool equals(SongsRecord? e1, SongsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.artist == e2?.artist &&
        e1?.duration == e2?.duration &&
        e1?.songUrl == e2?.songUrl &&
        e1?.title == e2?.title &&
        e1?.songCoverImage == e2?.songCoverImage &&
        e1?.poster == e2?.poster &&
        e1?.album == e2?.album &&
        listEquality.equals(e1?.likedBy, e2?.likedBy) &&
        e1?.id == e2?.id &&
        e1?.num == e2?.num &&
        listEquality.equals(e1?.tags, e2?.tags);
  }

  @override
  int hash(SongsRecord? e) => const ListEquality().hash([
        e?.artist,
        e?.duration,
        e?.songUrl,
        e?.title,
        e?.songCoverImage,
        e?.poster,
        e?.album,
        e?.likedBy,
        e?.id,
        e?.num,
        e?.tags
      ]);

  @override
  bool isValidKey(Object? o) => o is SongsRecord;
}
