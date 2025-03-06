import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';

import '../../../../../core/data_sources/database_service.dart';
import '../../../data/datasources/tafseer_database_service.dart';
import '../../../data/datasources/tafseer_list.dart';
import '../../../data/models/tafseer_model.dart';
import '../../../data/models/tafseer_page_object_to_save.dart';
import '../../../data/models/tafseer_reading_model.dart';
import 'tafseer_page_cubit.dart';

class TafseerPageCubitService {
  final int defaultTafseerPageNumber = 1;
  final String tafseerCode = "ar-qo";
  final List<String> tafseerCodesToBeFetchedLocally = [];

  Future<void> initAndLoadPage(
    BuildContext context, {
    required String tafseerCode,
  }) async {
    final tafseerPageCubit = BlocProvider.of<TafseerPageCubit>(context);
    TafseerPageObjectToSave tafseerPageObjectToSave =
        tafseerPageCubit.getCurrentTafseerPageDetails();
    int pageNumber = 1;
    if (tafseerPageObjectToSave.tafseerCode == tafseerCode) {
      pageNumber = tafseerPageObjectToSave.pageNumber;
    }
    tafseerPageObjectToSave = TafseerPageObjectToSave(
      pageNumber: pageNumber,
      tafseerCode: tafseerCode,
    );
    List<TafseerPageList> currentTafseerList =
        await fetchTafseerListLocallyOrDB(tafseerPageObjectToSave);
    if (currentTafseerList.isNotEmpty) {
      tafseerPageCubit.setCurrentTafseerPageDetails(
          tafseerPageObjectToSave, currentTafseerList.first);
    }
  }

  Future<void> initAndLoadPageFromBottomBar(
    BuildContext context, {
    required int fetchPageNumber,
    String? fetchTafseerCode,
    bool isLimited = false,
  }) async {
    final tafseerPageCubit = BlocProvider.of<TafseerPageCubit>(context);
    TafseerPageObjectToSave tafseerPageObjectToSave =
        tafseerPageCubit.getCurrentTafseerPageDetails();

    tafseerPageObjectToSave = TafseerPageObjectToSave(
      pageNumber: fetchPageNumber,
      tafseerCode: fetchTafseerCode ?? tafseerPageObjectToSave.tafseerCode,
    );
    List<TafseerPageList> currentTafseerList =
        await fetchTafseerListLocallyOrDB(tafseerPageObjectToSave);
    if (currentTafseerList.isNotEmpty) {
      List<AyahWithTafseer> newTafseerList = [];
      if (isLimited) {
        bool isStartAdding = false;
        for (final ayah in currentTafseerList.first.ayahs) {
          if (ayah.ayahId == BottomWidgetService.ayahId &&
              ayah.surahIndex == BottomWidgetService.surahId) {
            isStartAdding = true;
          }
          if (isStartAdding) {
            newTafseerList.add(ayah);
          }
        }
        currentTafseerList.first.ayahs = newTafseerList;
      }
      tafseerPageCubit.setCurrentTafseerPageDetails(
          tafseerPageObjectToSave, currentTafseerList.first);
    }
  }

  Future<List<TafseerPageList>> fetchTafseerListLocallyOrDB(
    TafseerPageObjectToSave tafseerPageObjectToSave,
  ) async {
    List<TafseerPageList> currentTafseerList = [];
    if (tafseerCodesToBeFetchedLocally
        .contains(tafseerPageObjectToSave.tafseerCode)) {
      List<AyahTafseerModel> allQuranTafseer =
          tafseerList.map((e) => AyahTafseerModel.fromJson(e)).toList();
      List<AyahTafseerModel> tafseersInCurrentPage = allQuranTafseer
          .where(
              (element) => element.page == tafseerPageObjectToSave.pageNumber)
          .toList();
      currentTafseerList.add(
        TafseerPageList(
          pageIndex: tafseerPageObjectToSave.pageNumber,
          ayahs: tafseersInCurrentPage
              .map(
                (tafseer) => AyahWithTafseer(
                  ayahId: tafseer.numberInSurah!,
                  verseUthmani: tafseer.text!,
                  surahIndex: tafseer.surahNumber!,
                  surahName: tafseer.surah!,
                  tafseerText: tafseer.tafseer!,
                ),
              )
              .toList(),
        ),
      );
    } else {
      currentTafseerList = await TafseerDatabaseService.fetchTafseerList(
        DatabaseService.shamelDb!,
        tafseerPageObjectToSave.tafseerCode,
        tafseerPageObjectToSave.pageNumber,
      );
    }
    return currentTafseerList;
  }

  Future<void> updatePageNumber(
    BuildContext context, {
    required int newPageNumber,
    required String tafseerCode,
  }) async {
    final tafseerPageCubit = BlocProvider.of<TafseerPageCubit>(context);
    TafseerPageObjectToSave tafseerPageObjectToSave = TafseerPageObjectToSave(
      pageNumber: newPageNumber,
      tafseerCode: tafseerCode,
    );

    List<TafseerPageList> currentTafseerList =
        await fetchTafseerListLocallyOrDB(tafseerPageObjectToSave);

    if (currentTafseerList.isNotEmpty) {
      tafseerPageCubit.setCurrentTafseerPageDetails(
          tafseerPageObjectToSave, currentTafseerList.first);
    }
  }

  String? getCurrentTafseerBook(
    BuildContext context,
  ) {
    List<TafseerReadingModel> tafseerBookList =
        TafseerReadingService().getTafseerList();
    TafseerReadingModel? bookToReturn;
    final tafseerPageCubitState =
        BlocProvider.of<TafseerPageCubit>(context).state;
    if (tafseerPageCubitState is CurrentTafseerPageState) {
      for (final TafseerReadingModel currentBook in tafseerBookList) {
        if (currentBook.tafseerCode == tafseerPageCubitState.tafseerCode) {
          bookToReturn = currentBook;
        }
      }
    }
    return (bookToReturn != null) ? bookToReturn.tafseerCode : null;
  }

  List<AyahWithTafseer> getCurrentFetchedTafseers() {
    List<AyahWithTafseer> tafseerList = [];
    BuildContext? context = AppContext.getAppContext();
    if (context != null) {
      final TafseerPageState tafseerPageCubitState =
          BlocProvider.of<TafseerPageCubit>(context).state;
      if (tafseerPageCubitState is CurrentTafseerPageState) {
        tafseerList = tafseerPageCubitState.currentTafseerPageList.ayahs;
      }
    }
    return tafseerList;
  }
}
