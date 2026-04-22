import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  List<String> _categoryList = [
    '528Hz',
    'Electronic',
    'Mental Health',
    'Stress',
    '423Hz',
    'Breathwork',
    'Chakra',
    'Ambient',
    'Solfeggio Scale'
  ];
  List<String> get categoryList => _categoryList;
  set categoryList(List<String> value) {
    _categoryList = value;
  }

  void addToCategoryList(String value) {
    categoryList.add(value);
  }

  void removeFromCategoryList(String value) {
    categoryList.remove(value);
  }

  void removeAtIndexFromCategoryList(int index) {
    categoryList.removeAt(index);
  }

  void updateCategoryListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    categoryList[index] = updateFn(_categoryList[index]);
  }

  void insertAtIndexInCategoryList(int index, String value) {
    categoryList.insert(index, value);
  }

  double _navplayeropacity = 0.0;
  double get navplayeropacity => _navplayeropacity;
  set navplayeropacity(double value) {
    _navplayeropacity = value;
  }

  bool _navPlayerVisible = false;
  bool get navPlayerVisible => _navPlayerVisible;
  set navPlayerVisible(bool value) {
    _navPlayerVisible = value;
  }

  String _PosterImage =
      'https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/thumb.png?alt=media&token=e6577b33-e529-48be-8df3-6a94f5b68e16';
  String get PosterImage => _PosterImage;
  set PosterImage(String value) {
    _PosterImage = value;
  }

  String _title = '';
  String get title => _title;
  set title(String value) {
    _title = value;
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  set isPlaying(bool value) {
    _isPlaying = value;
  }

  double _currentPosition = 0.0;
  double get currentPosition => _currentPosition;
  set currentPosition(double value) {
    _currentPosition = value;
  }

  double _totalDuration = 0.0;
  double get totalDuration => _totalDuration;
  set totalDuration(double value) {
    _totalDuration = value;
  }

  String _songurl = '';
  String get songurl => _songurl;
  set songurl(String value) {
    _songurl = value;
  }

  String _audiourl = '';
  String get audiourl => _audiourl;
  set audiourl(String value) {
    _audiourl = value;
  }

  String _coverImage =
      'https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/thumb.png?alt=media&token=e6577b33-e529-48be-8df3-6a94f5b68e16\n';
  String get coverImage => _coverImage;
  set coverImage(String value) {
    _coverImage = value;
  }

  bool _isSongPlaying = false;
  bool get isSongPlaying => _isSongPlaying;
  set isSongPlaying(bool value) {
    _isSongPlaying = value;
  }

  bool _showplay = false;
  bool get showplay => _showplay;
  set showplay(bool value) {
    _showplay = value;
  }

  List<SongDataStruct> _SongList = [
    SongDataStruct.fromSerializableMap(jsonDecode(
        '{\"songTitle\":\"Flumin Heck\",\"authorName\":\"Matty Chew, Klaust\",\"duration\":\"05:50\",\"songUrl\":\"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3\",\"coverUrl\":\"https://uc579ce35ebaaf7631efd26f0b84.previews.dropboxusercontent.com/p/thumb/ACxfAerkCRXA_PR4BdJNhReNRSLKgdc9tgc3-yCQz_88D8sKX-D2a1GODdm23OqEVpwRTfZ2Id3SvRiYXqXg-RcyPjnqIBiHokHpVEKmUfcCOk5PCHiRn1a9nCTFgxYD7vC1V5k5Hi5avmsDNmwofdPOLXQbZpPzrHGVwhOeb5YtCnC5WX6XeKFY4H5eNXwCYHFU89MoQ8ootiPJNR8JfXyJ-34HErdh1lbDj0MFshLu58BuuuAC3TIZEpTnJLCnUGnVyE3lFU7Th-3llGqaB9vkId15MkJ3ME9xMAdXFaxeucQIm_qosU4cU6zX0E7gsSYn1wM9IffF0WRYDHR1o7cybC_Pu-_LI2Y71kuIBizUHUPkp_Fd6A1YM_-Ixt1CO7k7VSoU4YIkSk3GJpn7rPIv/p.jpeg?is_prewarmed=true\"}')),
    SongDataStruct.fromSerializableMap(jsonDecode(
        '{\"songTitle\":\"Big Budda\",\"authorName\":\"Matty Chew, Klaust\",\"duration\":\"08:54\",\"songUrl\":\"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3\",\"coverUrl\":\"https://uc65645a48e4bb740afa5acec99d.previews.dropboxusercontent.com/p/thumb/ACw1a1awK_YljPm_4_QAfGgrhkCG7wFbHgyalSi5d0wNK-cxwBTQ5m-yKXeBsxLqbx3vYlg-enWIPRsxwzHbQXe46Hb0pnJFEo5EaTLyb6_ZqYxQJka-CgERw1iFven_TpVNH2_Il7-ShRXQtfvgfdhbwikGnKAxht7HdPYVFIs7n4ylqVTuVasrr336q-fWkXUMHk2px9tH21PkGOyLDvadOEw4O_fuqpt6WXqMwt4xEdkRHjBdacl-2XhnzcygxUMSqGNgSGXyV1dwaFAL4WSMZb7hw2EDRj7t4GEtCaq-52zXonpxIq5mgocK_T30nz6g6p7uYIpDgrLk1r5sDE1u6hx-Vuz-eKIaBfaezQ9g9GDerZnqw5KziNFt-zlCKRrWKkw7IqdqN7Mra8szMiqN3iz5D0YV5GbLaGB-v1VxYfDDHra28Q0-wcZjaXohITsxQCWv1H-xCNqcwl4FFVqU/p.png?is_prewarmed=true\"}')),
    SongDataStruct.fromSerializableMap(jsonDecode(
        '{\"songTitle\":\"Timelines (528Hz Slo Mo Edit)\",\"authorName\":\"Matty Chew, Klaust\",\"duration\":\"05:50\",\"songUrl\":\"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3\",\"coverUrl\":\"https://uc4a852529aa92840df70b72fcdf.previews.dropboxusercontent.com/p/thumb/ACxn_GJ7lGmb6GW6F47ieIgt_k0i_20jx3UGcrVUYp9Z7m6VS_OBIvZKoJdPdoBkZj--PEPfE9nP_8-AS5_KwOP8Cho11uKTv0Pd_NtX-MRxPQ52izlw3X4N_1wyIRfrHBV3G1ppYDksvkvb0a4K19kuptHfbSerd_aAd-0nGkGboh8mxAl7CLZLNMWjNNDtrs6ky6qbp-jROURJxZcD939pEOkEuRxvnREfHR09zKjCDazBo86cjIhWNt6EzHsCfybCXQHCVtbGy9cfkbuPccJ0pFTDF50MhsbwjaIGDBqr0nIbO0FikjcsVcQsn_7HySY_H2NgVx2nNA_Ys_nOmK2xnvbV3-QvYeQMBgQPnCpTsCtYmpoYqWszWDNRA7W5MtElutsEboyDRS-zBRaHgyky9VLXKOFB_mlNthvbIRFgPDZQ_Ha5sauGkuLfbSHM-Fp9kNAoQ3Gw3LO8Jiczxqfj/p.png?is_prewarmed=true\"}'))
  ];
  List<SongDataStruct> get SongList => _SongList;
  set SongList(List<SongDataStruct> value) {
    _SongList = value;
  }

  void addToSongList(SongDataStruct value) {
    SongList.add(value);
  }

  void removeFromSongList(SongDataStruct value) {
    SongList.remove(value);
  }

  void removeAtIndexFromSongList(int index) {
    SongList.removeAt(index);
  }

  void updateSongListAtIndex(
    int index,
    SongDataStruct Function(SongDataStruct) updateFn,
  ) {
    SongList[index] = updateFn(_SongList[index]);
  }

  void insertAtIndexInSongList(int index, SongDataStruct value) {
    SongList.insert(index, value);
  }

  double _songProgress = 0.0;
  double get songProgress => _songProgress;
  set songProgress(double value) {
    _songProgress = value;
  }

  String _artist = '';
  String get artist => _artist;
  set artist(String value) {
    _artist = value;
  }

  String _detTitle = '';
  String get detTitle => _detTitle;
  set detTitle(String value) {
    _detTitle = value;
  }

  String _detaiImage =
      'https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/thumb.png?alt=media&token=e6577b33-e529-48be-8df3-6a94f5b68e16';
  String get detaiImage => _detaiImage;
  set detaiImage(String value) {
    _detaiImage = value;
  }

  String _DescrptionDetail = '';
  String get DescrptionDetail => _DescrptionDetail;
  set DescrptionDetail(String value) {
    _DescrptionDetail = value;
  }

  String _artistDetail = '';
  String get artistDetail => _artistDetail;
  set artistDetail(String value) {
    _artistDetail = value;
  }

  bool _notificationisseen = false;
  bool get notificationisseen => _notificationisseen;
  set notificationisseen(bool value) {
    _notificationisseen = value;
  }

  bool _searchactive = false;
  bool get searchactive => _searchactive;
  set searchactive(bool value) {
    _searchactive = value;
  }

  int _songnum = 0;
  int get songnum => _songnum;
  set songnum(int value) {
    _songnum = value;
  }

  DocumentReference? _activeSongRef =
      FirebaseFirestore.instance.doc('/songs/zeTBd9KN2m3PXNV6X7Vm');
  DocumentReference? get activeSongRef => _activeSongRef;
  set activeSongRef(DocumentReference? value) {
    _activeSongRef = value;
  }

  bool _miniplayer = false;
  bool get miniplayer => _miniplayer;
  set miniplayer(bool value) {
    _miniplayer = value;
  }

  List<int> _songslist = [];
  List<int> get songslist => _songslist;
  set songslist(List<int> value) {
    _songslist = value;
  }

  void addToSongslist(int value) {
    songslist.add(value);
  }

  void removeFromSongslist(int value) {
    songslist.remove(value);
  }

  void removeAtIndexFromSongslist(int index) {
    songslist.removeAt(index);
  }

  void updateSongslistAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    songslist[index] = updateFn(_songslist[index]);
  }

  void insertAtIndexInSongslist(int index, int value) {
    songslist.insert(index, value);
  }

  List<String> _tags = [
    'General',
    'Yoga',
    'Travel',
    'Meditation',
    'Promotion',
    'Education',
    'Books',
    'Podcast',
    'Question',
    'YouTube'
  ];
  List<String> get tags => _tags;
  set tags(List<String> value) {
    _tags = value;
  }

  void addToTags(String value) {
    tags.add(value);
  }

  void removeFromTags(String value) {
    tags.remove(value);
  }

  void removeAtIndexFromTags(int index) {
    tags.removeAt(index);
  }

  void updateTagsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    tags[index] = updateFn(_tags[index]);
  }

  void insertAtIndexInTags(int index, String value) {
    tags.insert(index, value);
  }

  List<String> _selectedtags = [];
  List<String> get selectedtags => _selectedtags;
  set selectedtags(List<String> value) {
    _selectedtags = value;
  }

  void addToSelectedtags(String value) {
    selectedtags.add(value);
  }

  void removeFromSelectedtags(String value) {
    selectedtags.remove(value);
  }

  void removeAtIndexFromSelectedtags(int index) {
    selectedtags.removeAt(index);
  }

  void updateSelectedtagsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    selectedtags[index] = updateFn(_selectedtags[index]);
  }

  void insertAtIndexInSelectedtags(int index, String value) {
    selectedtags.insert(index, value);
  }

  bool _shuffle = false;
  bool get shuffle => _shuffle;
  set shuffle(bool value) {
    _shuffle = value;
  }

  bool _repeate = false;
  bool get repeate => _repeate;
  set repeate(bool value) {
    _repeate = value;
  }
}
