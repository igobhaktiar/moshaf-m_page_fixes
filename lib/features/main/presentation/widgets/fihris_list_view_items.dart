import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/number_to_arabic.dart';
import '../../../essential_moshaf_feature/data/models/fihris_models.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

class SurahListViewItem extends StatelessWidget {
  final SurahFihrisModel surahFihrisModel;
  final Function(int)? onTapFihrisItem;

  const SurahListViewItem({
    Key? key,
    required this.surahFihrisModel,
    this.onTapFihrisItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (onTapFihrisItem != null) {
          onTapFihrisItem!(surahFihrisModel.page!);
        } else {
          context
              .read<EssentialMoshafCubit>()
              .navigateToPage(surahFihrisModel.page!);
        }
        Navigator.of(context).pop();

        // EssentialMoshafCubit.get(context).toggleRootView();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: context.theme.cardColor,
                      child: Text(
                        context.translate.localeName == "ar"
                            ? convertToArabicNumber(
                                surahFihrisModel.number.toString())
                            : surahFihrisModel.number.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                            fontSize: 14,
                            color: context.theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    context.translate.localeName == "ar"
                        ? surahFihrisModel.name.toString()
                        : surahFihrisModel.englishName.toString(),
                    style: context.textTheme.bodyMedium!.copyWith(
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45, left: 20),
                child: Row(
                  children: [
                    Text(
                      '${context.translate.the_page} (${surahFihrisModel.page}) - ${context.translate.its_ayat_female} (${surahFihrisModel.count}) - ${context.translate.localeName == "ar" ? surahFihrisModel.revelationTypeArabic : surahFihrisModel.revelationType}',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Text(
                      context.translate.localeName == AppStrings.arabicCode
                          ? "${EssentialMoshafCubit.get(context).ajzaaListForFihris.where((element) => element.number == surahFihrisModel.juz).toList().first.name}"
                          : "${context.translate.the_juz} ${surahFihrisModel.juz}",
                      // "${context.translate.the_juz} ${surahFihrisModel.juz}",
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class JuzListViewItem extends StatelessWidget {
  final JuzFihrisModel juzFihrisModel;
  final Function(int)? onTapFihrisItem;

  const JuzListViewItem({
    Key? key,
    required this.juzFihrisModel,
    this.onTapFihrisItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (onTapFihrisItem != null) {
          onTapFihrisItem!(juzFihrisModel.pageStart!);
        } else {
          context
              .read<EssentialMoshafCubit>()
              .navigateToPage(juzFihrisModel.pageStart!);
        }

        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: context.theme.cardColor,
                      child: Text(
                        context.translate.localeName == "ar"
                            ? convertToArabicNumber(
                                juzFihrisModel.number.toString())
                            : juzFihrisModel.number.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                            color: context.theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    context.translate.localeName == "ar"
                        ? juzFihrisModel.name.toString()
                        : "${context.translate.the_juz} ${juzFihrisModel.number}",
                    style: context.textTheme.bodyMedium!.copyWith(
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45, left: 20),
                child: Row(
                  children: [
                    Text(
                      '${context.translate.the_page} (${juzFihrisModel.pageStart}) - ${context.translate.its_ayat_male} (${juzFihrisModel.count})',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class HizbListViewItem extends StatelessWidget {
  final HizbFihrisModel hizbFihrisModel;
  final Function(int)? onTapFihrisItem;

  const HizbListViewItem({
    Key? key,
    required this.hizbFihrisModel,
    this.onTapFihrisItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (onTapFihrisItem != null) {
          onTapFihrisItem!(hizbFihrisModel.pageStart!);
        } else {
          context
              .read<EssentialMoshafCubit>()
              .navigateToPage(hizbFihrisModel.pageStart!);
        }
//go back to the main screen by poping the current screen
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: context.theme.cardColor,
                      child: Text(
                        context.translate.localeName == "ar"
                            ? convertToArabicNumber(
                                hizbFihrisModel.number.toString())
                            : hizbFihrisModel.number.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                            color: context.theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    context.translate.localeName == "ar"
                        ? hizbFihrisModel.name.toString()
                        : "${context.translate.the_hizb} ${hizbFihrisModel.number}",
                    style: context.textTheme.bodyMedium!.copyWith(
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45, left: 20),
                child: Row(
                  children: [
                    Text(
                      '${context.translate.the_page} (${hizbFihrisModel.pageStart}) - ${context.translate.its_ayat_male} (${hizbFihrisModel.count})',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Text(
                      context.translate.localeName == AppStrings.arabicCode
                          ? "${EssentialMoshafCubit.get(context).ajzaaListForFihris.where((element) => element.number == hizbFihrisModel.juz).toList().first.name}"
                          : "${context.translate.the_juz} ${hizbFihrisModel.juz}",
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
