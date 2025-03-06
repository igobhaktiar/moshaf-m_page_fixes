// ayat menu
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/widgets/custom_switch_list_tile.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/show_juz_popup/show_juz_popup_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class ShowJuzPopupScreen extends StatelessWidget {
  const ShowJuzPopupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.showJuzPopup),
          leading: AppConstants.customBackButton(context),
          actions: [
            AppConstants.customHomeButton(context, doublePop: true),
          ],
        ),
        body: Column(
          children: [
            Card(
                margin: const EdgeInsets.all(8),
                clipBehavior: Clip.antiAlias,
                color: context.theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  side: BorderSide(
                      color: AppColors.border,
                      width: context.theme.brightness == Brightness.dark
                          ? 0.0
                          : 1.5),
                ),
                child: BlocBuilder<JuzPopupCubit, JuzPopupState>(
                  builder: (context, state) {
                    if (state is JuzPopupEnabled) {
                      return CustomSwitchListTile(
                        title: context.translate
                            .showJuzPopup, // Assuming you have translations
                        enabled: true,
                        value: state.showPopup,
                        onChanged: (value) {
                          context.read<JuzPopupCubit>().toggleJuzPopup(value);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )),
          ],
        ));
  }
}
