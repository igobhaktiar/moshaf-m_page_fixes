import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

showPromptToInformUserThatWeMustDownloadSomeFilesFirst(BuildContext context) {
  AppConstants.showConfirmationDialog(context,
      confirmMsg: context.translate.we_must_download_10_readings_file_first,
      acceptButtonText: context.translate.download_current_juz_now,
      withOkButton: true,
      refuseButtonText: context.translate.no_thanks,
      okCallback: () {
        Navigator.pop(context);
        // context.read<TenReadingsCubit>().downloadTenResourcesForCurrentPage();
        // return;
        var currentJuzInt = context.read<EssentialMoshafCubit>().currentJuz;
        var currentJuz = context
            .read<EssentialMoshafCubit>()
            .ajzaaListForFihris
            .where((element) => element.number == currentJuzInt)
            .toList()
            .first;
        context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
        context.read<TenReadingsCubit>().downloadFilesForPageRange(
            start: currentJuz.pageStart!, end: currentJuz.pageEnd!);
      },
      cancelCallback: () {
        context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
        Navigator.pop(context);
      },
      additionalBtns: [],
      onDialogDismissed: () async {
        context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
        log("dialog dissmissed");
        return true;
      });
}
