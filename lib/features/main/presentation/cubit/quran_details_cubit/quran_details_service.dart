import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/quran_details_cubit/quran_details_cubit.dart';
import 'package:xml/xml.dart';

import '../../../../../core/responsiveness/responsive_framework_helper.dart';

class QuranDetailsService {
  QuranDetailsService._();

  static const Color defaultQuranTextColor = Color(0xff000000);
  static const Color defaultQuranDarkThemeTextColor = Color(0xffffffff);
  static const int defaultTextShadeInDarkValue = 100;

  static Color getDefaultTextColorCondition(BuildContext context,
      {required Color currentQuranTextColor}) {
    Color colorToReturn = context.theme.brightness == Brightness.dark
        ? defaultQuranDarkThemeTextColor
        : defaultQuranTextColor;
    if (currentQuranTextColor == defaultQuranTextColor &&
        context.theme.brightness == Brightness.dark) {
      colorToReturn = colorToReturn;
    } else if (currentQuranTextColor == defaultQuranDarkThemeTextColor &&
        context.theme.brightness == Brightness.light) {
      colorToReturn = colorToReturn;
    } else {
      colorToReturn = currentQuranTextColor;
    }

    return colorToReturn;
  }

  static void resetQuranTextColor(
    BuildContext context,
  ) {
    context.read<QuranDetailsCubit>().setCurrentQuranTextColor(
          context.isDarkMode ? Colors.white : Colors.black,
          myTextShadeInDarkValue: 100,
        );
  }

  static void setQuranTextColor(
    BuildContext context, {
    required Color color,
  }) {
    final QuranDetailsState quranDetailsState =
        QuranDetailsCubit.get(context).state;
    int myTextShadeInDarkValue = defaultTextShadeInDarkValue;
    if (quranDetailsState is AppQuranDetailsState) {
      myTextShadeInDarkValue = quranDetailsState.currentTextShadeInDarkValue;
    }

    context.read<QuranDetailsCubit>().setCurrentQuranTextColor(
          color,
          myTextShadeInDarkValue: myTextShadeInDarkValue,
        );
    Color colorToChange = QuranDetailsService.getDefaultTextColorCondition(
      context,
      currentQuranTextColor: color,
    );
    bool isTwoPage = ResponsiveFrameworkHelper().isTwoPaged();
    if (isTwoPage) {
      XmlDocument? documentOne;
      XmlDocument? documentTwo;
      (documentOne, documentTwo) =
          AyahRenderBlocHelper.getTwoPagedSvgDocument(context);
      List<XmlElement> elementsToReturnOne = [];
      List<XmlElement> elementsToReturnTwo = [];
      (elementsToReturnOne, elementsToReturnTwo) =
          AyahRenderBlocHelper.getTwoPagedSvgElement(context);
      String svgDataOne = AyahRenderBlocHelper.colorAllAyaCustomSvgData(
        context,
        customColor: colorToChange,
        darkThemeTextShade: myTextShadeInDarkValue,
        document: documentOne!,
        elements: elementsToReturnOne,
      );
      String svgDataTwo = AyahRenderBlocHelper.colorAllAyaCustomSvgData(
        context,
        customColor: colorToChange,
        darkThemeTextShade: myTextShadeInDarkValue,
        document: documentTwo!,
        elements: elementsToReturnTwo,
      );
      AyahRenderBlocHelper.updatePage(
        context,
        isTwoPage: isTwoPage,
        firstPageSvgData: svgDataOne,
        secondPageSvgData: svgDataTwo,
        quranTextColor: colorToChange,
      );
    } else {
      String svgData = AyahRenderBlocHelper.colorAllAyaCustomSvgData(
        context,
        customColor: colorToChange,
        darkThemeTextShade: myTextShadeInDarkValue,
        document: AyahRenderBlocHelper.getSvgDocument(context)!,
        elements: AyahRenderBlocHelper.getSvgElement(context),
      );
      AyahRenderBlocHelper.updatePage(
        context,
        svgData: svgData,
        quranTextColor: colorToChange,
      );
    }
  }

  static void setTextShadeInDarkValue(
    BuildContext context, {
    required int shadeValue,
  }) {
    final QuranDetailsState quranDetailsState =
        QuranDetailsCubit.get(context).state;
    Color myQuranTextColor = defaultQuranTextColor;
    if (quranDetailsState is AppQuranDetailsState) {
      myQuranTextColor = quranDetailsState.currentQuranTextColor;
    }

    context.read<QuranDetailsCubit>().setCurrentDarkShadeValue(
          shadeValue,
          myQuranTextColor: myQuranTextColor,
        );

    bool isTwoPage = ResponsiveFrameworkHelper().isTwoPaged();
    if (isTwoPage) {
      XmlDocument? documentOne;
      XmlDocument? documentTwo;
      (documentOne, documentTwo) =
          AyahRenderBlocHelper.getTwoPagedSvgDocument(context);
      List<XmlElement> elementsToReturnOne = [];
      List<XmlElement> elementsToReturnTwo = [];
      (elementsToReturnOne, elementsToReturnTwo) =
          AyahRenderBlocHelper.getTwoPagedSvgElement(context);
      String svgDataOne = AyahRenderBlocHelper.colorAllAya(
        context,
        (0 + (100 - shadeValue)).toDouble(),
        document: documentOne!,
        elements: elementsToReturnOne,
      );
      String svgDataTwo = AyahRenderBlocHelper.colorAllAya(
        context,
        (0 + (100 - shadeValue)).toDouble(),
        document: documentTwo!,
        elements: elementsToReturnTwo,
      );
      AyahRenderBlocHelper.updatePage(
        context,
        isTwoPage: isTwoPage,
        firstPageSvgData: svgDataOne,
        secondPageSvgData: svgDataTwo,
        darkThemeTextShade: shadeValue,
      );
    } else {
      String svgData = AyahRenderBlocHelper.colorAllAya(
        context,
        (0 + (100 - shadeValue)).toDouble(),
        document: AyahRenderBlocHelper.getSvgDocument(context)!,
        elements: AyahRenderBlocHelper.getSvgElement(context),
      );

      AyahRenderBlocHelper.updatePage(
        context,
        svgData: svgData,
        darkThemeTextShade: shadeValue,
      );
    }
  }
}
