import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/app_strings.dart';
import 'quran_details_service.dart';

part 'quran_details_state.dart';

class QuranDetailsCubit extends Cubit<QuranDetailsState> {
  QuranDetailsCubit({required this.sharedPreferences})
      : super(const AppQuranDetailsState(
          currentQuranTextColor: QuranDetailsService.defaultQuranTextColor,
          currentTextShadeInDarkValue:
              QuranDetailsService.defaultTextShadeInDarkValue,
        ));

  final SharedPreferences sharedPreferences;
  static QuranDetailsCubit get(context) => BlocProvider.of(context);

  init() {
    Color myQuranTextColor = Color(
        sharedPreferences.getInt(AppStrings.savedCurrentQuranTextColor) ??
            QuranDetailsService.defaultQuranTextColor.value);

    int myTextShadeInDarkValue =
        sharedPreferences.getInt(AppStrings.savedCurrentTextShadeInDarkValue) ??
            QuranDetailsService.defaultTextShadeInDarkValue;

    setInit(
      myQuranTextColor: myQuranTextColor,
      myTextShadeInDarkValue: myTextShadeInDarkValue,
      logAnalyticsEvent: false,
    );
    // setCurrentQuranTextColor(myQuranTextColor, logAnalyticsEvent: false);
    // setTextShadeInDarkValue(myTextShadeInDarkValue, logAnalyticsEvent: false);
  }

  setInit(
      {required Color myQuranTextColor,
      required int myTextShadeInDarkValue,
      bool logAnalyticsEvent = true}) {
    emit(
      AppQuranDetailsState(
        currentQuranTextColor: myQuranTextColor,
        currentTextShadeInDarkValue: myTextShadeInDarkValue,
      ),
    );

    sharedPreferences.setInt(
      AppStrings.savedCurrentQuranTextColor,
      myQuranTextColor.value,
    );
    sharedPreferences.setInt(
      AppStrings.savedCurrentTextShadeInDarkValue,
      myTextShadeInDarkValue,
    );
  }

  setCurrentQuranTextColor(Color myQuranTextColor,
      {required int myTextShadeInDarkValue, bool logAnalyticsEvent = true}) {
    emit(
      AppQuranDetailsState(
        currentQuranTextColor: myQuranTextColor,
        currentTextShadeInDarkValue: myTextShadeInDarkValue,
      ),
    );

    sharedPreferences.setInt(
      AppStrings.savedCurrentQuranTextColor,
      myQuranTextColor.value,
    );
  }

  setCurrentDarkShadeValue(int myTextShadeInDarkValue,
      {required Color myQuranTextColor, bool logAnalyticsEvent = true}) {
    emit(
      AppQuranDetailsState(
        currentQuranTextColor: myQuranTextColor,
        currentTextShadeInDarkValue: myTextShadeInDarkValue,
      ),
    );

    sharedPreferences.setInt(
      AppStrings.savedCurrentTextShadeInDarkValue,
      myTextShadeInDarkValue,
    );
  }
}
