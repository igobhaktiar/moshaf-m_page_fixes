import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart';

import '../../../../../core/utils/app_context.dart';
import '../essential_moshaf_cubit.dart';
import 'bottom_widget_service.dart';

part 'bottom_widget_state.dart';

class BottomWidgetCubit extends Cubit<BottomWidgetState> {
  BottomWidgetCubit()
      : super(const BottomWidgetOpenState(
          isOpened: false,
        ));

  static BottomWidgetCubit get(context) => BlocProvider.of(context);

  bool getBottomWidgetState(BuildContext currentContext) {
    bool isOpened = false;

    final BottomWidgetState bottomWidgetState =
        BottomWidgetCubit.get(currentContext).state;
    if (bottomWidgetState is BottomWidgetOpenState) {
      isOpened = bottomWidgetState.isOpened;
    }
    return isOpened;
  }

  void reloadBottomWidgetState(
    BuildContext appContext, {
    bool scrollDownTopPage = true,
    int customIndex = 0,
    Offset? scrollOffset,
    int surahId = -1,
    int ayahId = -1,
  }) {
    BottomWidgetService.updateAyahAndSurahId(
        toUpdateSurahId: surahId, toUpdateAyahId: ayahId);
    final isOpened =
        BottomWidgetCubit.get(appContext).getBottomWidgetState(appContext);

    if (isOpened) {
      appContext.read<BottomWidgetCubit>().setBottomWidgetState(
        scrollDownTopPage: false,
        false,
        resetAyahAndSurahStatus: false,
        afterExecutionFunction: () {
          appContext.read<BottomWidgetCubit>().setBottomWidgetState(
                true,
                scrollDownTopPage: true,
                customIndex: customIndex,
                scrollOffset: scrollOffset,
              );
        },
      );
    } else {
      appContext.read<BottomWidgetCubit>().setBottomWidgetState(
            true,
            scrollDownTopPage: true,
            customIndex: customIndex,
            scrollOffset: scrollOffset,
          );
    }
  }

  setBottomWidgetState(
    bool isOpened, {
    int customIndex = 0,
    bool withoutAffectingSafeArea = false,
    bool scrollDownTopPage = true,
    VoidCallback? afterExecutionFunction,
    bool logAnalyticsEvent = true,
    bool resetBottomView = false,
    bool resetAyahAndSurahStatus = true,
    Offset? scrollOffset,
  }) {
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      if (!isOpened && resetBottomView) {
        appContext.read<BottomSheetCubit>().changeViewIndex(0);
      }
      if (scrollDownTopPage) {
        bool isAlreadyOpened = getBottomWidgetState(appContext);
        if (!isAlreadyOpened && scrollOffset != null) {
          if (!appContext.isLandscape) {
            BottomWidgetService.scrollToTappedPosition(scrollOffset);
            // Todo: Open this for bottom scrolling
            BottomWidgetService.scrollToTappedPositionBottom();
          }
        }
      }
      if (isOpened) {
        EssentialMoshafCubit.get(appContext)
            .showBottomNavigateByPageLayer(false);
        if (!withoutAffectingSafeArea) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: SystemUiOverlay.values);
        }
        Future.delayed(Durations.extralong1, () {
          BottomSheetCubit.get(appContext).changeViewIndex(customIndex);
        });
      } else {
        if (resetAyahAndSurahStatus) {
          BottomWidgetService.sheetClosed();
        }
        if (!withoutAffectingSafeArea) {
          // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        }
      }
    }

    emit(
      BottomWidgetLoading(),
    );
    emit(
      BottomWidgetOpenState(
        isOpened: isOpened,
      ),
    );
    if (afterExecutionFunction != null) {
      afterExecutionFunction();
    }
  }
}
