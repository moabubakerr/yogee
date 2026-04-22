import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "username" field.
  String? _username;
  String get username => _username ?? '';
  bool hasUsername() => _username != null;

  // "Bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  bool hasBio() => _bio != null;

  // "from" field.
  String? _from;
  String get from => _from ?? '';
  bool hasFrom() => _from != null;

  // "currentlocation" field.
  String? _currentlocation;
  String get currentlocation => _currentlocation ?? '';
  bool hasCurrentlocation() => _currentlocation != null;

  // "following" field.
  List<DocumentReference>? _following;
  List<DocumentReference> get following => _following ?? const [];
  bool hasFollowing() => _following != null;

  // "followers" field.
  List<DocumentReference>? _followers;
  List<DocumentReference> get followers => _followers ?? const [];
  bool hasFollowers() => _followers != null;

  // "blocked" field.
  List<DocumentReference>? _blocked;
  List<DocumentReference> get blocked => _blocked ?? const [];
  bool hasBlocked() => _blocked != null;

  // "Interests" field.
  List<String>? _interests;
  List<String> get interests => _interests ?? const [];
  bool hasInterests() => _interests != null;

  // "favsongs" field.
  List<int>? _favsongs;
  List<int> get favsongs => _favsongs ?? const [];
  bool hasFavsongs() => _favsongs != null;

  // "announcement_notification" field.
  bool? _announcementNotification;
  bool get announcementNotification => _announcementNotification ?? false;
  bool hasAnnouncementNotification() => _announcementNotification != null;

  // "appupdate_notifications" field.
  bool? _appupdateNotifications;
  bool get appupdateNotifications => _appupdateNotifications ?? false;
  bool hasAppupdateNotifications() => _appupdateNotifications != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _username = snapshotData['username'] as String?;
    _bio = snapshotData['Bio'] as String?;
    _from = snapshotData['from'] as String?;
    _currentlocation = snapshotData['currentlocation'] as String?;
    _following = getDataList(snapshotData['following']);
    _followers = getDataList(snapshotData['followers']);
    _blocked = getDataList(snapshotData['blocked']);
    _interests = getDataList(snapshotData['Interests']);
    _favsongs = getDataList(snapshotData['favsongs']);
    _announcementNotification =
        snapshotData['announcement_notification'] as bool?;
    _appupdateNotifications = snapshotData['appupdate_notifications'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? username,
  String? bio,
  String? from,
  String? currentlocation,
  bool? announcementNotification,
  bool? appupdateNotifications,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'username': username,
      'Bio': bio,
      'from': from,
      'currentlocation': currentlocation,
      'announcement_notification': announcementNotification,
      'appupdate_notifications': appupdateNotifications,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.username == e2?.username &&
        e1?.bio == e2?.bio &&
        e1?.from == e2?.from &&
        e1?.currentlocation == e2?.currentlocation &&
        listEquality.equals(e1?.following, e2?.following) &&
        listEquality.equals(e1?.followers, e2?.followers) &&
        listEquality.equals(e1?.blocked, e2?.blocked) &&
        listEquality.equals(e1?.interests, e2?.interests) &&
        listEquality.equals(e1?.favsongs, e2?.favsongs) &&
        e1?.announcementNotification == e2?.announcementNotification &&
        e1?.appupdateNotifications == e2?.appupdateNotifications;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.username,
        e?.bio,
        e?.from,
        e?.currentlocation,
        e?.following,
        e?.followers,
        e?.blocked,
        e?.interests,
        e?.favsongs,
        e?.announcementNotification,
        e?.appupdateNotifications
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
