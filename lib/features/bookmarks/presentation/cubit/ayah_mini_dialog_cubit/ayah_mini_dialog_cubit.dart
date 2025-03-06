import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';

import '../../../../ayatHighlight/data/models/ahyah_segs_model.dart';

part 'ayah_mini_dialog_state.dart';

class AyahMiniDialogCubit extends Cubit<AyahMiniDialogState> {
  AyahMiniDialogCubit() : super(AyahMiniDialogInitial());
  static AyahMiniDialogCubit get(context) => BlocProvider.of(context);

  void openMiniDialog(
      AyahModel ayah, AyahSegsModel? highlight, Offset? scrollOffset) {
    emit(
      AyahMiniDialogInitial(),
    );
    emit(
      AyahMiniDialogOpened(
        ayah: ayah,
        highlight: highlight,
        scrollOffset: scrollOffset,
      ),
    );
  }

  void closeMiniDialog() {
    emit(
      AyahMiniDialogInitial(),
    );
  }
}
