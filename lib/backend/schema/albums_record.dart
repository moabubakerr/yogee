import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AlbumsRecord extends FirestoreRecord {
  AlbumsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "album_name" field.
  String? _albumName;
  String get albumName => _albumName ?? '';
  bool hasAlbumName() => _albumName != null;

  // "tacks" field.
  List<DocumentReference>? _tacks;
  List<DocumentReference> get tacks => _tacks ?? const [];
  bool hasTacks() => _tacks != null;

  // "artist" field.
  String? _artist;
  String get artist => _artist ?? '';
  bool hasArtist() => _artist != null;

  // "cover_image" field.
  String? _coverImage;
  String get coverImage => _coverImage ?? '';
  bool hasCoverImage() => _coverImage != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "tags" field.
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "playcount" field.
  List<DocumentReference>? _playcount;
  List<DocumentReference> get playcount => _playcount ?? const [];
  bool hasPlaycount() => _playcount != null;

  // "artistref" field.
  List<DocumentReference>? _artistref;
  List<DocumentReference> get artistref => _artistref ?? const [];
  bool hasArtistref() => _artistref != null;

  // "filter" field.
  String? _filter;
  String get filter => _filter ?? '';
  bool hasFilter() => _filter != null;

  void _initializeFields() {
    _albumName = snapshotData['album_name'] as String?;
    _tacks = getDataList(snapshotData['tacks']);
    _artist = snapshotData['artist'] as String?;
    _coverImage = snapshotData['cover_image'] as String?;
    _description = snapshotData['description'] as String?;
    _tags = getDataList(snapshotData['tags']);
    _playcount = getDataList(snapshotData['playcount']);
    _artistref = getDataList(snapshotData['artistref']);
    _filter = snapshotData['filter'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('albums');

  static Stream<AlbumsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AlbumsRecord.fromSnapshot(s));

  static Future<AlbumsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AlbumsRecord.fromSnapshot(s));

  static AlbumsRecord fromSnapshot(DocumentSnapshot snapshot) => AlbumsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AlbumsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AlbumsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AlbumsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AlbumsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAlbumsRecordData({
  String? albumName,
  String? artist,
  String? coverImage,
  String? description,
  String? filter,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'album_name': albumName,
      'artist': artist,
      'cover_image': coverImage,
      'description': description,
      'filter': filter,
    }.withoutNulls,
  );

  return firestoreData;
}

class AlbumsRecordDocumentEquality implements Equality<AlbumsRecord> {
  const AlbumsRecordDocumentEquality();

  @override
  bool equals(AlbumsRecord? e1, AlbumsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.albumName == e2?.albumName &&
        listEquality.equals(e1?.tacks, e2?.tacks) &&
        e1?.artist == e2?.artist &&
        e1?.coverImage == e2?.coverImage &&
        e1?.description == e2?.description &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        listEquality.equals(e1?.playcount, e2?.playcount) &&
        listEquality.equals(e1?.artistref, e2?.artistref) &&
        e1?.filter == e2?.filter;
  }

  @override
  int hash(AlbumsRecord? e) => const ListEquality().hash([
        e?.albumName,
        e?.tacks,
        e?.artist,
        e?.coverImage,
        e?.description,
        e?.tags,
        e?.playcount,
        e?.artistref,
        e?.filter
      ]);

  @override
  bool isValidKey(Object? o) => o is AlbumsRecord;
}
