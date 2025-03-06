import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';
import '../models/tafseer_reading_model.dart';

class TafseerDatabaseService {
  TafseerDatabaseService._();

  static Future<List<TafseerPageList>> fetchTafseerList(
      Database db, String tafseerCode, int pageNumber) async {
    // Create a list to hold the final result
    List<TafseerPageList> tafseerList = [];
    try {
      await db.transaction((txn) async {
        // SQL query to fetch data
        // String queryToFetchPageData =
        //     'SELECT ih.pageIndex, ih.surahIndex, s.name AS surahName, q.id AS ayahId, q.QeraatKuwait, t.tafsserText FROM index_uthmanic_hafs ih JOIN quran q ON q.verseId BETWEEN ih.ayahFromIndex AND ih.ayahToIndex LEFT JOIN tafseer t ON q.verseId = t.verseId AND t.tafsserCode = "$tafseerCode" JOIN surah s ON ih.surahIndex = s.id WHERE ih.pageIndex  = $pageNumber ORDER BY ih.pageIndex, q.id;';
        String queryToFetchPageData =
            'SELECT index_uthmanic_hafs.pageIndex, index_uthmanic_hafs.surahIndex, surah.displayName AS surahName, verses.ayahIndex AS ayahId, quran.QeraatKuwait, tafseer.tafsserText FROM index_uthmanic_hafs JOIN surah ON index_uthmanic_hafs.surahIndex = surah.surahIndex JOIN verses ON index_uthmanic_hafs.surahIndex = verses.surahIndex AND verses.ayahIndex BETWEEN index_uthmanic_hafs.ayahFromIndex AND index_uthmanic_hafs.ayahToIndex JOIN quran ON verses.id = quran.verseId JOIN tafseer ON quran.verseId = tafseer.verseId WHERE index_uthmanic_hafs.pageIndex = $pageNumber AND tafseer.tafsserCode = "$tafseerCode" ORDER BY index_uthmanic_hafs.surahIndex AND verses.ayahIndex; ';

        final List<Map<String, dynamic>> result = await txn.rawQuery(
          queryToFetchPageData,
        );

        // Group data by pageIndex
        Map<int, List<AyahWithTafseer>> groupedData = {};

        for (var row in result) {
          int pageIndex = row['pageIndex'];
          AyahWithTafseer ayah = AyahWithTafseer(
            ayahId: row['ayahId'],
            verseUthmani: row['QeraatKuwait'],
            tafseerText: row['tafsserText'] ?? '',
            surahIndex: row['surahIndex'],
            surahName: row['surahName'],
          );

          if (!groupedData.containsKey(pageIndex)) {
            groupedData[pageIndex] = [];
          }
          groupedData[pageIndex]!.add(ayah);
        }

        // Convert to List<TafseerList>
        tafseerList = groupedData.entries.map((entry) {
          return TafseerPageList(pageIndex: entry.key, ayahs: entry.value);
        }).toList();
      });
      // Execute the SQL query inside a transaction
    } catch (e) {
      debugPrint(e.toString());
    }

    return tafseerList;
  }

  static Future<AyahWithTafseer?> fetchAyahWithAyahId({
    required Database db,
    required String bookCode,
    required AyahModel ayahModel,
  }) async {
    // Create a list to hold the final result
    AyahWithTafseer? ayahWithTafseer;
    List<TafseerPageList> tafseerList = await fetchTafseerList(
      db,
      bookCode,
      ayahModel.page!,
    );

    if (tafseerList.isNotEmpty) {
      for (final TafseerPageList singlePageList in tafseerList) {
        if (singlePageList.pageIndex == ayahModel.page!) {
          for (final AyahWithTafseer singleAyahWithTafseer
              in singlePageList.ayahs) {
            if (singleAyahWithTafseer.ayahId == ayahModel.numberInSurah) {
              ayahWithTafseer = singleAyahWithTafseer;
            }
          }
        }
      }
    }

    return ayahWithTafseer;
  }
}
