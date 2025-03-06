import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/utils/language_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/tafseer_font_size_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/data/models/translation_page_list_model.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/presentation/cubit/translation_page/translation_page_cubit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import '../../../main/presentation/widgets/fihris_dialog.dart';
import '../cubit/translation_page/translation_page_cubit_service.dart';
import '../widgets/bottom_model_dropdown_translation_widget.dart';

class TranslationPageScreen extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final bool removeNavigation;
  const TranslationPageScreen({
    super.key,
    this.languageCode = '',
    this.languageName = '',
    this.removeNavigation = false,
  });

  @override
  State<TranslationPageScreen> createState() => _TranslationPageScreenState();
}

class _TranslationPageScreenState extends State<TranslationPageScreen> {
  int getUpdatedPageNumber(
      {required int currentPageNumber, bool isPositive = true}) {
    int pageToReturn = currentPageNumber;
    if (isPositive) {
      if (pageToReturn >= 1 && pageToReturn < 604) {
        pageToReturn = pageToReturn + 1;
      }
    } else {
      if (pageToReturn > 1 && pageToReturn <= 604) {
        pageToReturn = pageToReturn - 1;
      }
    }
    return pageToReturn;
  }

  String _getCurrentFontSizeOption(BuildContext context) {
    final state = context.watch<FontSizeCubit>().state;

    if (state.ayahFontSize == 20.0 && state.tafseerFontSize == 12.0) {
      return 'Small';
    } else if (state.ayahFontSize == 26.0 && state.tafseerFontSize == 14.0) {
      return 'Medium';
    } else if (state.ayahFontSize == 32.0 && state.tafseerFontSize == 16.0) {
      return 'Large';
    }
    return 'Medium'; // Default option
  }

  Color getTextThemedModeColor(
    BuildContext context, {
    Color lightModeColor = Colors.black,
  }) {
    return context.isDarkMode ? Colors.white : lightModeColor;
  }

