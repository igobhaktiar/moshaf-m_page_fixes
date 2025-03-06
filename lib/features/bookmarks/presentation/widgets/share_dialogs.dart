import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/widgets/share_dialog_ayah_list_widget.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:qeraat_moshaf_kwait/features/tafseer/data/models/tafseer_reading_model.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

import '../../../quran_translation/data/models/translation_page_list_model.dart';
import '../cubit/share_service/share_database_service.dart';

class ShareDialogs {
  static Color getTextThemedModeColor(
    BuildContext context, {
    Color lightModeColor = Colors.black,
  }) {
    return context.isDarkMode ? Colors.white : lightModeColor;
  }

  static Future<void> _captureAndShare(ScreenshotController controller) async {
    try {
      // Capture the widget as an image
      final imageBytes = await controller.capture();

      if (imageBytes != null) {
        // Save the image to a temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/ayah.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        // Share the image using share_plus
        await Share.shareFiles(
          [imagePath],
        );
      }
    } catch (e) {
      print('Error capturing and sharing screenshot: $e');
    }
  }

  static void showShareDialogGeneric({
    required BuildContext context,
    required dynamic ayah,
    bool showOnlyQuran = false,
    bool isTranslation = false,
    bool isTafseer = false,
    String? currentLanguageCode,
    String? currentBookCode,
  }) {
    List<dynamic> addedAyat = [ayah];
    bool isLoading = false;

    final ScreenshotController screenshotController = ScreenshotController();
    final ScrollController scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      _captureAndShare(screenshotController);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.transparent),
                        color: context.isDarkMode
                            ? Colors.black
                            : AppColors.tafseerTextColor.withOpacity(0.7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.translate.shareAyah,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.share,
                            color: context.isDarkMode
                                ? Colors.white
                                : AppColors.activeButtonColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.75,
                    ),
                    child: Screenshot(
                      controller: screenshotController,
                      child: Container(
                        color: context.isDarkMode ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 20.0),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: ShareDialogAyahListWidget(
                            addedAyahs: addedAyat,
                            scrollController: scrollController,
                            showOnlyQuran: showOnlyQuran,
                            isTranslation: isTranslation,
                            isTafseer: isTafseer,
                            currentLanguageCode: currentLanguageCode,
                            currentBookCode: currentBookCode,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.transparent),
                        color: context.isDarkMode
                            ? Colors.black
                            : AppColors.tafseerTextColor.withOpacity(0.7),
                      ),
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        child: CircularProgressIndicator(
                          color:
                              context.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        double scrollPosition =
                            scrollController.position.maxScrollExtent;

                        ShareDatabaseService shareDatabaseService =
                            ShareDatabaseService();

                        if (isTranslation && currentLanguageCode != null) {
                          AyahModel? nextAyah =
                              shareDatabaseService.getAyahFromTashkilList(
                                  context,
                                  addedAyat.last.surahIndex,
                                  addedAyat.last.ayahId);
                          if (nextAyah != null) {
                            AyahWithTranslation? ayahWithTranslation;

                            (ayahWithTranslation, currentLanguageCode) =
                                await ShareDatabaseService()
                                    .getSurahWithTranslation(
                              ayah: nextAyah,
                            );
                            setState(() {
                              addedAyat.add(ayahWithTranslation);
                            });
                          }
                        }
                        if (isTafseer && currentBookCode != null) {
                          AyahModel? nextAyah =
                              shareDatabaseService.getAyahFromTashkilList(
                                  context,
                                  addedAyat.last.surahIndex,
                                  addedAyat.last.ayahId);
                          if (nextAyah != null) {
                            AyahWithTafseer? ayahWithTafseer;

                            (ayahWithTafseer, currentLanguageCode) =
                                await ShareDatabaseService()
                                    .getSurahWithTafseer(
                              ayah: nextAyah,
                            );

                            setState(() {
                              addedAyat.add(ayahWithTafseer);
                            });
                          }
                        }
                        await Future.delayed((Durations.medium1), () {
                          scrollController.animateTo(
                            scrollPosition + 150, // Scroll to the bottom
                            duration: const Duration(
                                milliseconds:
                                    300), // Adjust the duration as needed
                            curve: Curves.easeInOut, // Smooth scrolling effect
                          );
                        });
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.transparent),
                          color: context.isDarkMode
                              ? Colors.black
                              : AppColors.tafseerTextColor.withOpacity(0.7),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: context.isDarkMode
                                  ? Colors.white
                                  : AppColors.activeButtonColor,
                              size: 20,
                            ),
                            Text(
                              context.translate.addNextAyah,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
