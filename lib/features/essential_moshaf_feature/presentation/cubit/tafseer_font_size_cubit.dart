import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeState {
  final double ayahFontSize;
  final double tafseerFontSize;

  FontSizeState({
    required this.ayahFontSize,
    required this.tafseerFontSize,
  });
}

class FontSizeCubit extends Cubit<FontSizeState> {
  final SharedPreferences sharedPreferences;

  FontSizeCubit({required this.sharedPreferences})
      : super(FontSizeState(ayahFontSize: 26.0, tafseerFontSize: 14.0));

  void init() {
    // Load font sizes from shared preferences or use defaults
    double savedAyahFontSize =
        sharedPreferences.getDouble('ayahFontSize') ?? 26.0;
    double savedTafseerFontSize =
        sharedPreferences.getDouble('tafseerFontSize') ?? 14.0;

    emit(FontSizeState(
      ayahFontSize: savedAyahFontSize,
      tafseerFontSize: savedTafseerFontSize,
    ));
  }

  void changeFontSize(String sizeOption) {
    // Define font sizes for each option
    double ayahFontSize = 26.0;
    double tafseerFontSize = 14.0;

    if (sizeOption == 'Small') {
      ayahFontSize = 20.0;
      tafseerFontSize = 12.0;
    } else if (sizeOption == 'Medium') {
      ayahFontSize = 26.0;
      tafseerFontSize = 14.0;
    } else if (sizeOption == 'Large') {
      ayahFontSize = 32.0;
      tafseerFontSize = 16.0;
    }

    // Save the selected font sizes to shared preferences
    sharedPreferences.setDouble('ayahFontSize', ayahFontSize);
    sharedPreferences.setDouble('tafseerFontSize', tafseerFontSize);

    // Emit the new state
    emit(FontSizeState(
      ayahFontSize: ayahFontSize,
      tafseerFontSize: tafseerFontSize,
    ));
  }
}

List<DropdownMenuItem<String>> getFontDropDownItems(BuildContext context) {
  List<DropdownMenuItem<String>> dropitems = [
    DropdownMenuItem(
      value: 'Small',
      child: Row(
        children: [
          const Icon(Icons.text_fields, size: 18), // Font icon prefix
          const SizedBox(width: 10), // Spacing between icon and text
          Text(context.translate.small), // Arabic for "Small"
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'Medium',
      child: Row(
        children: [
          const Icon(Icons.text_fields, size: 22), // Font icon prefix
          const SizedBox(width: 10),
          Text(context.translate.medium), // Arabic for "Medium"
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'Large',
      child: Row(
        children: [
          const Icon(Icons.text_fields, size: 26), // Font icon prefix
          const SizedBox(width: 10),
          Text(context.translate.large), // Arabic for "Large"
        ],
      ),
    ),
  ];
  return dropitems;
}
