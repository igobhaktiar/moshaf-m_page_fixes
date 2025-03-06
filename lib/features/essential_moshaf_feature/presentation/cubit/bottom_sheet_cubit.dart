import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/enums/moshaf_type_enum.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/screens/listen_view.dart'
    show ListenView;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/margins_view.dart'
    show MarginsView;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/notes_view.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/osoul_view.dart'
    show OsoulView;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/qeraat_view.dart'
    show QeraaatView;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/shwahid_view.dart'
    show ShwahidView;

import '../../../../config/app_config/app_config.dart';
import '../../../quran_translation/presentation/screens/translation_page_with_dropdown_language_section_display.dart';
import '../../../tafseer/presentation/screens/tafseer_page_with_dropdown_book_selection_display.dart';

part 'bottom_sheet_state.dart';

class BottomSheetCubit extends Cubit<BottomSheetState> {
  BottomSheetCubit() : super(const BottomSheetOrdinaryState(0));
  static BottomSheetCubit get(context) => BlocProvider.of(context);

  //*VALIABLES
  // Widget currentBottomSheetView = const TafseerListView();
  Widget currentBottomSheetView = AppConfig.isQeeratView()
      ? const QeraaatView()
      : const TafseerPageWithDropdownBookSelectionDisplay();

  //* LISTS
  //* These lists are for the bottom sheet which contains [التفسير،الاستماع،العلاملات المرجعية] in ordinary qeaah mode, and [الأصول،،الهوامش،القراءات،الشواهد] in ten qerraaat mode
  // List<Widget> currentBottomSheetViews = [SizedBox()];

  List<Widget> ordinaryQeraatBottomSheetViews = AppConfig.isQeeratView()
      ? [
          const QeraaatView(),
          const OsoulView(),
          const ShwahidView(),
          const MarginsView(),
        ]
      : [
          // const TafseerListView(),
          const TafseerPageWithDropdownBookSelectionDisplay(),
          const TranslationPageWithDropdownBookSelectionDisplay(),
          const ListenView(
            customBackgroundColor: Colors.white,
          ),
          const NotesView(),
          const BookmarksView(
            removeNavigation: true,
          ),
        ];
  List<Widget> tenQeraatBottomSheetViews = [
    const QeraaatView(),
    const OsoulView(),
    const ShwahidView(),
    const MarginsView(),
  ];

  //*METHODS

  changeViewsType(MoshafTypes moshafType) {
    if (moshafType == MoshafTypes.ORDINARY) {
      currentBottomSheetView = ordinaryQeraatBottomSheetViews[0];
      emit(const BottomSheetOrdinaryState(0));
    } else {
      currentBottomSheetView = tenQeraatBottomSheetViews[0];
      emit(const BottomSheetTenQeraatState(0));
    }
  }

  int getViewIndex() {
    int returnBottomIndex = 0;
    if (state is BottomSheetOrdinaryState) {
      returnBottomIndex = state.currentViewIndex;
    } else if (state is BottomSheetTenQeraatState) {
      returnBottomIndex = state.currentViewIndex;
    } else {
      returnBottomIndex = state.currentViewIndex;
    }
    return returnBottomIndex;
  }

  changeViewIndex(int newIndex) {
    if (state is BottomSheetOrdinaryState) {
      currentBottomSheetView = ordinaryQeraatBottomSheetViews[newIndex];
      emit(BottomSheetOrdinaryState(newIndex));
    } else {
      currentBottomSheetView = tenQeraatBottomSheetViews[newIndex];
      emit(BottomSheetTenQeraatState(newIndex));
    }
    log("currentBottomSheetView: ${currentBottomSheetView.toString()}");
  }
}
