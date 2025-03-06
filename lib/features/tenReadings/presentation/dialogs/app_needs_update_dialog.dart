import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/constants.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

showAppNeedsUpdateDialog(BuildContext context) async {
  AppConstants.showConfirmationDialog(context,
      confirmMsg: context.translate.please_update_app_to_get_new_features,
      acceptButtonText: context.translate.update,
      withOkButton: true,
      refuseButtonText: context.translate.later, okCallback: () async {
    Navigator.pop(context);
    // if (await canLaunchUrl(Uri.parse(EndPoints.appLandingPage))) {
  }, cancelCallback: () {
    context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
    context.read<TenReadingsCubit>().resetIsNeedUpdateDialogShown();
    Navigator.pop(context);
  }, onDialogDismissed: () async {
    context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
    context.read<TenReadingsCubit>().resetIsNeedUpdateDialogShown();

    return true;
  });
}
