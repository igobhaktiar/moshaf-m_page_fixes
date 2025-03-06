import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/tafseer_font_size_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/tafseer/presentation/cubit/tafseer_page/tafseer_page_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/tafseer/presentation/cubit/tafseer_page/tafseer_page_cubit_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../main/presentation/widgets/fihris_dialog.dart';
import '../../data/models/tafseer_reading_model.dart';
import '../widgets/bottom_model_dropdown_tafseer_widget.dart';

class TafseerPageScreen extends StatefulWidget {
  final String tafseerCode;
  final String tafseerBookName;
  final bool removeNavigation;
  const TafseerPageScreen({
    super.key,
    this.tafseerCode = '',
    this.tafseerBookName = '',
    this.removeNavigation = false,
  });

  @override
  State<TafseerPageScreen> createState() => _TafseerPageScreenState();
}

class _TafseerPageScreenState extends State<TafseerPageScreen> {
  TafseerPageCubitService tafseerPageCubitService = TafseerPageCubitService();

  bool onlyShowQuran = false;
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

  Color getTextThemedModeColor(
    BuildContext context, {
    Color lightModeColor = Colors.black,
  }) {
    return context.isDarkMode ? Colors.white : lightModeColor;
  }

  @override
  void initState() {
    super.initState();
    final TafseerPageState tafseerPageState =
        BlocProvider.of<TafseerPageCubit>(context).state;
    if (TafseerPageCubitService()
            .tafseerCodesToBeFetchedLocally
            .contains(widget.tafseerCode) &&
        (tafseerPageState is CurrentTafseerPageState)) {
      tafseerPageCubitService.updatePageNumber(
        context,
        newPageNumber: tafseerPageState.pageNumber,
        tafseerCode: widget.tafseerCode,
      );
    }
    if (widget.removeNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BottomWidgetService.scrollToTappedPositionBottom();
      });
    }
  }

  @override
  void dispose() {
    BottomWidgetService.currentTafseerItems = [];

    super.dispose();
  }

  String getTafseerTitle(String surahName) {
    String title = 'سورة ';
    if (surahName.contains('سورة')) {
      title = surahName;
    } else {
      title = title + surahName;
    }

    return title;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!widget.removeNavigation)
          ? AppBar(
              title: Text(
                widget.tafseerBookName,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    showFihrisDialog(
                      context,
                      (int pageNumber) {
                        tafseerPageCubitService.updatePageNumber(
                          context,
                          newPageNumber: pageNumber,
                          tafseerCode: widget.tafseerCode,
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
          child: BlocBuilder<TafseerPageCubit, TafseerPageState>(
            builder: (context, tafseerPageState) {
              if (tafseerPageState is CurrentTafseerPageState) {
                BottomWidgetService.currentTafseerItems =
                    tafseerPageState.currentTafseerPageList.ayahs;
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
                                  height: 40,
                                  color: AppColors.lightGrey,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          tafseerPageCubitService
                                              .updatePageNumber(
                                            context,
                                            newPageNumber: getUpdatedPageNumber(
                                              currentPageNumber:
                                                  tafseerPageState.pageNumber,
                                            ),
                                            tafseerCode: widget.tafseerCode,
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
                                        tafseerPageState.pageNumber.toString(),
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          tafseerPageCubitService
                                              .updatePageNumber(
                                            context,
                                            newPageNumber: getUpdatedPageNumber(
                                              currentPageNumber:
                                                  tafseerPageState.pageNumber,
                                              isPositive: false,
                                            ),
                                            tafseerCode: widget.tafseerCode,
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
                                  left: 2,
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0),
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
                              ),
                              Expanded(
                                child: BottomModelDropdownTafseerWidget(
                                  currentTafseerCode:
                                      tafseerPageState.tafseerCode,
                                ),
                              ),
                            ],
                          ),
                        Builder(builder: (context) {
                          var tafseerAyahs = removeDuplicates(
                              tafseerPageState.currentTafseerPageList.ayahs);
                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: ScrollablePositionedList.builder(
                                itemScrollController: BottomWidgetService
                                    .bottomWidgetScrollController,
                                itemCount: tafseerAyahs.length,
                                itemBuilder: (context, index) {
                                  AyahWithTafseer currentAyah =
                                      tafseerAyahs[index];
                                  return Column(
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerEnd,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const SizedBox(height: 15),
                                              if (currentAyah.ayahId == 1)
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
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                              if (!onlyShowQuran) ...[
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child: Text(
                                                    currentAyah.tafseerText,
                                                    textAlign: TextAlign.start,
                                                    style: context
                                                        .textTheme.bodySmall!
                                                        .copyWith(
                                                      fontSize: fontSizeState
                                                          .tafseerFontSize,
                                                      //uthmanyFontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          getTextThemedModeColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                          );
                        }),
                      ],
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
