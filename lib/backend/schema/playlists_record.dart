import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PlaylistsRecord extends FirestoreRecord {
  PlaylistsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "playlist_name" field.
  String? _playlistName;
  String get playlistName => _playlistName ?? '';
  bool hasPlaylistName() => _playlistName != null;

  // "songs" field.
  List<DocumentReference>? _songs;
  List<DocumentReference> get songs => _songs ?? const [];
  bool hasSongs() => _songs != null;

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "songsnum" field.
  List<int>? _songsnum;
  List<int> get songsnum => _songsnum ?? const [];
  bool hasSongsnum() => _songsnum != null;

  void _initializeFields() {
    _playlistName = snapshotData['playlist_name'] as String?;
    _songs = getDataList(snapshotData['songs']);
    _user = snapshotData['user'] as DocumentReference?;
    _songsnum = getDataList(snapshotData['songsnum']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('playlists');

  static Stream<PlaylistsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PlaylistsRecord.fromSnapshot(s));

  static Future<PlaylistsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PlaylistsRecord.fromSnapshot(s));

  static PlaylistsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PlaylistsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PlaylistsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PlaylistsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PlaylistsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PlaylistsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPlaylistsRecordData({
  String? playlistName,
  DocumentReference? user,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'playlist_name': playlistName,
      'user': user,
    }.withoutNulls,
  );

  return firestoreData;
}

class PlaylistsRecordDocumentEquality implements Equality<PlaylistsRecord> {
  const PlaylistsRecordDocumentEquality();

  @override
  bool equals(PlaylistsRecord? e1, PlaylistsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.playlistName == e2?.playlistName &&
        listEquality.equals(e1?.songs, e2?.songs) &&
        e1?.user == e2?.user &&
        listEquality.equals(e1?.songsnum, e2?.songsnum);
  }

  @override
  int hash(PlaylistsRecord? e) => const ListEquality()
      .hash([e?.playlistName, e?.songs, e?.user, e?.songsnum]);

  @override
  bool isValidKey(Object? o) => o is PlaylistsRecord;
}
