import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/moshaf_background_color_cubit/moshaf_background_color_cubit.dart';

class MoshafBackgroundColorService {
  MoshafBackgroundColorService._();

  static void setMoshafBackgroundColor(
    BuildContext context, {
    required Color backgroundColor,
  }) {
    context.read<MoshafBackgroundColorCubit>().setCurrentBgColor(
          backgroundColor,
        );
  }
}
