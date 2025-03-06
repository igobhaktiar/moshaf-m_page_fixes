import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/language_service.dart';

class ShareDialogTheme {
  Color getTextThemedModeColor(
    BuildContext context, {
    Color lightModeColor = Colors.black,
  }) {
    return context.isDarkMode ? Colors.white : lightModeColor;
  }
}

class ShareDialogAyahListWidget extends StatelessWidget {
  ShareDialogAyahListWidget({
    super.key,
    required this.addedAyahs,
    required this.scrollController,
    this.showOnlyQuran = false,
    this.isTranslation = false,
    this.isTafseer = false,
    this.currentLanguageCode,
    this.currentBookCode,
  });
  final ScrollController scrollController;
  final bool showOnlyQuran, isTranslation, isTafseer;
  final String? currentLanguageCode, currentBookCode;
  final List<dynamic> addedAyahs;
  String ayahCombined = "";
  @override
  Widget build(BuildContext context) {
    if (showOnlyQuran) {
      return ListView(
        shrinkWrap: true,
        controller: scrollController,
        children: [
          Builder(builder: (context) {
            String rtlMarker = '\u200F';
            List<Widget> contentWidgets = [];
            Map<int, List<String>> surahAyahs = {};

            // Group ayahs by surah
            for (var ayah in addedAyahs) {
              if (!surahAyahs.containsKey(ayah.surahIndex)) {
                surahAyahs[ayah.surahIndex] = [];
              }
              surahAyahs[ayah.surahIndex]!.add(rtlMarker + ayah.verseUthmani);
            }

            // Create widgets for each surah
            for (var surahIndex in surahAyahs.keys) {
              // Add frame for every surah including the first one
              contentWidgets.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Image.asset(
                      '$surahFramesAssetsPath/${surahIndex.toString().padLeft(3, '0')}.png',
                      color: context.isDarkMode ? Colors.white : null,
                    ),
                  ),
                ),
              );

              contentWidgets.add(
                Text(
                  surahAyahs[surahIndex]!.join(''),
                  textAlign: TextAlign.right,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                    height: 1.7,
                    fontFamily: AppStrings.qeeratKuwaitFontFamily,
                    color: ShareDialogTheme().getTextThemedModeColor(context),
                  ),
                ),
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: contentWidgets,
              ),
            );
          }),
        ],
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      controller: scrollController,
      itemBuilder: (context, index) {
        bool showHeader = true;
        try {
          if (addedAyahs[index].surahIndex ==
              addedAyahs[index - 1].surahIndex) {
            showHeader = false;
          }
        } catch (e) {
          showHeader = true;
        }
        return ShareDialogSingleAyahTile(
          ayah: addedAyahs[index],
          showHeader: showHeader,
          showOnlyQuran: showOnlyQuran,
          isTranslation: isTranslation,
          isTafseer: isTafseer,
          currentLanguageCode: currentLanguageCode,
          currentBookCode: currentBookCode,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 40,
          thickness: 0.7,
          color: ShareDialogTheme().getTextThemedModeColor(
            context,
            lightModeColor: AppColors.tafseerTextColor,
          ),
        );
      },
      itemCount: addedAyahs.length,
    );
  }
}

class ShareDialogSingleAyahTile extends StatelessWidget {
  const ShareDialogSingleAyahTile({
    super.key,
    required this.ayah,
    this.showOnlyQuran = false,
    this.showHeader = true,
    this.isTranslation = false,
    this.isTafseer = false,
    this.currentLanguageCode,
    this.currentBookCode,
  });

  final bool showOnlyQuran, showHeader, isTranslation, isTafseer;
  final String? currentLanguageCode, currentBookCode;
  final dynamic ayah;

  @override
  Widget build(BuildContext context) {
    ShareDialogTheme shareDialogTheme = ShareDialogTheme();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Surah Name with respective border
        if (showHeader) ...[
          Image.asset(
            '$surahFramesAssetsPath/${ayah.surahIndex.toString().padLeft(3, '0')}.png',
            color: context.isDarkMode ? Colors.white : null,
          ),
          const SizedBox(height: 10),
        ],
        //Surah Display
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.verseUthmani,
              textAlign: TextAlign.start,
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w400,
                height: 1.75,
                fontSize: 24,
                fontFamily: AppStrings.qeeratKuwaitFontFamily,
                color: shareDialogTheme.getTextThemedModeColor(
                  context,
                ),
              ),
            ),
          ),
        ),
        if ((isTranslation || isTafseer) && (!showOnlyQuran)) ...[
          Divider(
            height: 40,
            thickness: 0.7,
            color: shareDialogTheme.getTextThemedModeColor(
              context,
              lightModeColor: AppColors.tafseerTextColor,
            ),
          ),
          if (isTranslation && currentLanguageCode != null) ...[
            Align(
              alignment: LanguageService.isCodeLanguageRtl(currentLanguageCode!)
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: Directionality(
                textDirection:
                    LanguageService.isCodeLanguageRtl(currentLanguageCode!)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                child: Text(
                  ayah.translatedText,
                  style: context.textTheme.bodySmall!.copyWith(
                    fontSize: 16,
                    fontFamily:
                        LanguageService.isUrduOrPersian(currentLanguageCode!)
                            ? AppStrings.urduNoto
                            : null,
                    fontWeight: FontWeight.w400,
                    color: shareDialogTheme.getTextThemedModeColor(
                      context,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (isTafseer && currentBookCode != null) ...[
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                ayah.tafseerText,
                textAlign: TextAlign.start,
                style: context.textTheme.bodySmall!.copyWith(
                  fontSize: 14,
                  //uthmanyFontFamily,
                  fontWeight: FontWeight.w400,
                  color: shareDialogTheme.getTextThemedModeColor(
                    context,
                  ),
                ),
              ),
            ),
          ]
        ]
      ],
    );
  }
}
