import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/reciter_image_cubit/reciter_image_cubit.dart';

class ReciterControlsService {
  ReciterControlsService._();

  static void setReciterImagesToShow(
    BuildContext context, {
    required bool showReciterImages,
  }) {
    context.read<ReciterImageCubit>().setShowReciterImageSelection(
          showReciterImages,
        );
  }
}
