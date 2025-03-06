// ayat menu
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/quran_details_cubit/quran_details_service.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../cubit/quran_details_cubit/quran_details_cubit.dart';
import '../../widgets/custom_color_picker.dart';

class QuranTextColorChangeScreen extends StatelessWidget {
  const QuranTextColorChangeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.quran_text_color),
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
                        BlocBuilder<QuranDetailsCubit, QuranDetailsState>(
                          builder: (context, quranDetailsState) {
                            return _QuranTextColorSelectionDisplay(
                              groupTitle: context.translate.quran_text_color,
                              selectedColor:
                                  quranDetailsState.currentQuranTextColor,
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

class _QuranTextColorSelectionDisplay extends StatelessWidget {
  const _QuranTextColorSelectionDisplay({
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
                      child:
                          _QuranDetailsBlocWrappedQuranTextColorSelectionDisplay(),
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
                  QuranDetailsService.setQuranTextColor(
                    context,
                    color: context.isDarkMode
                        ? QuranDetailsService.defaultQuranDarkThemeTextColor
                        : QuranDetailsService.defaultQuranTextColor,
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
                            color: context.isDarkMode
                                ? QuranDetailsService
                                    .defaultQuranDarkThemeTextColor
                                : QuranDetailsService.defaultQuranTextColor,
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
    if (context.theme.brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  void _showColorPicker(
    BuildContext context,
    Color selectedColor,
  ) {
    final List<Color> colors = [
      QuranDetailsService.getDefaultTextColorCondition(context,
          currentQuranTextColor: selectedColor),
      context.theme.brightness == Brightness.dark
          ? QuranDetailsService.defaultQuranDarkThemeTextColor
          : QuranDetailsService.defaultQuranTextColor,
      AppColors.primary,
      AppColors.activeTypeBgDark,
      Colors.brown.shade900,
      AppColors.beige,
    ];
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    QuranDetailsService.setQuranTextColor(
                      context,
                      color: colors[index],
                    );
                  },
                  children: colors.map((Color color) {
                    return Container(
                      color: color,
                      // child: Center(
                      //   child: Text(
                      //     color == const Color(0xffffffff) ? 'Default' : '',
                      //     // style: const TextStyle(color: Colors.black),
                      //     style: context.textTheme.bodyMedium,
                      //   ),
                      // ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String colorToString(Color color) {
    return color.toString().toUpperCase().split('(0XFF')[1].split(')')[0];
  }
}

class _QuranDetailsBlocWrappedQuranTextColorSelectionDisplay
    extends StatelessWidget {
  const _QuranDetailsBlocWrappedQuranTextColorSelectionDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranDetailsCubit, QuranDetailsState>(
      builder: (context, quranDetailsBlocWrappedQuranTextColorState) {
        Color quranTextColor = QuranDetailsService.defaultQuranTextColor;
        final List<Color> colors = [
          context.isDarkMode
              ? const Color(0xffffffff)
              : const Color(0xff000000),
          AppColors.primary,
          AppColors.activeTypeBgDark,
          Colors.amber.shade800
        ];
        if (quranDetailsBlocWrappedQuranTextColorState
            is AppQuranDetailsState) {
          quranTextColor =
              quranDetailsBlocWrappedQuranTextColorState.currentQuranTextColor;
          quranTextColor = QuranDetailsService.getDefaultTextColorCondition(
            context,
            currentQuranTextColor: quranTextColor,
          );
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
                        QuranDetailsService.setQuranTextColor(
                          context,
                          color: singleColor,
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
                              color: quranTextColor == singleColor
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
              moshafColor: quranTextColor,
              isSelectedFromPreviousList:
                  colors.contains(quranTextColor) ? true : false,
              onChange: (value) {
                QuranDetailsService.setQuranTextColor(
                  context,
                  color: value,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
