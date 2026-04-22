import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificationsRecord extends FirestoreRecord {
  NotificationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "isread" field.
  bool? _isread;
  bool get isread => _isread ?? false;
  bool hasIsread() => _isread != null;

  // "ispost" field.
  bool? _ispost;
  bool get ispost => _ispost ?? false;
  bool hasIspost() => _ispost != null;

  // "is_like" field.
  bool? _isLike;
  bool get isLike => _isLike ?? false;
  bool hasIsLike() => _isLike != null;

  // "postref" field.
  DocumentReference? _postref;
  DocumentReference? get postref => _postref;
  bool hasPostref() => _postref != null;

  // "madeby" field.
  DocumentReference? _madeby;
  DocumentReference? get madeby => _madeby;
  bool hasMadeby() => _madeby != null;

  // "madeto" field.
  DocumentReference? _madeto;
  DocumentReference? get madeto => _madeto;
  bool hasMadeto() => _madeto != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  void _initializeFields() {
    _isread = snapshotData['isread'] as bool?;
    _ispost = snapshotData['ispost'] as bool?;
    _isLike = snapshotData['is_like'] as bool?;
    _postref = snapshotData['postref'] as DocumentReference?;
    _madeby = snapshotData['madeby'] as DocumentReference?;
    _madeto = snapshotData['madeto'] as DocumentReference?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationsRecord.fromSnapshot(s));

  static Future<NotificationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationsRecord.fromSnapshot(s));

  static NotificationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationsRecordData({
  bool? isread,
  bool? ispost,
  bool? isLike,
  DocumentReference? postref,
  DocumentReference? madeby,
  DocumentReference? madeto,
  DateTime? timestamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'isread': isread,
      'ispost': ispost,
      'is_like': isLike,
      'postref': postref,
      'madeby': madeby,
      'madeto': madeto,
      'timestamp': timestamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationsRecordDocumentEquality
    implements Equality<NotificationsRecord> {
  const NotificationsRecordDocumentEquality();

  @override
  bool equals(NotificationsRecord? e1, NotificationsRecord? e2) {
    return e1?.isread == e2?.isread &&
        e1?.ispost == e2?.ispost &&
        e1?.isLike == e2?.isLike &&
        e1?.postref == e2?.postref &&
        e1?.madeby == e2?.madeby &&
        e1?.madeto == e2?.madeto &&
        e1?.timestamp == e2?.timestamp;
  }

  @override
  int hash(NotificationsRecord? e) => const ListEquality().hash([
        e?.isread,
        e?.ispost,
        e?.isLike,
        e?.postref,
        e?.madeby,
        e?.madeto,
        e?.timestamp
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationsRecord;
}
