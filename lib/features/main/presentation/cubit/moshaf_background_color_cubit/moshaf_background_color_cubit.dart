import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/app_strings.dart';

part 'moshaf_background_color_state.dart';

class MoshafBackgroundColorCubit extends Cubit<MoshafBackgroundColorState> {
  MoshafBackgroundColorCubit({required this.sharedPreferences})
      : super(const AppMoshafBackgroundColorState(
          currentColor: Color(0xffffffff),
        ));

  final SharedPreferences sharedPreferences;
  static MoshafBackgroundColorCubit get(context) => BlocProvider.of(context);

  init() {
    Color myBackgroundColor = Color(
        sharedPreferences.getInt(AppStrings.savedMoshafBackgroundColor) ??
            const Color(0xffffffff).value);

    setCurrentBgColor(myBackgroundColor, logAnalyticsEvent: false);
  }

  setCurrentBgColor(Color selectedColor, {bool logAnalyticsEvent = true}) {
    emit(
      AppMoshafBackgroundColorState(
        currentColor: selectedColor,
      ),
    );

    sharedPreferences.setInt(
      AppStrings.savedMoshafBackgroundColor,
      selectedColor.value,
    );
  }
}
