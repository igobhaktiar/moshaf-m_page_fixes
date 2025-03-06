import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/data/models/translation_page_list_model.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/presentation/cubit/translation_page/translation_page_cubit_service.dart';
import 'package:qeraat_moshaf_kwait/features/tafseer/data/datasources/tafseer_database_service.dart';
import 'package:qeraat_moshaf_kwait/features/tafseer/data/models/tafseer_reading_model.dart';

import '../../../../../core/data_sources/database_service.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../../quran_translation/data/datasources/quran_translation_database_service.dart';
import '../../../../tafseer/presentation/cubit/tafseer_page/tafseer_page_cubit_service.dart';

class ShareDatabaseService {
  AyahModel? getAyahFromTashkilList(
    BuildContext context,
    int previousSurahNumber,
    int previousNumberInSurah,
  ) {
    List<AyahModel> tashkeelList =
        EssentialMoshafCubit.get(context).allAyatWithTashkeelList;
    AyahModel? nextAyahModel;
    for (int i = 0; i < tashkeelList.length; i++) {
      if (tashkeelList[i].surahNumber == previousSurahNumber &&
          tashkeelList[i].numberInSurah == previousNumberInSurah &&
          i + 1 < tashkeelList.length) {
        nextAyahModel = tashkeelList[i + 1];
      }
    }
    return nextAyahModel;
  }

  Future<(AyahWithTafseer?, String)> getSurahWithTafseer(
      {required AyahModel ayah}) async {
    AyahWithTafseer? currentAyahWithTafseer;
    String? currentTafseerCode;
    TafseerPageCubitService tafseerPageCubitService = TafseerPageCubitService();

    final BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      currentTafseerCode =
          tafseerPageCubitService.getCurrentTafseerBook(appContext);
      currentAyahWithTafseer = await TafseerDatabaseService.fetchAyahWithAyahId(
        db: DatabaseService.shamelDb!,
        bookCode: currentTafseerCode ?? tafseerPageCubitService.tafseerCode,
        ayahModel: ayah,
      );
    }
    return (
      currentAyahWithTafseer,
      (currentTafseerCode ?? tafseerPageCubitService.tafseerCode)
    );
  }

  Future<(AyahWithTafseer?, String)> getAyahText(
      {required AyahModel ayah}) async {
    AyahWithTafseer? currentAyahWithTafseer;
    String? currentTafseerCode;
    TafseerPageCubitService tafseerPageCubitService = TafseerPageCubitService();

    final BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      currentTafseerCode =
          tafseerPageCubitService.getCurrentTafseerBook(appContext);
      currentAyahWithTafseer = await TafseerDatabaseService.fetchAyahWithAyahId(
        db: DatabaseService.shamelDb!,
        bookCode: currentTafseerCode ?? tafseerPageCubitService.tafseerCode,
        ayahModel: ayah,
      );
    }
    return (
      currentAyahWithTafseer,
      (currentTafseerCode ?? tafseerPageCubitService.tafseerCode)
    );
  }

  Future<(AyahWithTranslation?, String)> getSurahWithTranslation({
    required AyahModel ayah,
  }) async {
    AyahWithTranslation? currentAyahWithTranslation;
    String? currentLanguage;
    TranslationPageCubitService translationPageCubitService =
        TranslationPageCubitService();

    final BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      currentLanguage =
          translationPageCubitService.getCurrentLanguage(appContext);
      currentAyahWithTranslation =
          await QuranTranslationDatabaseService.fetchAyahWithAyahId(
        db: DatabaseService.shamelDb!,
        languageCode:
            currentLanguage ?? translationPageCubitService.languageCode,
        ayahModel: ayah,
      );
    }
    return (
      currentAyahWithTranslation,
      (currentLanguage ?? translationPageCubitService.languageCode)
    );
  }
}
