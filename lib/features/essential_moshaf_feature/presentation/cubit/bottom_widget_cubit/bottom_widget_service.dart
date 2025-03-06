import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../quran_translation/data/models/translation_page_list_model.dart';
import '../../../../tafseer/data/models/tafseer_reading_model.dart';

class BottomWidgetService {
  BottomWidgetService._();

  static int surahId = -1, ayahId = -1;

  static void sheetClosed() {
    surahId = -1;
    ayahId = -1;
  }

  static void updateAyahAndSurahId({
    required int toUpdateSurahId,
    required int toUpdateAyahId,
  }) {
    surahId = toUpdateSurahId;
    ayahId = toUpdateAyahId;
  }

  static ScrollController topWidgetScrollController = ScrollController();
  static List<AyahWithTafseer> currentTafseerItems = [];
  static List<AyahWithTranslation> currentTranslationItems = [];
  static ItemScrollController bottomWidgetScrollController =
      ItemScrollController();
  static ItemScrollController bottomWidgetScrollControllerTranslation =
      ItemScrollController();
  static List<double> itemHeights = [];
  static void scrollDown() {
    Future.delayed(Durations.extralong1, () {
      topWidgetScrollController.animateTo(
        topWidgetScrollController
            .position.maxScrollExtent, // Scroll to the bottom
        duration:
            const Duration(milliseconds: 700), // Adjust the duration as needed
        curve: Curves.easeInOut, // Smooth scrolling effect
      );
    });
  }

  // Function to scroll to the tapped position
  static void scrollToTappedPosition(Offset tapPosition) {
    try {
      Future.delayed(const Duration(milliseconds: 650), () {
        // Calculate the target scroll position based on the tap
        double targetScrollPosition =
            (tapPosition.dy + topWidgetScrollController.offset) - 150;

        // Optionally, clamp the scroll position to avoid overscrolling
        double maxScrollExtent =
            topWidgetScrollController.position.maxScrollExtent;
        targetScrollPosition = targetScrollPosition.clamp(0.0, maxScrollExtent);

        // Animate to the tapped position
        topWidgetScrollController.animateTo(
          targetScrollPosition,
          duration:
              const Duration(milliseconds: 700), // You can adjust the duration
          curve: Curves.easeInOut,
        );
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static double getTextHeight(String text, TextStyle style, double maxWidth) {
    // Create a TextPainter
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr, // Specify text direction
      maxLines: null, // Allow unlimited lines for calculation
    );

    // Layout the text with the given maxWidth
    textPainter.layout(maxWidth: maxWidth);

    // Get the line metrics and return the line count
    // return textPainter.computeLineMetrics().length;
    return textPainter.size.height;
  }

  static void scrollToTappedPositionBottom() {
    try {
      Future.delayed(const Duration(milliseconds: 1000), () {
        dynamic controller = bottomWidgetScrollController;
        if (currentTafseerItems.isNotEmpty) {
          controller = bottomWidgetScrollController;
        } else {
          controller = bottomWidgetScrollControllerTranslation;
        }

        if (BottomWidgetService.ayahId != -1 &&
            BottomWidgetService.surahId != -1) {
          // currentTafseerItems =
          //     TafseerPageCubitService().getCurrentFetchedTafseers();
          if (currentTafseerItems.isNotEmpty) {
            final tappedAyahIndex = currentTafseerItems.indexWhere(
              (ayah) => (ayah.surahIndex == BottomWidgetService.surahId &&
                  ayah.ayahId == BottomWidgetService.ayahId),
            );
            if (tappedAyahIndex != -1) {
              controller.jumpTo(
                index: tappedAyahIndex,
              );
            } else {
              debugPrint('Ayah not found for scrolling: $ayahId');
            }
          } else {
            final tappedAyahIndex =
                BottomWidgetService.currentTranslationItems.indexWhere(
              (ayah) => (ayah.surahIndex == BottomWidgetService.surahId &&
                  ayah.ayahId == BottomWidgetService.ayahId),
            );
            if (tappedAyahIndex != -1) {
              controller.jumpTo(
                index: tappedAyahIndex,
              );
            } else {
              debugPrint('Ayah not found for scrolling: $ayahId');
            }
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
