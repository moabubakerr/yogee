import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PostsRecord extends FirestoreRecord {
  PostsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "topic" field.
  String? _topic;
  String get topic => _topic ?? '';
  bool hasTopic() => _topic != null;

  // "poster" field.
  DocumentReference? _poster;
  DocumentReference? get poster => _poster;
  bool hasPoster() => _poster != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  bool hasImage() => _image != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "des" field.
  String? _des;
  String get des => _des ?? '';
  bool hasDes() => _des != null;

  // "artist" field.
  String? _artist;
  String get artist => _artist ?? '';
  bool hasArtist() => _artist != null;

  // "likes" field.
  List<DocumentReference>? _likes;
  List<DocumentReference> get likes => _likes ?? const [];
  bool hasLikes() => _likes != null;

  // "comments" field.
  DocumentReference? _comments;
  DocumentReference? get comments => _comments;
  bool hasComments() => _comments != null;

  // "images" field.
  List<String>? _images;
  List<String> get images => _images ?? const [];
  bool hasImages() => _images != null;

  // "tags" field.
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  void _initializeFields() {
    _topic = snapshotData['topic'] as String?;
    _poster = snapshotData['poster'] as DocumentReference?;
    _image = snapshotData['image'] as String?;
    _date = snapshotData['date'] as DateTime?;
    _des = snapshotData['des'] as String?;
    _artist = snapshotData['artist'] as String?;
    _likes = getDataList(snapshotData['likes']);
    _comments = snapshotData['comments'] as DocumentReference?;
    _images = getDataList(snapshotData['images']);
    _tags = getDataList(snapshotData['tags']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('posts');

  static Stream<PostsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PostsRecord.fromSnapshot(s));

  static Future<PostsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PostsRecord.fromSnapshot(s));

  static PostsRecord fromSnapshot(DocumentSnapshot snapshot) => PostsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PostsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PostsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PostsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PostsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPostsRecordData({
  String? topic,
  DocumentReference? poster,
  String? image,
  DateTime? date,
  String? des,
  String? artist,
  DocumentReference? comments,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'topic': topic,
      'poster': poster,
      'image': image,
      'date': date,
      'des': des,
      'artist': artist,
      'comments': comments,
    }.withoutNulls,
  );

  return firestoreData;
}

class PostsRecordDocumentEquality implements Equality<PostsRecord> {
  const PostsRecordDocumentEquality();

  @override
  bool equals(PostsRecord? e1, PostsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.topic == e2?.topic &&
        e1?.poster == e2?.poster &&
        e1?.image == e2?.image &&
        e1?.date == e2?.date &&
        e1?.des == e2?.des &&
        e1?.artist == e2?.artist &&
        listEquality.equals(e1?.likes, e2?.likes) &&
        e1?.comments == e2?.comments &&
        listEquality.equals(e1?.images, e2?.images) &&
        listEquality.equals(e1?.tags, e2?.tags);
  }

  @override
  int hash(PostsRecord? e) => const ListEquality().hash([
        e?.topic,
        e?.poster,
        e?.image,
        e?.date,
        e?.des,
        e?.artist,
        e?.likes,
        e?.comments,
        e?.images,
        e?.tags
      ]);

  @override
  bool isValidKey(Object? o) => o is PostsRecord;
}
