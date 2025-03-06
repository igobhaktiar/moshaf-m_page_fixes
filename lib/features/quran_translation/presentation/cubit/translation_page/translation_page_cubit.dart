import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/data/models/translation_page_object_to_save.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/data_sources/database_service.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../data/datasources/quran_translation_database_service.dart';
import '../../../data/models/translation_page_list_model.dart';

part 'translation_page_state.dart';

class TranslationPageCubit extends Cubit<TranslationPageState> {
  TranslationPageCubit({required this.sharedPreferences})
      : super(CurrentTranslationPageState(
          pageNumber: 1,
          languageCode: 'en',
          currentTranslationPageList:
              TranslationPageList(ayahs: [], pageIndex: 1),
        ));
  static TranslationPageCubit get(context) => BlocProvider.of(context);
  final SharedPreferences sharedPreferences;
  init() async {
    emit(CurrentTranslationPageLoading());
    TranslationPageObjectToSave translationPageObjectToSave;
    String savedTranslationPageDetails =
        sharedPreferences.getString(AppStrings.savedTranslationPage) ?? '';
    if (savedTranslationPageDetails.isEmpty) {
      translationPageObjectToSave =
          TranslationPageObjectToSave(pageNumber: 1, languageCode: 'en');
    } else {
      translationPageObjectToSave =
          TranslationPageObjectToSave.fromRawJson(savedTranslationPageDetails);
    }
    List<TranslationPageList> currentTranslationList =
        await QuranTranslationDatabaseService.fetchTranslationList(
      DatabaseService.shamelDb!,
      translationPageObjectToSave.languageCode,
      translationPageObjectToSave.pageNumber,
    );

    setCurrentTranslationPageDetails(
        translationPageObjectToSave, currentTranslationList.first,
        logAnalyticsEvent: false);
  }

  getCurrentTranslationPageDetails() {
    TranslationPageObjectToSave translationPageObjectToSave;
    String translationPageDetails =
        sharedPreferences.getString(AppStrings.savedTranslationPage) ?? '';

    if (translationPageDetails.isEmpty) {
      translationPageObjectToSave =
          TranslationPageObjectToSave(pageNumber: 1, languageCode: 'en');
    } else {
      translationPageObjectToSave =
          TranslationPageObjectToSave.fromRawJson(translationPageDetails);
    }
    return translationPageObjectToSave;
  }

  setPageToLoading() {
    emit(CurrentTranslationPageLoading());
  }

  setCurrentTranslationPageDetails(
    TranslationPageObjectToSave translationsPageObjectToSave,
    TranslationPageList currentPageAyahList, {
    bool logAnalyticsEvent = true,
  }) {
    emit(CurrentTranslationPageInitial());
    emit(
      CurrentTranslationPageState(
        pageNumber: translationsPageObjectToSave.pageNumber,
        languageCode: translationsPageObjectToSave.languageCode,
        currentTranslationPageList: currentPageAyahList,
      ),
    );

    sharedPreferences.setString(
      AppStrings.savedTranslationPage,
      translationsPageObjectToSave.toRawJson(),
    );
  }
}
