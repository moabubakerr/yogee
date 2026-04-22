class SongData {
  final String songTitle;
  final String coverUrl; // Renamed 'postor' to 'posterUrl' for clarity
  final String authorName;
  final String duration;
  final String songUrl; // Added songUrl, as it is essential for playback

  const SongData({
    required this.songTitle,
    required this.coverUrl,
    required this.authorName,
    required this.duration,
    required this.songUrl, // Essential for loading the audio
  });

  // Optional: A factory constructor to create a SongData object from a Map (like from Firestore/API)
  factory SongData.fromMap(Map<String, dynamic> map) {
    return SongData(
      songTitle: map['songTitle'] as String? ?? 'Unknown Title',
      coverUrl: map['posterUrl'] as String? ?? '',
      authorName: map['authorName'] as String? ?? 'Unknown Artist',
      // Duration is often stored as milliseconds or seconds in databases
      duration: map['durationMs'] ?? "",
      songUrl: map['songUrl'] as String? ?? '',
    );
  }

  // Optional: A method to convert the SongData object back into a Map
  Map<String, dynamic> toMap() {
    return {
      'songTitle': songTitle,
      'posterUrl': coverUrl,
      'authorName': authorName,
      'durationMs': duration,
      'songUrl': songUrl,
    };
  }
}
