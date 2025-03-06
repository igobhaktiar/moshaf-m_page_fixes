// ayat menu
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/moshaf_background_color_cubit/moshaf_background_color_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/moshaf_background_color_cubit/moshaf_background_color_service.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/widgets/custom_color_picker.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';

class MoshafBackgroundControlScreen extends StatelessWidget {
  const MoshafBackgroundControlScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.moshaf_background_color),
          leading: AppConstants.customBackButton(context),
          actions: [
            AppConstants.customHomeButton(context, doublePop: true),
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0.0, 16, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        BlocBuilder<MoshafBackgroundColorCubit,
                            MoshafBackgroundColorState>(
                          builder: (context, moshafBackgroundColorState) {
                            return _MoshafBackgroundColorSelectionDisplay(
                              groupTitle:
                                  context.translate.moshaf_background_color,
                              selectedColor:
                                  moshafBackgroundColorState.currentColor,
                            );
                          },
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ),
                ),
              )
            ]));
  }
}

class _MoshafBackgroundColorSelectionDisplay extends StatelessWidget {
  const _MoshafBackgroundColorSelectionDisplay({
    required this.groupTitle,
    required this.selectedColor,
    Key? key,
  }) : super(key: key);
  final String groupTitle;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            groupTitle,
            style: context.textTheme.displayMedium,
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          color: context.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
                color: AppColors.border,
                width: context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: _MoshafBlocWrappedColorContainer(),
                    ),
                    // const SizedBox(
                    //   width: 8,
                    // ),
                    // Text(
                    //   groupTitle,
                    //   style: context.textTheme.bodyMedium,
                    // ),
                    // const Spacer(),
                    // Icon(
                    //   Icons.arrow_forward_ios,
                    //   color: context.theme.primaryIconTheme.color,
                    //   size: 16,
                    // ),
                    SizedBox(
                      width: 12,
                    ),
                  ],
                ),
              ),
              AppConstants.appDivider(
                context,
                indent: 40,
              ),
              InkWell(
                onTap: () {
                  MoshafBackgroundColorService.setMoshafBackgroundColor(
                    context,
                    backgroundColor: context.isDarkMode
                        ? Colors.black
                        : const Color(0xffffffff),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      ClipOval(
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: (context.isDarkMode)
                                ? Colors.black
                                : const Color(0xffffffff),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          context.translate.reset_to_default,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.restart_alt_rounded,
                        color: _getResetIconColor(context),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color? _getResetIconColor(BuildContext context) {
    if (context.isDarkMode) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  String colorToString(Color color) {
    return color.toString().toUpperCase().split('(0XFF')[1].split(')')[0];
  }
}

class _MoshafBlocWrappedColorContainer extends StatelessWidget {
  const _MoshafBlocWrappedColorContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoshafBackgroundColorCubit, MoshafBackgroundColorState>(
      builder: (context, moshafBlocWrappedColorState) {
        Color moshafColor = AppColors.primary;
        final List<Color> colors = [
          context.isDarkMode
              ? const Color(0xff000000)
              : const Color(0xffffffff),
          AppColors.primary,
          AppColors.activeTypeBgDark,
          Colors.amber.shade800
        ];
        if (moshafBlocWrappedColorState is AppMoshafBackgroundColorState) {
          moshafColor = moshafBlocWrappedColorState.currentColor;
        }
        return Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: colors.map(
                  (singleColor) {
                    return InkWell(
                      onTap: () {
                        MoshafBackgroundColorService.setMoshafBackgroundColor(
                          context,
                          backgroundColor: singleColor,
                        );
                      },
                      child: ClipOval(
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: singleColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: moshafColor == singleColor
                                  ? Colors.red
                                  : context.theme.cardColor, // Red border
                              width: 2.0, // Thickness of the border
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            CustomerColorPicker(
              moshafColor: moshafColor,
              isSelectedFromPreviousList:
                  colors.contains(moshafColor) ? true : false,
              onChange: (value) {
                MoshafBackgroundColorService.setMoshafBackgroundColor(
                  context,
                  backgroundColor: value,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
