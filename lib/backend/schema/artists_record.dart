import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ArtistsRecord extends FirestoreRecord {
  ArtistsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "artistname" field.
  String? _artistname;
  String get artistname => _artistname ?? '';
  bool hasArtistname() => _artistname != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  bool hasImage() => _image != null;

  // "details" field.
  String? _details;
  String get details => _details ?? '';
  bool hasDetails() => _details != null;

  // "albums" field.
  List<DocumentReference>? _albums;
  List<DocumentReference> get albums => _albums ?? const [];
  bool hasAlbums() => _albums != null;

  void _initializeFields() {
    _artistname = snapshotData['artistname'] as String?;
    _image = snapshotData['image'] as String?;
    _details = snapshotData['details'] as String?;
    _albums = getDataList(snapshotData['albums']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('artists');

  static Stream<ArtistsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ArtistsRecord.fromSnapshot(s));

  static Future<ArtistsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ArtistsRecord.fromSnapshot(s));

  static ArtistsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ArtistsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ArtistsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ArtistsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ArtistsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ArtistsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createArtistsRecordData({
  String? artistname,
  String? image,
  String? details,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'artistname': artistname,
      'image': image,
      'details': details,
    }.withoutNulls,
  );

  return firestoreData;
}

class ArtistsRecordDocumentEquality implements Equality<ArtistsRecord> {
  const ArtistsRecordDocumentEquality();

  @override
  bool equals(ArtistsRecord? e1, ArtistsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.artistname == e2?.artistname &&
        e1?.image == e2?.image &&
        e1?.details == e2?.details &&
        listEquality.equals(e1?.albums, e2?.albums);
  }

  @override
  int hash(ArtistsRecord? e) => const ListEquality()
      .hash([e?.artistname, e?.image, e?.details, e?.albums]);

  @override
  bool isValidKey(Object? o) => o is ArtistsRecord;
}
