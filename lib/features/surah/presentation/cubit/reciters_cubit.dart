import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/surah/data/datasources/soorah_reciters.dart';
import 'package:qeraat_moshaf_kwait/features/surah/data/models/reciter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reciters_state.dart';

class RecitersCubit extends Cubit<RecitersState> {
  RecitersCubit({required this.sharedPreferences}) : super(RecitersInitial());

  static RecitersCubit get(context) => BlocProvider.of(context);
  List<ReciterModel> recitersList = availableReciters
      .map((reciter) => ReciterModel.fromJson(reciter))
      .toList();
  // ReciterModel? currentReciter;
  String? appDirectory;
  late File logFile;
  final SharedPreferences sharedPreferences;
  late String currentReciterFolderPath;
  bool enablePlayInBackground = true;

  //* Methods

  void selectReciter(ReciterModel reciter) {
    if (reciter.allowedReciters != '') {
      emit(ChangeCurrentReciterState(reciter));
    } else {
      emit(const RecitersAvailability(msg: 'Reciter will be available soon'));
    }
  }

  void resetState() {
    emit(RecitersInitial());
  }
}
