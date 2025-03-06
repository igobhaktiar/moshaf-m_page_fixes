class PlaylistSurahModel {
  final int? surahId;
  final String? surahName;
  final String? reciterName;
  final String? reciterArabicName;
  final String? reciterEnglishName;
  final String? audioPath;
  final String? audioUrl;
  final int? playlistId;

  PlaylistSurahModel({
    this.surahId,
    this.surahName,
    this.reciterName,
    this.reciterArabicName,
    this.reciterEnglishName,
    this.audioPath,
    this.audioUrl,
    this.playlistId,
  });

  Map<String, dynamic> toMap() {
    return {
      'surah_id': surahId,
      'surah_name': surahName,
      'reciter_name': reciterName,
      'reciter_arabic_name': reciterArabicName,
      'reciter_english_name': reciterEnglishName,
      'audio_path': audioPath,
      'audio_url': audioUrl,
      'playlist_id': playlistId,
    };
  }

  factory PlaylistSurahModel.fromMap(Map<String, dynamic> map) {
    return PlaylistSurahModel(
      surahId: map['surah_id'],
      surahName: map['surah_name'],
      reciterName: map['reciter_name'],
      reciterArabicName: map['reciter_arabic_name'],
      reciterEnglishName: map['reciter_english_name'],
      audioPath: map['audio_path'],
      audioUrl: map['audio_url'],
      playlistId: map['playlist_id'],
    );
  }

  @override
  String toString() {
    return 'PlaylistSurahModel(surahId: $surahId, surahName: $surahName, reciterName: $reciterName, reciterArabicName: $reciterArabicName, reciterEnglishName: $reciterEnglishName, audioPath: $audioPath, audioUrl: $audioUrl, playlistId: $playlistId)';
  }
}
