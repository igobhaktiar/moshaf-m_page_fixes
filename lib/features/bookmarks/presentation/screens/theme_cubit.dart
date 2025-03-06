import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/quran_details_cubit/quran_details_service.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../navigation_service.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required this.sharedPreferences})
      : super(const AppThemeState(brightness: Brightness.light));
  static ThemeCubit get(context) => BlocProvider.of(context);

  final SharedPreferences sharedPreferences;
  int currentThemeId = 1;
  init() {
    int savedIndex = sharedPreferences.getInt(AppStrings.savedTheme) ?? 1;
    setCurrentTheme(savedIndex, initial: true, logAnalyticsEvent: false);
  }

  setCurrentTheme(int index,
      {bool initial = false, bool logAnalyticsEvent = true}) {
    currentThemeId = index;
    if (index == 0) {
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      emit(AppThemeState(
          brightness: !isDarkMode ? Brightness.light : Brightness.dark,
          pageBgcolor: !isDarkMode ? Colors.white : const Color(0xFFF5EFDF)));
    } else {
      emit(AppThemeState(
          brightness:
              [1, 3, 4].contains(index) ? Brightness.light : Brightness.dark,
          pageBgcolor:
              [1, 3].contains(index) ? Colors.white : const Color(0xFFF5EFDF)));
    }
    sharedPreferences.setInt(AppStrings.savedTheme, index);

    if (!initial) {
      BuildContext context = getItInstance<NavigationService>().getContext()!;
      Future.delayed(const Duration(seconds: 2), () {
        int pageIndex = AyahRenderBlocHelper.getPageIndex(context);
        QuranDetailsService.resetQuranTextColor(context);
        AyahRenderBlocHelper.pageChangeInitialize(
          context,
          pageIndex,
          resetQuranTextColor: true,
        );

        bool bottomWidgetOpened =
            context.read<BottomWidgetCubit>().getBottomWidgetState(context);
        if (bottomWidgetOpened) {
          context.read<EssentialMoshafCubit>().hideFlyingLayers();
          context.read<BottomWidgetCubit>().setBottomWidgetState(
                false,
                withoutAffectingSafeArea: true,
              );
          // context.read<BottomWidgetCubit>().setBottomWidgetState(true);
        }
      });
    }
  }
}
