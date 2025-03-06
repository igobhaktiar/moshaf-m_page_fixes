import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/data/models/translation_page_list_model.dart';

import '../../../../../core/data_sources/database_service.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import '../../../data/datasources/quran_translation_database_service.dart';
import '../../../data/datasources/quran_translation_service.dart';
import '../../../data/models/translation_language_display_model.dart';
import '../../../data/models/translation_page_object_to_save.dart';
import 'translation_page_cubit.dart';

class TranslationPageCubitService {
  final int defaultTafseerPageNumber = 1;
  final String languageCode = "en";

  Future<void> initAndLoadPage(
    BuildContext context, {
    required String languageCode,
  }) async {
    final translationPageCubit = BlocProvider.of<TranslationPageCubit>(context);
    translationPageCubit.setPageToLoading();
    TranslationPageObjectToSave translationPageObjectToSave =
        translationPageCubit.getCurrentTranslationPageDetails();
    int pageNumber = 1;
    if (translationPageObjectToSave.languageCode == languageCode) {
      pageNumber = translationPageObjectToSave.pageNumber;
    }
    translationPageObjectToSave = TranslationPageObjectToSave(
      pageNumber: pageNumber,
      languageCode: languageCode,
    );
    List<TranslationPageList> currentTranslationList =
        await QuranTranslationDatabaseService.fetchTranslationList(
      DatabaseService.shamelDb!,
      translationPageObjectToSave.languageCode,
      translationPageObjectToSave.pageNumber,
    );
    if (currentTranslationList.isNotEmpty) {
      translationPageCubit.setCurrentTranslationPageDetails(
          translationPageObjectToSave, currentTranslationList.first);
    }
  }

  Future<void> initAndLoadPageFromBottomBar(
    BuildContext context, {
    required int fetchPageNumber,
    String? fetchLanguageCode,
    bool isLimited = false,
  }) async {
    final translationPageCubit = BlocProvider.of<TranslationPageCubit>(context);
    translationPageCubit.setPageToLoading();
    TranslationPageObjectToSave translationPageObjectToSave =
        translationPageCubit.getCurrentTranslationPageDetails();

    translationPageObjectToSave = TranslationPageObjectToSave(
      pageNumber: fetchPageNumber,
      languageCode:
          fetchLanguageCode ?? translationPageObjectToSave.languageCode,
    );
    List<TranslationPageList> currentTranslationList =
        await QuranTranslationDatabaseService.fetchTranslationList(
      DatabaseService.shamelDb!,
      translationPageObjectToSave.languageCode,
      translationPageObjectToSave.pageNumber,
    );
    if (currentTranslationList.isNotEmpty) {
      List<AyahWithTranslation> newTranslationList = [];
      if (isLimited) {
        bool isStartAdding = false;
        for (final ayah in currentTranslationList.first.ayahs) {
          if (ayah.ayahId == BottomWidgetService.ayahId &&
              ayah.surahIndex == BottomWidgetService.surahId) {
            isStartAdding = true;
          }
          if (isStartAdding) {
            newTranslationList.add(ayah);
          }
        }
        currentTranslationList.first.ayahs = newTranslationList;
      }
      translationPageCubit.setCurrentTranslationPageDetails(
          translationPageObjectToSave, currentTranslationList.first);
    }
  }

  Future<void> updatePageNumber(
    BuildContext context, {
    required int newPageNumber,
    required String languageCode,
  }) async {
    final translationPageCubit = BlocProvider.of<TranslationPageCubit>(context);
    translationPageCubit.setPageToLoading();
    TranslationPageObjectToSave translationPageObjectToSave =
        TranslationPageObjectToSave(
      pageNumber: newPageNumber,
      languageCode: languageCode,
    );
    List<TranslationPageList> currentTranslationList =
        await QuranTranslationDatabaseService.fetchTranslationList(
      DatabaseService.shamelDb!,
      translationPageObjectToSave.languageCode,
      translationPageObjectToSave.pageNumber,
    );
    if (currentTranslationList.isNotEmpty) {
      translationPageCubit.setCurrentTranslationPageDetails(
          translationPageObjectToSave, currentTranslationList.first);
    }
  }

  String? getCurrentLanguage(
    BuildContext context,
  ) {
    List<TranslationLanguageDisplayModel> languageList =
        QuranTranslationService().getLanguageList();
    TranslationLanguageDisplayModel? languageToReturn;
    final translationPageCubitState =
        BlocProvider.of<TranslationPageCubit>(context).state;
    if (translationPageCubitState is CurrentTranslationPageState) {
      for (final TranslationLanguageDisplayModel currentLanguage
          in languageList) {
        if (currentLanguage.languageCode ==
            translationPageCubitState.languageCode) {
          languageToReturn = currentLanguage;
        }
      }
    }
    return (languageToReturn != null) ? languageToReturn.languageCode : null;
  }
}
