class TranslationPageList {
  final int pageIndex;
  List<AyahWithTranslation> ayahs;

  TranslationPageList({
    required this.pageIndex,
    required this.ayahs,
  });
}

class AyahWithTranslation {
  final int ayahId;
  final String verseUthmani;
  final int surahIndex;
  final String surahName;
  final String translatedText;

  AyahWithTranslation({
    required this.ayahId,
    required this.verseUthmani,
    required this.surahIndex,
    required this.surahName,
    required this.translatedText,
  });
}

// Method 1: Using Set
List<AyahWithTranslation> removeDuplicateAyahs(
    List<AyahWithTranslation> ayahs) {
  return ayahs.toSet().toList();
}

// Method 2: Using fold (keeps the last occurrence of duplicates)
List<AyahWithTranslation> removeDuplicateAyahsKeepLast(
    List<AyahWithTranslation> ayahs) {
  return ayahs
      .fold<Map<String, AyahWithTranslation>>({}, (map, ayah) {
        map['${ayah.ayahId}_${ayah.surahIndex}'] = ayah;
        return map;
      })
      .values
      .toList();
}

// Method 3: Using where (keeps the first occurrence of duplicates)
List<AyahWithTranslation> removeDuplicateAyahsKeepFirst(
    List<AyahWithTranslation> ayahs) {
  final seen = <String>{};
  return ayahs.where((ayah) {
    final key = '${ayah.ayahId}_${ayah.surahIndex}';
    return seen.add(key); // add() returns false if element already exists
  }).toList();
}