  @override
  void initState() {
    super.initState();
    if (widget.removeNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BottomWidgetService.scrollToTappedPositionBottom();
      });
    }
  }

  @override
  void dispose() {
    BottomWidgetService.currentTranslationItems = [];

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TranslationPageCubitService translationPageCubitService =
        TranslationPageCubitService();
    LanguageService.isLanguageRtl(context);

    return Scaffold(
      appBar: (!widget.removeNavigation)
          ? AppBar(
              title: Text(
                widget.languageName,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    showFihrisDialog(
                      context,
                      (int pageNumber) {
                        translationPageCubitService.updatePageNumber(
                          context,
                          newPageNumber: pageNumber,
                          languageCode: widget.languageCode,
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Icon(
                      Icons.list_sharp,
                      size: 35,
                      color: context.isDarkMode ? Colors.white : null,
                    ),
                  ),
                ),
              ],
              leading: AppConstants.customBackButton(context, onPressed: () {
                Navigator.of(context).pop();
              }),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    image: context.isDarkMode
                        ? null
                        : const DecorationImage(
                            image: AssetImage(AppAssets.pattern),
                            fit: BoxFit.cover)),
              ),
            )
          : null,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: BlocBuilder<TranslationPageCubit, TranslationPageState>(
            builder: (context, translationPageState) {
              if (translationPageState is CurrentTranslationPageState) {
                var translatedAyahs = removeDuplicateAyahsKeepLast(
                    translationPageState.currentTranslationPageList.ayahs);
                BottomWidgetService.currentTranslationItems = translatedAyahs;
                return BlocBuilder<FontSizeCubit, FontSizeState>(
                  builder: (context, fontSizeState) {
                    return Column(
                      children: [
                        if (!widget.removeNavigation)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.only(
                                    top: 5,
                                    left: 15,
                                    right: 2,
                                  ),
                                  // Adjust padding as needed
                                  color: AppColors.lightGrey,
                                  child: DropdownButton<String>(
                                      icon: Icon(
                                        Icons.arrow_drop_down_sharp,
                                        size: 20,
                                        color: context.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      underline: const SizedBox.shrink(),
                                      value: _getCurrentFontSizeOption(context),
                                      onChanged: (value) {
                                        if (value != null) {
                                          context
                                              .read<FontSizeCubit>()
                                              .changeFontSize(value);
                                        }
                                      },
                                      items: getFontDropDownItems(context)),
                                ),
                                Container(
                                  color: AppColors.lightGrey,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          translationPageCubitService
                                              .updatePageNumber(
                                            context,
                                            newPageNumber: getUpdatedPageNumber(
                                              currentPageNumber:
                                                  translationPageState
                                                      .pageNumber,
                                            ),
                                            languageCode: widget.languageCode,
                                          );
                                        },
                                        child: const SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        translationPageState.pageNumber
                                            .toString(),
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          translationPageCubitService
                                              .updatePageNumber(
                                            context,
                                            newPageNumber: getUpdatedPageNumber(
                                              currentPageNumber:
                                                  translationPageState
                                                      .pageNumber,
                                              isPositive: false,
                                            ),
                                            languageCode: widget.languageCode,
                                          );
                                        },
                                        child: const SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  left: 15,
                                  right: 2,
                                ),
                                // Adjust padding as needed
                                decoration: BoxDecoration(
                                  color: context.isDarkMode
                                      ? AppColors.tabBackgroundDark
                                      : AppColors.tabBackground,
                                  borderRadius:
                                      BorderRadius.circular(8), // Border radius
                                ),
                                child: DropdownButton<String>(
                                    icon: Icon(
                                      Icons.arrow_drop_down_sharp,
                                      size: 50,
                                      color: context.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    underline: const SizedBox.shrink(),
                                    value: _getCurrentFontSizeOption(context),
                                    onChanged: (value) {
                                      if (value != null) {
                                        context
                                            .read<FontSizeCubit>()
                                            .changeFontSize(value);
                                      }
                                    },
                                    items: getFontDropDownItems(context)),
                              ),
                              Expanded(
                                child: BottomModelDropdownTranslationWidget(
                                  currentLanguageCode:
                                      translationPageState.languageCode,
                                ),
                              ),
                            ],
                          ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: ScrollablePositionedList.builder(
                              itemScrollController: BottomWidgetService
                                  .bottomWidgetScrollControllerTranslation,
                              itemCount: translatedAyahs.length,
                              itemBuilder: (context, index) {
                                AyahWithTranslation currentAyah =
                                    translatedAyahs[index];
                                return Column(
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10.0,
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 15),
                                            if (currentAyah.ayahId == 1)
                                              //Bismillah
                                              Image.asset(
                                                '$surahFramesAssetsPath/${currentAyah.surahIndex.toString().padLeft(3, '0')}.png',
                                                color: context.isDarkMode
                                                    ? Colors.white
                                                    : null,
                                              ),
                                            const SizedBox(height: 15),
                                            Align(
                                              alignment: AlignmentDirectional
                                                  .centerEnd,
                                              child: Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: Text(
                                                  currentAyah.verseUthmani,
                                                  textAlign: TextAlign.start,
                                                  style: context
                                                      .textTheme.bodyMedium!
                                                      .copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.7,
                                                    fontSize: fontSizeState
                                                        .ayahFontSize,
                                                    fontFamily: AppStrings
                                                        .qeeratKuwaitFontFamily,
                                                    color:
                                                        getTextThemedModeColor(
                                                      context,
                                                      lightModeColor: AppColors
                                                          .tafseerTextColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                              alignment: LanguageService
                                                      .isCodeLanguageRtl(
                                                          translationPageState
                                                              .languageCode)
                                                  ? AlignmentDirectional
                                                      .centerEnd
                                                  : AlignmentDirectional
                                                      .centerStart,
                                              child: Directionality(
                                                textDirection: LanguageService
                                                        .isCodeLanguageRtl(
                                                            translationPageState
                                                                .languageCode)
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr,
                                                child: Text(
                                                  currentAyah.translatedText,
                                                  style: context
                                                      .textTheme.bodySmall!
                                                      .copyWith(
                                                    fontSize: fontSizeState
                                                        .tafseerFontSize,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: LanguageService
                                                            .isUrduOrPersian(
                                                                translationPageState
                                                                    .languageCode)
                                                        ? AppStrings.urduNoto
                                                        : null,
                                                    color:
                                                        getTextThemedModeColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (currentAyah.ayahId != 1)
                                      Divider(
                                        height: 40,
                                        thickness: 0.7,
                                        color: getTextThemedModeColor(
                                          context,
                                          lightModeColor:
                                              AppColors.tafseerTextColor,
                                        ),
                                      )
                                    else
                                      const SizedBox(),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
