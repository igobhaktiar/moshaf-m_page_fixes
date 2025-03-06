import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/app_strings.dart';

part 'display_on_start_up_state.dart';

class DisplayOnStartUpCubit extends Cubit<DisplayOnStartUpState> {
  DisplayOnStartUpCubit({required this.sharedPreferences})
      : super(const DisplayOnStartUpStateUpdated(
          isPageOneSwitched: false,
          isLastPositionSwitched: true,
          isIndexSwitched: false,
          isBookmarkSwitched: false,
        ));

  final SharedPreferences sharedPreferences;
  static DisplayOnStartUpCubit get(context) => BlocProvider.of(context);
  init() {
    Map<String, dynamic> saveSwitchData = {
      'isPageOneSwitched': false,
      'isLastPositionSwitched': true,
      'isIndexSwitched': false,
      'isBookmarkSwitched': false,
    };
    try {
      saveSwitchData = jsonDecode(
        sharedPreferences.getString(AppStrings.savedMoshafStartUpSwitches) ??
            '',
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    setSwitches(
      isPageOneSwitched: saveSwitchData['isPageOneSwitched'] ?? false,
      isLastPositionSwitched: saveSwitchData['isLastPositionSwitched'] ?? false,
      isIndexSwitched: saveSwitchData['isIndexSwitched'] ?? false,
      isBookmarkSwitched: saveSwitchData['isBookmarkSwitched'] ?? false,
    );
  }

  setSwitches({
    required bool isPageOneSwitched,
    required bool isLastPositionSwitched,
    required bool isIndexSwitched,
    required bool isBookmarkSwitched,
  }) {
    emit(
      DisplayOnStartUpStateUpdated(
        isPageOneSwitched: isPageOneSwitched,
        isLastPositionSwitched: isLastPositionSwitched,
        isIndexSwitched: isIndexSwitched,
        isBookmarkSwitched: isBookmarkSwitched,
      ),
    );
    Map<String, dynamic> saveSwitchData = {
      'isPageOneSwitched': isPageOneSwitched,
      'isLastPositionSwitched': isLastPositionSwitched,
      'isIndexSwitched': isIndexSwitched,
      'isBookmarkSwitched': isBookmarkSwitched,
    };

    // Convert the dictionary to a JSON string
    String jsonString = jsonEncode(saveSwitchData);
    sharedPreferences.setString(
      AppStrings.savedMoshafStartUpSwitches,
      jsonString,
    );
  }
}
