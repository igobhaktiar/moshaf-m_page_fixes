import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/app_strings.dart';

part 'reciter_image_state.dart';

class ReciterImageCubit extends Cubit<ReciterImageState> {
  ReciterImageCubit({required this.sharedPreferences})
      : super(const ReciterImageControlState(
          showReciterImages: true,
        ));

  final SharedPreferences sharedPreferences;
  static ReciterImageCubit get(context) => BlocProvider.of(context);

  init() {
    bool showReciterImageSelection =
        sharedPreferences.getBool(AppStrings.savedShowReciterImageSelection) ??
            true;

    setShowReciterImageSelection(showReciterImageSelection,
        logAnalyticsEvent: false);
  }

  setShowReciterImageSelection(bool showReciterImageSelection,
      {bool logAnalyticsEvent = true}) {
    emit(
      ReciterImageControlState(
        showReciterImages: showReciterImageSelection,
      ),
    );

    sharedPreferences.setBool(
        AppStrings.savedShowReciterImageSelection, showReciterImageSelection);
  }
}
