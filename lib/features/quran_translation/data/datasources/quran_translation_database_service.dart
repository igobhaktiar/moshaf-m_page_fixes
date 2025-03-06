import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/data_sources/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:translator/translator.dart';

import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';
import '../models/translation_page_list_model.dart';

class QuranTranslationDatabaseService {
  QuranTranslationDatabaseService._();
  static Future<String?> fetchAyahText(int surahIndex, int ayahIndex) async {
    String? ayahText;

    try {
      var db = DatabaseService.shamelDb!;
      await db.transaction((txn) async {
        // SQL query to fetch the ayah text
        const String query = '''
        SELECT quran.QeraatKuwait 
        FROM index_uthmanic_hafs
        JOIN verses ON index_uthmanic_hafs.surahIndex = verses.surahIndex 
          AND verses.ayahIndex BETWEEN index_uthmanic_hafs.ayahFromIndex 
          AND index_uthmanic_hafs.ayahToIndex
        JOIN quran ON verses.id = quran.verseId
        WHERE index_uthmanic_hafs.surahIndex = ? 
          AND verses.ayahIndex = ?
      ''';

        final List<Map<String, dynamic>> result = await txn.rawQuery(
          query,
          [surahIndex, ayahIndex],
        );

        // Check if we got any results
        if (result.isNotEmpty) {
          ayahText = result.first['QeraatKuwait'];
        }
      });
    } catch (e) {
      debugPrint('Error fetching ayah text: ${e.toString()}');
      return null;
    }

    return ayahText;
  }

  static Future<List<TranslationPageList>> fetchTranslationList(
      Database db, String languageCode, int pageNumber) async {
    // Create a list to hold the final result
    List<TranslationPageList> translationList = [];
    try {
      await db.transaction((txn) async {
        // SQL query to fetch data
        String queryToFetchPageData =
            ' SELECT index_uthmanic_hafs.pageIndex, index_uthmanic_hafs.surahIndex, surah.displayName AS surahName, verses.ayahIndex AS ayahId, quran.QeraatKuwait, translateVerses.translateText FROM index_uthmanic_hafs JOIN surah ON index_uthmanic_hafs.surahIndex = surah.surahIndex JOIN verses ON index_uthmanic_hafs.surahIndex = verses.surahIndex AND verses.ayahIndex BETWEEN index_uthmanic_hafs.ayahFromIndex AND index_uthmanic_hafs.ayahToIndex JOIN quran ON verses.id = quran.verseId JOIN translateVerses ON quran.verseId = translateVerses.verseId WHERE index_uthmanic_hafs.pageIndex = $pageNumber AND translateVerses.languageCode = "$languageCode" ORDER BY index_uthmanic_hafs.surahIndex AND verses.ayahIndex;';

        final List<Map<String, dynamic>> result = await txn.rawQuery(
          queryToFetchPageData,
        );

        Map<int, List<AyahWithTranslation>> groupedData = {};

        for (var row in result) {
          String translatedText = row['translateText'] ?? '';

          if (translatedText.isEmpty) {
            GoogleTranslator translator = GoogleTranslator();
            await translator
                .translate(row['QeraatKuwait'], from: 'ar', to: languageCode)
                .then(
                  (value) => translatedText = value.text,
                );
          }

          int pageIndex = row['pageIndex'];
          AyahWithTranslation ayah = AyahWithTranslation(
            ayahId: row['ayahId'],
            verseUthmani: row['QeraatKuwait'],
            translatedText: translatedText,
            surahIndex: row['surahIndex'],
            surahName: row['surahName'],
          );

          if (!groupedData.containsKey(pageIndex)) {
            groupedData[pageIndex] = [];
          }
          groupedData[pageIndex]!.add(ayah);
        }

        // Convert to List<TafseerList>
        translationList = groupedData.entries.map((entry) {
          return TranslationPageList(pageIndex: entry.key, ayahs: entry.value);
        }).toList();
      });
      // Execute the SQL query inside a transaction
    } catch (e) {
      debugPrint(e.toString());
    }

    return translationList;
  }

  static Future<AyahWithTranslation?> fetchAyahWithAyahId({
    required Database db,
    required String languageCode,
    required AyahModel ayahModel,
  }) async {
    // Create a list to hold the final result
    AyahWithTranslation? ayahWithTranslation;
    List<TranslationPageList> translationList = await fetchTranslationList(
      db,
      languageCode,
      ayahModel.page!,
    );

    if (translationList.isNotEmpty) {
      for (final TranslationPageList singlePageList in translationList) {
        if (singlePageList.pageIndex == ayahModel.page!) {
          for (final AyahWithTranslation singleAyahWithTranslation
              in singlePageList.ayahs) {
            if (singleAyahWithTranslation.ayahId == ayahModel.numberInSurah) {
              ayahWithTranslation = singleAyahWithTranslation;
            }
          }
        }
      }
    }

    return ayahWithTranslation;
  }
}
