import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'lang_state.dart';

class LangCubit extends Cubit<LangState> {
  LangCubit({required this.sharedPreferences})
      : super(const LangChanged(Locale(AppStrings.arabicCode)));
  static LangCubit get(context) => BlocProvider.of(context);

  final SharedPreferences sharedPreferences;

  Locale currentLocale = const Locale(AppStrings.arabicCode);

  void init() {
    currentLocale = Locale(
        sharedPreferences.getString(AppStrings.savedLocale) ??
            AppStrings.arabicCode,
        "us");
    log("currentLocale: ${sharedPreferences.getString(AppStrings.savedLocale)}");

    emit(LangChanged(currentLocale));
  }

  void changeLocale(String langCode, [String countryCode = "us"]) {
    currentLocale = Locale(langCode, countryCode);
    sharedPreferences.setString(AppStrings.savedLocale, langCode);

    emit(LangChanged(currentLocale));
  }
}
