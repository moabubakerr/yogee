import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WrittenNoteRecord extends FirestoreRecord {
  WrittenNoteRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "writer" field.
  DocumentReference? _writer;
  DocumentReference? get writer => _writer;
  bool hasWriter() => _writer != null;

  // "topic" field.
  String? _topic;
  String get topic => _topic ?? '';
  bool hasTopic() => _topic != null;

  // "time" field.
  DateTime? _time;
  DateTime? get time => _time;
  bool hasTime() => _time != null;

  // "is_voice" field.
  bool? _isVoice;
  bool get isVoice => _isVoice ?? false;
  bool hasIsVoice() => _isVoice != null;

  // "voicenote" field.
  String? _voicenote;
  String get voicenote => _voicenote ?? '';
  bool hasVoicenote() => _voicenote != null;

  // "starred" field.
  bool? _starred;
  bool get starred => _starred ?? false;
  bool hasStarred() => _starred != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _writer = snapshotData['writer'] as DocumentReference?;
    _topic = snapshotData['topic'] as String?;
    _time = snapshotData['time'] as DateTime?;
    _isVoice = snapshotData['is_voice'] as bool?;
    _voicenote = snapshotData['voicenote'] as String?;
    _starred = snapshotData['starred'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('written_note');

  static Stream<WrittenNoteRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WrittenNoteRecord.fromSnapshot(s));

  static Future<WrittenNoteRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => WrittenNoteRecord.fromSnapshot(s));

  static WrittenNoteRecord fromSnapshot(DocumentSnapshot snapshot) =>
      WrittenNoteRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static WrittenNoteRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      WrittenNoteRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WrittenNoteRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is WrittenNoteRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createWrittenNoteRecordData({
  String? name,
  DocumentReference? writer,
  String? topic,
  DateTime? time,
  bool? isVoice,
  String? voicenote,
  bool? starred,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'writer': writer,
      'topic': topic,
      'time': time,
      'is_voice': isVoice,
      'voicenote': voicenote,
      'starred': starred,
    }.withoutNulls,
  );

  return firestoreData;
}

class WrittenNoteRecordDocumentEquality implements Equality<WrittenNoteRecord> {
  const WrittenNoteRecordDocumentEquality();

  @override
  bool equals(WrittenNoteRecord? e1, WrittenNoteRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.writer == e2?.writer &&
        e1?.topic == e2?.topic &&
        e1?.time == e2?.time &&
        e1?.isVoice == e2?.isVoice &&
        e1?.voicenote == e2?.voicenote &&
        e1?.starred == e2?.starred;
  }

  @override
  int hash(WrittenNoteRecord? e) => const ListEquality().hash([
        e?.name,
        e?.writer,
        e?.topic,
        e?.time,
        e?.isVoice,
        e?.voicenote,
        e?.starred
      ]);

  @override
  bool isValidKey(Object? o) => o is WrittenNoteRecord;
}
