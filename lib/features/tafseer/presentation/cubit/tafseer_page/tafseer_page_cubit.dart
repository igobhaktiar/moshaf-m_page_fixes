import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/data_sources/database_service.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../data/datasources/tafseer_database_service.dart';
import '../../../data/models/tafseer_page_object_to_save.dart';
import '../../../data/models/tafseer_reading_model.dart';

part 'tafseer_page_state.dart';

class TafseerPageCubit extends Cubit<TafseerPageState> {
  TafseerPageCubit({required this.sharedPreferences})
      : super(CurrentTafseerPageState(
          pageNumber: 1,
          tafseerCode: 'ar-qo',
          currentTafseerPageList: TafseerPageList(ayahs: [], pageIndex: 1),
        ));
  static TafseerPageCubit get(context) => BlocProvider.of(context);
  final SharedPreferences sharedPreferences;
  init() async {
    String savedTafseerPageDetails =
        sharedPreferences.getString(AppStrings.savedTafseerPage) ?? '';

    TafseerPageObjectToSave tafseerPageObjectToSave;
    if (savedTafseerPageDetails.isEmpty) {
      tafseerPageObjectToSave = TafseerPageObjectToSave(
        pageNumber: 1,
        tafseerCode: 'ar-qo',
      );
    } else {
      tafseerPageObjectToSave =
          TafseerPageObjectToSave.fromRawJson(savedTafseerPageDetails);
    }

    List<TafseerPageList> currentTafseerList =
        await TafseerDatabaseService.fetchTafseerList(
      DatabaseService.shamelDb!,
      tafseerPageObjectToSave.tafseerCode,
      tafseerPageObjectToSave.pageNumber,
    );

    setCurrentTafseerPageDetails(
        tafseerPageObjectToSave, currentTafseerList.first,
        logAnalyticsEvent: false);
  }

  getCurrentTafseerPageDetails() {
    String tafseerPageDetails =
        sharedPreferences.getString(AppStrings.savedTafseerPage) ?? '';

    TafseerPageObjectToSave tafseerPageObjectToSave;
    if (tafseerPageDetails.isEmpty) {
      tafseerPageObjectToSave = TafseerPageObjectToSave(
        pageNumber: 1,
        tafseerCode: 'ar-qo',
      );
    } else {
      tafseerPageObjectToSave =
          TafseerPageObjectToSave.fromRawJson(tafseerPageDetails);
    }

    return tafseerPageObjectToSave;
  }

  setCurrentTafseerPageDetails(
    TafseerPageObjectToSave tafseerPageObjectToSave,
    TafseerPageList currentPageAyahList, {
    bool logAnalyticsEvent = true,
  }) {
    emit(CurrentTafseerPageLoading());
    emit(
      CurrentTafseerPageState(
        pageNumber: tafseerPageObjectToSave.pageNumber,
        tafseerCode: tafseerPageObjectToSave.tafseerCode,
        currentTafseerPageList: currentPageAyahList,
      ),
    );

    sharedPreferences.setString(
      AppStrings.savedTafseerPage,
      tafseerPageObjectToSave.toRawJson(),
    );
  }
}
