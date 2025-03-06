import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/data_sources/all_ayat_with_tashkeel.dart';
import 'package:qeraat_moshaf_kwait/core/responsiveness/responsive_framework_helper.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/data_sources/ayah_svg_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/data_sources/hizb_without_sjada.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/svg_element.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_rect_service.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/quran_details_cubit/quran_details_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/show_juz_popup/show_juz_popup_cubit.dart';
import 'package:xml/xml.dart';

import '../../../../../core/utils/play_asset_delivery.dart';
import '../../../../essential_moshaf_feature/data/data_sources/ayah_svg_service_helper.dart';
import '../../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import '../ayah_two_page_render_bloc/ayah_two_page_render_bloc.dart';
import '../quran_details_cubit/quran_details_service.dart';

class AyahRenderBlocHelper {
  AyahRenderBlocHelper._();
  static const int intialPageIndex = 0;
  static BuildContext? layoutContext;
  static BuildContext? firstPageLayoutContext;
  static BuildContext? secondPageLayoutContext;

  static String getSvgString(int pageIndex, {String addInString = ''}) {
    String currentPageNumberString = AppStrings.getAssetSvgNormalPagePath(
      pageIndex + 1,
    );
    return 'assets/ayah_svg/$currentPageNumberString$addInString.svg';
  }

  static String getSvgStringFromIndex(int pageIndex,
      {String addInString = ''}) {
    String currentPageNumberString = AppStrings.getAssetSvgNormalPagePath(
      pageIndex + 1,
    );
    return '$currentPageNumberString$addInString.svg';
  }

  static Future<String> preprocessingOnSvgData(
    BuildContext context, {
    required String svgData,
    required int svgNumber,
    int zoomPercentage = 28,
  }) async {
    String updatedSvg = svgData;

    if (context.theme.brightness != Brightness.dark) {
      updatedSvg =
          AyahSvgServiceHelper.removePathByClass(updatedSvg, 'aya-dark night');
    } else {
      updatedSvg =
          AyahSvgServiceHelper.removePathByClass(updatedSvg, 'aya-light-2 day');
      updatedSvg =
          AyahSvgServiceHelper.removePathByClass(updatedSvg, 'aya-light-1 day');
    }
    updatedSvg = AyahSvgServiceHelper.adjustSvgForTheme(
        updatedSvg, context.theme.brightness == Brightness.dark);

    updatedSvg = await AyahSvgServiceHelper.addPageHeader(
      svgString: updatedSvg,
      pageNumber: svgNumber,
      zoomPercentage: zoomPercentage,
    );

    updatedSvg = await AyahSvgServiceHelper.addSmallHisbSajdaSakta(
      svgString: updatedSvg,
      pageNumber: svgNumber,
      zoomPercentage: zoomPercentage,
    );

    if (ZoomService().isBorderEnable(zoomPercentage)) {
      updatedSvg = await AyahSvgServiceHelper.addSvgBorder(
        svgString: updatedSvg,
        pageNumber: svgNumber,
      );
      if (ZoomService().getCurrentZoomEnum(context) == ZoomEnum.large) {
        // updatedSvg = await AyahSvgServiceHelper.removeDefaultHisbIcon(
        //   svgString: updatedSvg,
        //   pageNumber: svgNumber,
        // );
      }
      if (svgNumber < 3) {
        updatedSvg = AyahSvgService.adjustSvgForFontSize(
          context,
          svgString: updatedSvg,
          pageNumber: svgNumber,
          zoomPercentage: zoomPercentage,
        );
      }
    } else {
      if (svgNumber > 2) {
        updatedSvg = await AyahSvgServiceHelper.removeBorderAndMaxZoom(
          svgString: updatedSvg,
          pageNumber: svgNumber,
          zoomPercentage: zoomPercentage,
        );
      }
    }

    // Apply Qeraat styles
    updatedSvg = AyahSvgServiceHelper.updateQeeratStyles(svgString: updatedSvg);

    return updatedSvg;
  }

  static List<XmlElement> getXmlElements(XmlDocument xmlDocument) {
    return xmlDocument
        .findAllElements('g')
        .where((element) => element.getAttribute('objectid') != null)
        .toList();
  }

  static (double, double) getWidthAndHeight(
      XmlDocument document, List<XmlElement> elements) {
    double svgWidth = 0;
    double svgHeight = 0;
    final XmlElement? svgElement = document.findAllElements('svg').firstOrNull;
    if (svgElement != null) {
      // Extract width and height attributes
      final String? viewBox = svgElement.getAttribute('viewBox');
      final String? widthStr = svgElement.getAttribute('width');
      final String? heightStr = svgElement.getAttribute('height');

      if (viewBox != null) {
        List<String> viewBoxValues = viewBox.split(' ');
        svgWidth = double.parse(viewBoxValues[2]);
        svgHeight = double.parse(viewBoxValues[3]);
      } else {}
    } else {
      debugPrint('SVG element not found.');
    }
    return (svgWidth, svgHeight);
  }

  static List<SvgElement> getSvgElementList(
    List<XmlElement> elements,
  ) {
    return elements.map((element) {
      final String rectData = element.getAttribute('rect') ?? '0,0,0,0';
      final List<double> rectValues = rectData
          .split(',')
          .map((value) => double.tryParse(value) ?? 0.0)
          .toList();
      if (rectValues.length == 4) {
        final Rect rect = Rect.fromLTWH(rectValues[0], rectValues[1],
            rectValues[2] - rectValues[0], rectValues[3] - rectValues[1]);
        return SvgElement(
          objectId: element.getAttribute('objectid') ?? '',
          sora: element.getAttribute('sora') ?? '',
          aya: element.getAttribute('aya') ?? '',
          linenumber: element.getAttribute('linenumber') ?? '',
          objecttype: element.getAttribute('objecttype') ?? '',
          objecttext: element.getAttribute('objecttext') ?? '',
          objecttextemlaey: element.getAttribute('objecttextemlaey') ?? '',
          objectinayanumber: element.getAttribute('objectinayanumber') ?? '',
          wowatuf: element.getAttribute('wowatuf') ?? '',
          rect: rect,
        );
      } else {
        throw Exception('Invalid rect data');
      }
    }).toList();
  }

  static Future<void> getDelay() async {
    Future.delayed(Durations.long1, () {
      return;
    });
  }

  //View Box Functionality
  static String? fetchViewBoxOriginal(BuildContext context, String svgData) {
    String? originalViewString = getSvgViewBox(
      context,
      svgData,
    );

    return originalViewString;
  }

  static String? getSvgViewBox(
    BuildContext context,
    String svgData,
  ) {
    String? viewBox;

    final XmlDocument documentNewFetched = XmlDocument.parse(svgData);
    final XmlElement? svgElement =
        documentNewFetched.findAllElements('svg').firstOrNull;
    if (svgElement != null) {
      // Extract width and height attributes
      viewBox = svgElement.getAttribute('viewBox');
    }
    return viewBox;
  }

  static String colorAllAyaCustomSvgData(
    BuildContext context, {
    required Color customColor,
    required int darkThemeTextShade,
    required XmlDocument document,
    required List<XmlElement> elements,
  }) {
    String colorToChangeValue =
        AyahSvgServiceHelper.getStringFromColor(customColor);
    if (context.theme.brightness == Brightness.dark &&
        getDarkThemeTextShade(context) !=
            QuranDetailsService.defaultTextShadeInDarkValue) {
      colorToChangeValue = AyahSvgServiceHelper.valueToColorHex(
        (0 + (100 - darkThemeTextShade)).toDouble(),
      );
    }
    print('ColorPath: fill:$colorToChangeValue');
    for (final XmlElement element in elements) {
      // Check for the specified attributes and values
      final isObjectTypeNotAyaMark =
          element.getAttribute('objecttype') != 'otAyaMark';

      if (isObjectTypeNotAyaMark) {
        List<XmlElement> allPathElements =
            element.findAllElements('path').toList();
        element.findElements('path');
        for (final XmlElement pathElement in allPathElements) {
          pathElement.setAttribute('style', 'fill:$colorToChangeValue');
        }
      }
    }
    // Convert the modified XmlDocument back to a string
    return document.toXmlString(pretty: true);
  }

  static String hideShowAyaMarkNight(
    bool visibleFlag, {
    required List<XmlElement> elements,
    required XmlDocument document,
  }) {
    String tectColor = AyahSvgServiceHelper.valueToColorHex(100);
    for (final XmlElement element in elements) {
      // Check for the specified attributes and values
      final isObjectTypeAyaMark =
          element.getAttribute('objecttype') == 'otAyaMark';

      if (isObjectTypeAyaMark) {
        List<XmlElement> allPathElements =
            element.findAllElements('path').toList();
        final Iterable<XmlElement> pathElements = element.findElements('path');
        for (final XmlElement pathElement in allPathElements) {
          final isPathClassDark =
              pathElement.getAttribute('class') == 'aya-dark';
          if (isPathClassDark) {
            if (visibleFlag) {
              pathElement.setAttribute('style', 'fill:$tectColor;');
            } else {
              pathElement.setAttribute('style', 'display: none;');
            }
          }
        }
      }
    }
    // Convert the modified XmlDocument back to a string
    return document.toXmlString(pretty: true);
  }

  static String hideShowAyaMarkLight(
    bool visibleFlag, {
    required List<XmlElement> elements,
    required XmlDocument document,
  }) {
    AyahSvgServiceHelper.valueToColorHex(100);
    for (final XmlElement element in elements) {
      // Check for the specified attributes and values
      final isObjectTypeAyaMark =
          element.getAttribute('objecttype') == 'otAyaMark';

      if (isObjectTypeAyaMark) {
        List<XmlElement> allPathElements =
            element.findAllElements('path').toList();
        element.findElements('path');
        for (final XmlElement pathElement in allPathElements) {
          final isPathClassLight1 =
              pathElement.getAttribute('class') == 'aya-light-1';
          final isPathClassLight2 =
              pathElement.getAttribute('class') == 'aya-light-2';

          if (isPathClassLight1) {
            if (visibleFlag) {
              pathElement.setAttribute('style',
                  'fill:url(#blueWhiteCenterLight);fill-opacity:1;stroke:none;stroke-width:0.0839085;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
            } else {
              pathElement.setAttribute('style', 'display: none;');
            }
          }

          if (isPathClassLight2) {
            if (visibleFlag) {
              pathElement.setAttribute('style',
                  'fill:#ceaa26;fill-opacity:1;stroke:#080808;stroke-width:0.0833881;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
            } else {
              pathElement.setAttribute('style', 'display: none;');
            }
          }
        }
      }
    }
    // Convert the modified XmlDocument back to a string
    return document.toXmlString(pretty: true);
  }

  static Future<String?> getNextSvgData(
    BuildContext currentContext,
    int currentRenderedIndex,
    int zoomPercentage,
    Color quranTextColor,
    int darkThemeTextShade,
  ) async {
    int currentIndex = currentRenderedIndex + 1;
    String? svgData;
    if (currentRenderedIndex >= 0 && currentRenderedIndex < 604) {
      // svgData = await rootBundle.loadString(
      //   AyahRenderBlocHelper.getSvgString(currentIndex),
      // );
      svgData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
        AyahRenderBlocHelper.getSvgStringFromIndex(
          currentIndex,
        ),
      );

      if (!ZoomService().isBorderEnable(zoomPercentage) &&
          currentIndex + 1 < 3) {
        svgData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
          AyahRenderBlocHelper.getSvgStringFromIndex(
            currentIndex,
            addInString: '-level3',
          ),
        );
        // svgData = await rootBundle.loadString(
        //   AyahRenderBlocHelper.getSvgString(
        //     currentIndex,
        //     addInString: '-level3',
        //   ),
        // );
      }

      svgData = await AyahRenderBlocHelper.preprocessingOnSvgData(
        currentContext,
        svgData: svgData,
        svgNumber: currentIndex + 1,
        zoomPercentage: zoomPercentage,
      );

      bool isCustomColor = false;
      if (quranTextColor != QuranDetailsService.defaultQuranTextColor) {
        isCustomColor = true;
      }
      XmlDocument document = XmlDocument.parse(svgData);
      List<XmlElement> elements = AyahRenderBlocHelper.getXmlElements(
        document,
      );
      double width = 0, height = 0;
      (width, height) = AyahRenderBlocHelper.getWidthAndHeight(
        document,
        elements,
      );
      if (width == 0 && height == 0) {
        throw Exception("Condition Failed: width !=0 && height !=0");
      }
      if (currentContext.theme.brightness == Brightness.dark) {
        svgData = AyahRenderBlocHelper.hideShowAyaMarkNight(
          true,
          elements: elements,
          document: document,
        );
        svgData = AyahRenderBlocHelper.hideShowAyaMarkLight(
          false,
          elements: elements,
          document: document,
        );
        svgData = AyahRenderBlocHelper.colorAllAya(
          currentContext,
          (0 + (100 - darkThemeTextShade)).toDouble(),
          elements: elements,
          document: document,
          isCustom: isCustomColor,
        );
      } else {
        svgData = AyahRenderBlocHelper.hideShowAyaMarkNight(
          false,
          elements: elements,
          document: document,
        );
        svgData = AyahRenderBlocHelper.hideShowAyaMarkLight(
          true,
          elements: elements,
          document: document,
        );
        svgData = AyahRenderBlocHelper.colorAllAya(
          currentContext,
          100,
          elements: elements,
          document: document,
          isCustom: isCustomColor,
        );
      }
    }
    return svgData;
  }
  //

  static void pageChangeInitialize(
    BuildContext context,
    int index, {
    bool defaultTransition = true,
    bool resetQuranTextColor = false,
  }) {
    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered ||
        ayahRenderState is AyahRenderInitial) {
      ZoomService zoomService = ZoomService();
      ZoomEnum zoomCurrentPercentageEnum =
          zoomService.getCurrentZoomEnum(context);
      AyahRenderBlocHelper.initializePage(
        context,
        index: index,
        zoomPercentage: zoomService.zoomPercentage[zoomCurrentPercentageEnum]!,
        defaultTransition: defaultTransition,
        resetQuranTextColor: resetQuranTextColor,
      );
      context.read<EssentialMoshafCubit>().updateSlider();
    }
  }

  static void preloadImage(String asset) {}

  static (int, int) getFirstAndSecondPageByIndex(int index) {
    int firstPageIndex = AyahRenderBlocHelper.intialPageIndex;
    int secondPageIndex = firstPageIndex + 1;

    if (index % 2 == 0) {
      firstPageIndex = index;
      secondPageIndex = firstPageIndex + 1;
    } else {
      secondPageIndex = index;
      firstPageIndex = secondPageIndex - 1;
    }
    return (firstPageIndex, secondPageIndex);
  }

  //Bloc Functions
  static Future<void> initializePage(
    BuildContext context, {
    required int index,
    required int zoomPercentage,
    bool defaultTransition = true,
    bool resetQuranTextColor = false,
  }) async {
    ZoomService zoomService = ZoomService();
    zoomService.updateZoom(
      context,
      zoom: zoomService.getZoomEnumFromPercentage(
        zoomPercentage,
      ),
    );
    bool isTwoPage = ResponsiveFrameworkHelper().isTwoPaged();
    if (isTwoPage) {
      final (firstPageIndex, secondPageIndex) =
          getFirstAndSecondPageByIndex(index);
      if (defaultTransition ||
          secondPageIndex == 603 ||
          index < AyahRenderBlocHelper.getPageIndex(context) ||
          (index - AyahRenderBlocHelper.getPageIndex(context)) > 2) {
        BlocProvider.of<AyahTwoPageRenderBloc>(context).add(
          IntializeTwoPageRenderWidget(
            firstPagePageIndex: firstPageIndex,
            secondPagePageIndex: secondPageIndex,
            zoomPercentage: zoomPercentage,
            quranTextColor: AyahRenderBlocHelper.getQuranTextColor(
              context,
              isReset: resetQuranTextColor,
            ),
            darkThemeTextShade:
                AyahRenderBlocHelper.getDarkThemeTextShade(context),
          ),
        );
      } else {
        BlocProvider.of<AyahTwoPageRenderBloc>(context).add(
          IntializeTwoPageRenderWidgetWithTwoNextPage(
            firstPagePageIndex: firstPageIndex,
            secondPagePageIndex: secondPageIndex,
            zoomPercentage: zoomPercentage,
            quranTextColor: AyahRenderBlocHelper.getQuranTextColor(
              context,
              isReset: resetQuranTextColor,
            ),
            darkThemeTextShade:
                AyahRenderBlocHelper.getDarkThemeTextShade(context),
          ),
        );
      }
    } else {
      if (defaultTransition ||
          index == 603 ||
          index < AyahRenderBlocHelper.getPageIndex(context) ||
          (index - AyahRenderBlocHelper.getPageIndex(context)) > 1) {
        BlocProvider.of<AyahRenderBloc>(context).add(
          IntializeRenderWidget(
            currentPageIndex: index,
            zoomPercentage: zoomPercentage,
            quranTextColor: AyahRenderBlocHelper.getQuranTextColor(
              context,
              isReset: resetQuranTextColor,
            ),
            darkThemeTextShade:
                AyahRenderBlocHelper.getDarkThemeTextShade(context),
          ),
        );
      } else {
        BlocProvider.of<AyahRenderBloc>(context).add(
          IntializeRenderWidgetWithNextPage(
            // IntializeRenderWidget(
            currentPageIndex: index,
            zoomPercentage: zoomPercentage,
            quranTextColor: AyahRenderBlocHelper.getQuranTextColor(
              context,
              isReset: resetQuranTextColor,
            ),
            darkThemeTextShade:
                AyahRenderBlocHelper.getDarkThemeTextShade(context),
          ),
        );
      }
    }
    // Future.delayed(const Duration(seconds: 4), () {
    //   AyahRenderBlocHelper.removeHisbAndUpdateBloc();
    // });
  }

  static void updatePage(
    BuildContext context, {
    bool isTwoPage = false,
    int? pageIndex,
    Color? quranTextColor,
    int? darkThemeTextShade,
    String? currentPage,
    String? svgData,
    XmlDocument? document,
    List<XmlElement>? elements,
    double? svgWidth,
    double? svgHeight,
    List<SvgElement>? svgElementsList,
    BuildContext? layoutContext,
    String? originalViewBox,
    int? firstPageIndex,
    int? secondPageIndex,
    String? firstCurrentPage,
    String? secondCurrentPage,
    String? firstPageSvgData,
    String? secondPageSvgData,
    String? svgDataNextPageFirst,
    String? svgDataNextPageSecond,
    XmlDocument? firstPageDocument,
    XmlDocument? secondPageDocument,
    List<XmlElement>? firstPageElements,
    List<XmlElement>? secondPageElements,
    double? firstPageSvgWidth,
    double? firstPageSvgHeight,
    double? secondPageSvgWidth,
    double? secondPageSvgHeight,
    List<SvgElement>? firstPageSvgElementsList,
    List<SvgElement>? secondPageSvgElementsList,
    String? firstPageOriginalViewBox,
    String? secondPageOriginalViewBox,
  }) {
    if (isTwoPage) {
      final AyahTwoPageRenderBloc ayahTwoPageRenderBloc =
          BlocProvider.of<AyahTwoPageRenderBloc>(context);
      if (ayahTwoPageRenderBloc.state is TwoPageAyahRendered) {
        ayahTwoPageRenderBloc.add(
          UpdateAyahTwoPageRenderedState(
            previousState: ayahTwoPageRenderBloc.state as TwoPageAyahRendered,
            firstPageIndex: firstPageIndex,
            secondPageIndex: secondPageIndex,
            quranTextColor: quranTextColor,
            darkThemeTextShade: darkThemeTextShade,
            firstCurrentPage: firstCurrentPage,
            secondCurrentPage: secondCurrentPage,
            firstPageSvgData: firstPageSvgData,
            secondPageSvgData: secondPageSvgData,
            svgDataNextPageFirst: svgDataNextPageFirst,
            svgDataNextPageSecond: svgDataNextPageSecond,
            firstPageDocument: firstPageDocument,
            secondPageDocument: secondPageDocument,
            firstPageElements: firstPageElements,
            secondPageElements: secondPageElements,
            firstPageSvgWidth: firstPageSvgWidth,
            firstPageSvgHeight: firstPageSvgHeight,
            secondPageSvgWidth: secondPageSvgWidth,
            secondPageSvgHeight: secondPageSvgHeight,
            firstPageSvgElementsList: firstPageSvgElementsList,
            secondPageSvgElementsList: secondPageSvgElementsList,
            layoutContext: layoutContext,
            firstPageOriginalViewBox: firstPageOriginalViewBox,
            secondPageOriginalViewBox: secondPageOriginalViewBox,
          ),
        );
      }
    } else {
      final AyahRenderState ayahRenderState =
          BlocProvider.of<AyahRenderBloc>(context).state;
      if (ayahRenderState is AyahRendered) {
        BlocProvider.of<AyahRenderBloc>(context).add(
          UpdateAyahRenderedState(
            previousState: ayahRenderState,
            pageIndex: pageIndex,
            quranTextColor: quranTextColor,
            darkThemeTextShade: darkThemeTextShade,
            currentPage: currentPage,
            svgData: svgData,
            document: document,
            elements: elements,
            svgWidth: svgWidth,
            svgHeight: svgHeight,
            svgElementsList: svgElementsList,
            layoutContext: layoutContext,
            originalViewBox: originalViewBox,
          ),
        );
      }
    }
  }

  static Color getQuranTextColor(
    BuildContext context, {
    bool isReset = false,
  }) {
    Color colorToReturn = QuranDetailsService.getDefaultTextColorCondition(
      context,
      currentQuranTextColor: QuranDetailsService.defaultQuranTextColor,
    );
    if (!isReset) {
      // final AyahRenderState ayahRenderState =
      //     BlocProvider.of<AyahRenderBloc>(context).state;
      // if (ayahRenderState is AyahRendered &&
      //     ayahRenderState.quranTextColor != null) {
      //   colorToReturn = ayahRenderState.quranTextColor!;
      // }
      final QuranDetailsState quranDetailsState =
          BlocProvider.of<QuranDetailsCubit>(context).state;
      if (quranDetailsState is AppQuranDetailsState) {
        colorToReturn = quranDetailsState.currentQuranTextColor;
      }
    }
    return colorToReturn;
  }

  static int getDarkThemeTextShade(
    BuildContext context,
  ) {
    int shadeToReturn = QuranDetailsService.defaultTextShadeInDarkValue;
    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered &&
        ayahRenderState.darkThemeTextShade != null) {
      shadeToReturn = ayahRenderState.darkThemeTextShade!;
    }
    return shadeToReturn;
  }

  static int getPageIndex(
    BuildContext context,
  ) {
    int pageIndexToReturn = 0;
    if (ResponsiveFrameworkHelper().isTwoPaged()) {
      final AyahTwoPageRenderState ayahTwoPageRenderState =
          BlocProvider.of<AyahTwoPageRenderBloc>(context).state;
      if (ayahTwoPageRenderState is TwoPageAyahRendered &&
          ayahTwoPageRenderState.firstPageIndex != null) {
        pageIndexToReturn = ayahTwoPageRenderState.firstPageIndex!;
      }
    } else {
      final AyahRenderState ayahRenderState =
          BlocProvider.of<AyahRenderBloc>(context).state;
      if (ayahRenderState is AyahRendered &&
          ayahRenderState.pageIndex != null) {
        pageIndexToReturn = ayahRenderState.pageIndex!;
      }
    }
    return pageIndexToReturn;
  }

  static String getPageNumber(
    BuildContext context,
  ) {
    String pageToReturn = "001";
    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered &&
        ayahRenderState.currentPage != null) {
      pageToReturn = ayahRenderState.currentPage!;
    }
    return pageToReturn;
  }

  static String getSvgData(
    BuildContext context,
  ) {
    String svgData = '';
    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered && ayahRenderState.svgData != null) {
      svgData = ayahRenderState.svgData!;
    }
    return svgData;
  }

  static List<XmlElement> getSvgElement(
    BuildContext context,
  ) {
    List<XmlElement> elementsToReturn = [];
    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered && ayahRenderState.elements != null) {
      elementsToReturn = ayahRenderState.elements!;
    }
    return elementsToReturn;
  }

  static (List<XmlElement>, List<XmlElement>) getTwoPagedSvgElement(
    BuildContext context,
  ) {
    List<XmlElement> elementsToReturnOne = [];
    List<XmlElement> elementsToReturnTwo = [];
    final AyahTwoPageRenderState ayahTwoPageRenderState =
        BlocProvider.of<AyahTwoPageRenderBloc>(context).state;
    if (ayahTwoPageRenderState is TwoPageAyahRendered) {
      if (ayahTwoPageRenderState.firstPageElements != null) {
        elementsToReturnOne = ayahTwoPageRenderState.firstPageElements!;
      }
      if (ayahTwoPageRenderState.secondPageElements != null) {
        elementsToReturnTwo = ayahTwoPageRenderState.secondPageElements!;
      }
    }
    return (elementsToReturnOne, elementsToReturnTwo);
  }

  static XmlDocument? getSvgDocument(
    BuildContext context,
  ) {
    XmlDocument? xmlDocument;
    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered && ayahRenderState.document != null) {
      xmlDocument = ayahRenderState.document!;
    }
    return xmlDocument;
  }

  static (XmlDocument?, XmlDocument?) getTwoPagedSvgDocument(
    BuildContext context,
  ) {
    XmlDocument? xmlDocumentOne;
    XmlDocument? xmlDocumentTwo;
    final AyahTwoPageRenderState ayahTwoPageRenderState =
        BlocProvider.of<AyahTwoPageRenderBloc>(context).state;
    if (ayahTwoPageRenderState is TwoPageAyahRendered) {
      if (ayahTwoPageRenderState.firstPageDocument != null) {
        xmlDocumentOne = ayahTwoPageRenderState.firstPageDocument!;
      }
      if (ayahTwoPageRenderState.secondPageDocument != null) {
        xmlDocumentTwo = ayahTwoPageRenderState.secondPageDocument!;
      }
    }
    return (xmlDocumentOne, xmlDocumentTwo);
  }

  static BuildContext? getLayoutContext(
    BuildContext context,
  ) {
    BuildContext? layoutContextToReturn;
    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered &&
        ayahRenderState.layoutContext != null) {
      layoutContextToReturn = ayahRenderState.layoutContext!;
    }
    return layoutContextToReturn;
  }

  static String colorAllAya(
    BuildContext context,
    double value, {
    bool isCustom = false,
    required List<XmlElement> elements,
    required XmlDocument document,
  }) {
    String tectColor = AyahSvgServiceHelper.valueToColorHex(value);
    if (isCustom) {
      tectColor = AyahSvgServiceHelper.getStringFromColor(
          AyahRenderBlocHelper.getQuranTextColor(context));
    }
    for (final XmlElement element in elements) {
      // Check for the specified attributes and values
      //Check if it's ayah text or an ointment
      final isObjectTypeNotAyaMark =
          element.getAttribute('objecttype') != 'otAyaMark';

      List<XmlElement> allPathElements =
          element.findAllElements('path').toList();
      final Iterable<XmlElement> pathElements = element.findElements('path');
      for (final XmlElement pathElement in allPathElements) {
        //General Expected fill color according to theme
        String pathAttribute = 'fill:$tectColor;';
        //If Object is Ointment
        if (!isObjectTypeNotAyaMark) {
          //Get Ointment Theme
          String? fetchedPathAttribute =
              AyahSvgServiceHelper.getOintmentColorInlineString();
          if (fetchedPathAttribute != null) {
            //If Ointment in dark mode
            pathAttribute = fetchedPathAttribute;
          } else {
            //If Ointment in light mode need no styling only default
            pathAttribute = '-1';
          }
        }
        if (pathAttribute != '-1') {
          //If Ointment in light mode need no styling only default
          //Update color for all the text
          //Update Ointment for dark mode
          pathElement.setAttribute('style', pathAttribute);
        }
      }
    }
    // Convert the modified XmlDocument back to a string
    return document.toXmlString(pretty: true);
  }

  static String colorAya(
    BuildContext context,
    int suraId,
    int ayaId, {
    bool isCustomColor = false,
    required XmlDocument document,
    required List<XmlElement> elements,
  }) {
    BottomWidgetService.updateAyahAndSurahId(
      toUpdateSurahId: suraId,
      toUpdateAyahId: ayaId,
    );
    String? svgUpdatedData;
    if (context.theme.brightness == Brightness.dark) {
      svgUpdatedData = colorAllAya(
        context,
        (0 + (100 - AyahRenderBlocHelper.getDarkThemeTextShade(context)))
            .toDouble(),
        isCustom: isCustomColor,
        document: document,
        elements: elements,
      );
    } else {
      svgUpdatedData = colorAllAya(
        context,
        100,
        isCustom: isCustomColor,
        document: document,
        elements: elements,
      );
    }
    for (final XmlElement element in elements) {
      // Check for the specified attributes and values
      final hasObjectId = element.getAttribute('objectID') != null;
      final isObjectTypeNotAyaMark =
          element.getAttribute('objecttype') != 'otAyaMark';
      final isSora = element.getAttribute('sora') == suraId.toString();
      final isAya = element.getAttribute('aya') == ayaId.toString();
      final lineType = element.getAttribute('class');
      if (lineType != 'soraname' && lineType != 'basmallah') {
        if (isSora && isAya && isObjectTypeNotAyaMark) {
          List<XmlElement> allPathElements =
              element.findAllElements('path').toList();
          final Iterable<XmlElement> pathElements =
              element.findElements('path');
          for (final XmlElement pathElement in allPathElements) {
            pathElement.setAttribute('style', 'fill:#228b22');
            // pathElement.setAttribute(
            //     'style', 'fill:#228b22; text-decoration-line: underline;');
          }
        }
      } else {
        debugPrint('Is SorahName or Is Bismalla: $lineType');
      }
    }
    // Convert the modified XmlDocument back to a string
    return document.toXmlString(pretty: true);
  }

  static List<int> checkAyahHotspots(
    Offset position,
    BuildContext context, {
    bool isFirstPage = true,
  }) {
    int suraId = -1;
    int ayaId = -1;

    final AyahRenderState ayahRenderState =
        BlocProvider.of<AyahRenderBloc>(context).state;
    if (ayahRenderState is AyahRendered) {
      debugPrint("Checking headings");
      List<XmlElement> savedHeadings = [];
      List<XmlElement> pageNumberElements = [];
      for (final XmlElement element in ayahRenderState.elements!) {
        final hasObjectId = element.getAttribute('objectid') != null;
        final hasNoObjectType = element.getAttribute('objecttype') == null;
        final objectId = element.getAttribute('objectid');
        final hasEmptyClass = element.getAttribute('class') == '';
        if (hasObjectId && objectId == "1000") {
          element.attributes.forEach((attribute) {
            debugPrint("Attribute ${attribute.name}: ${attribute.value}");
          });

          pageNumberElements.add(element);
        }
        // Check for heading elements
        else if (hasObjectId && hasNoObjectType && hasEmptyClass) {
          savedHeadings.add(element);
        }
      }
      print('Length Of Saved headings: ${savedHeadings.length}');

      try {
        bool isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        // double screenHeight = MediaQuery.of(context).size.height * 0.60;
        double screenTotalHeight = MediaQuery.of(context).size.height;
        double screenHeight = MediaQuery.of(context).size.height * 0.65;
        if (screenTotalHeight >= 825 && screenTotalHeight < 850) {
          if (position.dy <= (screenHeight * 0.2)) {
            screenHeight = MediaQuery.of(context).size.height * 0.65;
          } else if (position.dy <= (screenHeight * 0.5)) {
            screenHeight = MediaQuery.of(context).size.height * 0.60;
          } else if (position.dy <= (screenHeight * 0.8)) {
            screenHeight = MediaQuery.of(context).size.height * 0.61;
          } else {
            screenHeight = MediaQuery.of(context).size.height * 0.65;
          }
        } else if (screenTotalHeight >= 850 && screenTotalHeight < 875) {
          if (position.dy <= screenHeight / 2) {
            //top half of the page tapped
            screenHeight = MediaQuery.of(context).size.height * 0.65;
          } else {
            screenHeight = MediaQuery.of(context).size.height * 0.71;
          }
        } else if (screenTotalHeight >= 875 && screenTotalHeight < 900) {
          if (position.dy <= (screenHeight * 0.25)) {
            //top half of the page tapped
            screenHeight = MediaQuery.of(context).size.height * 0.64;
          } else {
            screenHeight = MediaQuery.of(context).size.height * 0.65;
          }
        } else if (screenTotalHeight >= 900 && screenTotalHeight < 925) {
          if (position.dy <= (screenHeight * 0.6)) {
            //top half of the page tapped
            screenHeight = MediaQuery.of(context).size.height * 0.64;
          } else {
            screenHeight = MediaQuery.of(context).size.height * 0.65;
          }
        }
        print(
            "Screen Total Height: $screenTotalHeight, Screen Render Box Height: $screenHeight");

        // double screenHeight = MediaQuery.of(context).size.height * 0.64;
        double screenWidth = MediaQuery.of(context).size.width;

        if (isLandscape) {
          screenHeight = MediaQuery.of(context).size.height * 3;
          screenWidth = MediaQuery.of(context).size.width;
        } else {
          if (!(MediaQuery.of(context).size.height < 1090)) {
            screenHeight = MediaQuery.of(context).size.height * 0.9;
            screenWidth = MediaQuery.of(context).size.width;
          }
        }
        ZoomEnum currentZoom = ZoomService().getCurrentZoomEnum(context);
        if (currentZoom == ZoomEnum.medium) {
          if (isLandscape) {
            screenHeight = MediaQuery.of(context).size.height * 3;
            screenWidth = MediaQuery.of(context).size.width * 0.9;
          } else {
            if (((MediaQuery.of(context).size.height < 1090))) {
              screenHeight = MediaQuery.of(context).size.height * 0.75;
              screenWidth = MediaQuery.of(context).size.width * 0.9;
            } else {
              screenHeight = MediaQuery.of(context).size.height;
              screenWidth = MediaQuery.of(context).size.width * 0.9;
            }
          }
        } else if (currentZoom == ZoomEnum.large) {
          if (isLandscape) {
            screenHeight = MediaQuery.of(context).size.height * 3;
            screenWidth = MediaQuery.of(context).size.width * 0.9;
          } else {
            if (((MediaQuery.of(context).size.height < 1090))) {
              // screenHeight = MediaQuery.of(context).size.height * 0.64; Original
              // screenHeight = MediaQuery.of(context).size.height * 0.75; Small Phones
              screenHeight = MediaQuery.of(context).size.height * 0.681;
              screenWidth = MediaQuery.of(context).size.width * 0.9;
            } else {
              screenHeight = MediaQuery.of(context).size.height;
              screenWidth = MediaQuery.of(context).size.width * 0.9;
            }
          }
        } else if (currentZoom == ZoomEnum.extralarge) {
          if (ayahRenderState.pageIndex! < 2) {
            // screenHeight = MediaQuery.of(context).size.height * 0.5; Small Phones
            screenHeight = MediaQuery.of(context).size.height * 0.49;
            screenWidth = MediaQuery.of(context).size.width * 0.9;
          }
        }
        print(
          'Screen width: $screenWidth, Screen height: $screenHeight',
        );
        print(
          'Tap position: $position',
        );
        //Getting SVGWIDTH
        double svgWidth = 1;
        double scale = screenWidth / ayahRenderState.svgWidth!;
        Offset scaledOffset = const Offset(0, 0);
        if (ayahRenderState.originalViewBox!.isNotEmpty) {
          List<String> viewBoxValues =
              ayahRenderState.originalViewBox!.split(' ');
          double viewBoxX = double.parse(viewBoxValues[0]);
          double viewBoxY = double.parse(viewBoxValues[1]);
          double viewBoxWidth = double.parse(viewBoxValues[2]);
          double viewBoxHeight = double.parse(viewBoxValues[3]);

          // Debug output for viewBox values
          print(
            'ViewBox values - X: $viewBoxX, Y: $viewBoxY, Width: $viewBoxWidth, Height: $viewBoxHeight',
          );
          print(screenWidth);
          print(screenHeight);
          // Calculate scaling factors
          double scaleX = screenWidth / viewBoxWidth;
          double scaleY = screenHeight / viewBoxHeight;

          // Translate and scale tap position
          double scaledX = position.dx / scaleX + viewBoxX;
          double scaledY = position.dy / scaleY + viewBoxY;
          scaledOffset = Offset(scaledX, scaledY);

          print('Tap position: $position');
          print(
            'Translated position: $scaledOffset',
          );
          print(
            'Scale factors - X: $scaleX, Y: $scaleY',
          );
        }

        // Check if user tapped on page number FIRST before checking ayahs
        for (var element in pageNumberElements) {
          final String rectData = element.getAttribute('rect') ?? '0,0,0,0';
          final List<double> rectValues = rectData
              .split(',')
              .map((value) => double.tryParse(value) ?? 0.0)
              .toList();

          if (rectValues.length == 4) {
            final Rect rect = Rect.fromLTWH(rectValues[0], rectValues[1],
                rectValues[2] - rectValues[0], rectValues[3] - rectValues[1]);
            print("page number scaledOffset: $scaledOffset");
            print("page number rect: $rect");

            //if extra large zoom

            double proximityThreshold =
                currentZoom == ZoomEnum.extralarge ? 90.0 : 60;

            // Calculate distance from tap to center of rect
            Offset rectCenter = rect.center;
            double distance = (scaledOffset - rectCenter).distance;

            if (distance < proximityThreshold || rect.contains(scaledOffset)) {
              debugPrint("Tapped on/near page number");
              // Get the current page number
              int pageNumber = ayahRenderState.pageIndex! + 1;
              print("page number: $pageNumber");
              return [
                -1,
                -1,
                1,
                pageNumber,
              ]; // Special code for page number with flag
            }
          }
        }

        // Only process ayah tap if not on page number
        try {
          if (ayahRenderState.pageIndex! + 1 == 1 ||
              ayahRenderState.pageIndex! + 1 == 2) {
            for (var element in ayahRenderState.svgElementsList!) {
              if (element.rect.contains(scaledOffset)) {
                suraId = int.parse(element.sora);
                ayaId = int.parse(element.aya);
              }
            }
          } else {
            AyahDetailsWithRect? ayahDetailsWithRect =
                AyahRectService.findAyahByRect(scaledOffset.dx, scaledOffset.dy,
                    ayahRenderState.pageIndex! + 1);
            if (ayahDetailsWithRect != null) {
              suraId = ayahDetailsWithRect.sora;
              ayaId = ayahDetailsWithRect.aya;
              print('Ayah Rect: ${ayahDetailsWithRect.rect}');
            }
          }
          if (suraId == 0 && ayaId == 0) {
            suraId = 0;
            ayaId = 0;
          } else {
            AyahRenderBlocHelper.colorAyaAndUpdateBloc(
              surahNumber: suraId,
              ayahNumber: ayaId,
            );
          }
          if (suraId == -1 && ayaId == -1) {
            //Apply normalization to highlight the text
            Offset nearestCenter = const Offset(0, 0);
            List elementsListToFetchRects = [];
            if (ayahRenderState.pageIndex! + 1 == 1 ||
                ayahRenderState.pageIndex! + 1 == 2) {
              nearestCenter = AyahSvgServiceHelper.getCenter(
                  ayahRenderState.svgElementsList!.first.rect);
              elementsListToFetchRects = ayahRenderState.svgElementsList!;
            } else {
              List<AyahDetailsWithRect> ayahPageDetailsWithRectsList =
                  AyahRectService.findRectsByPage(
                      ayahRenderState.pageIndex! + 1);
              nearestCenter = AyahSvgServiceHelper.getCenter(
                  ayahPageDetailsWithRectsList.first.rect);
              elementsListToFetchRects = ayahPageDetailsWithRectsList;
            }
            double nearestDistance = (scaledOffset - nearestCenter).distance;

            for (var element in elementsListToFetchRects) {
              Offset center = AyahSvgServiceHelper.getCenter(element.rect);
              double distance = (scaledOffset - center).distance;
              if (distance < nearestDistance) {
                nearestCenter = center;
                nearestDistance = distance;
              }
            }

            Offset normalizedOffset = nearestCenter;
            double threshold =
                40.0; // Define a threshold for the nearest distance
            if (nearestDistance > threshold) {
              normalizedOffset = scaledOffset;
            }
            print('Normalized Offset: $normalizedOffset');

            if (ayahRenderState.pageIndex! + 1 == 1 ||
                ayahRenderState.pageIndex! + 1 == 2) {
              for (var element in ayahRenderState.svgElementsList!) {
                if (element.rect.contains(normalizedOffset)) {
                  suraId = int.parse(element.sora);
                  ayaId = int.parse(element.aya);
                }
              }
            } else {
              AyahDetailsWithRect? ayahDetailsWithRect =
                  AyahRectService.findAyahByRect(normalizedOffset.dx,
                      normalizedOffset.dy, ayahRenderState.pageIndex! + 1);

              if (ayahDetailsWithRect != null) {
                suraId = ayahDetailsWithRect.sora;
                ayaId = ayahDetailsWithRect.aya;
                print('Ayah Rect: ${ayahDetailsWithRect.rect}');
              }
            }
            if (suraId == 0 && ayaId == 0) {
              suraId = 0;
              ayaId = 0;
            } else {
              AyahRenderBlocHelper.colorAyaAndUpdateBloc(
                surahNumber: suraId,
                ayahNumber: ayaId,
              );
            }
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return [(suraId == 0) ? -1 : suraId, (ayaId == 0) ? -1 : ayaId, 0];
  }

  static Future<void> colorAyaAndUpdateBloc({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    BuildContext? context = AppContext.getAppContext();
    if (context != null) {
      bool isTwoPage = ResponsiveFrameworkHelper().isTwoPaged();
      if (isTwoPage) {
        final AyahTwoPageRenderState ayahTwoPageRenderState =
            BlocProvider.of<AyahTwoPageRenderBloc>(context).state;
        if (ayahTwoPageRenderState is TwoPageAyahRendered) {
          bool isCustomColor = context.isDarkMode
              ? (ayahTwoPageRenderState.quranTextColor !=
                  QuranDetailsService.defaultQuranDarkThemeTextColor)
              : (ayahTwoPageRenderState.quranTextColor !=
                  QuranDetailsService.defaultQuranTextColor);
          XmlDocument? documentOne;
          XmlDocument? documentTwo;
          (documentOne, documentTwo) =
              AyahRenderBlocHelper.getTwoPagedSvgDocument(context);
          List<XmlElement> elementsToReturnOne = [];
          List<XmlElement> elementsToReturnTwo = [];
          (elementsToReturnOne, elementsToReturnTwo) =
              AyahRenderBlocHelper.getTwoPagedSvgElement(context);
          int firstPageNumber = ayahTwoPageRenderState.firstPageIndex! + 1;
          int secondPageNumber = ayahTwoPageRenderState.secondPageIndex! + 1;
          String svgDataOne = ayahTwoPageRenderState.firstPageSvgData!;
          String svgDataTwo = ayahTwoPageRenderState.secondPageSvgData!;
          for (final ayah in allAyatWithTashkeel) {
            final ayahModel = AyahModel.fromJson(ayah);
            if (ayahModel.page == firstPageNumber &&
                ayahModel.surahNumber == surahNumber &&
                ayahModel.numberInSurah == ayahNumber) {
              if (context.theme.brightness == Brightness.dark) {
                svgDataTwo = colorAllAya(
                  context,
                  (0 +
                          (100 -
                              AyahRenderBlocHelper.getDarkThemeTextShade(
                                  context)))
                      .toDouble(),
                  isCustom: isCustomColor,
                  document: documentTwo!,
                  elements: elementsToReturnTwo,
                );
              } else {
                svgDataTwo = colorAllAya(
                  context,
                  100,
                  isCustom: isCustomColor,
                  document: documentTwo!,
                  elements: elementsToReturnTwo,
                );
              }
              svgDataOne = AyahRenderBlocHelper.colorAya(
                context,
                surahNumber,
                ayahNumber,
                isCustomColor: isCustomColor,
                document: documentOne!,
                elements: elementsToReturnOne,
              );
              // svgDataOne = await AyahSvgServiceHelper.removeHisbSajdaSakta(
              //   svgDataOne,
              //   firstPageNumber,
              // );
            }
            if (ayahModel.page == secondPageNumber &&
                ayahModel.surahNumber == surahNumber &&
                ayahModel.numberInSurah == ayahNumber) {
              if (context.theme.brightness == Brightness.dark) {
                svgDataOne = colorAllAya(
                  context,
                  (0 +
                          (100 -
                              AyahRenderBlocHelper.getDarkThemeTextShade(
                                  context)))
                      .toDouble(),
                  isCustom: isCustomColor,
                  document: documentOne!,
                  elements: elementsToReturnOne,
                );
              } else {
                svgDataOne = colorAllAya(
                  context,
                  100,
                  isCustom: isCustomColor,
                  document: documentOne!,
                  elements: elementsToReturnOne,
                );
              }

              svgDataTwo = AyahRenderBlocHelper.colorAya(
                context,
                surahNumber,
                ayahNumber,
                isCustomColor: isCustomColor,
                document: documentTwo!,
                elements: elementsToReturnTwo,
              );
              // svgDataTwo = await AyahSvgServiceHelper.removeHisbSajdaSakta(
              //   svgDataTwo,
              //   secondPageNumber,
              // );
            }
          }

          AyahRenderBlocHelper.updatePage(
            context,
            isTwoPage: isTwoPage,
            firstPageSvgData: svgDataOne,
            secondPageSvgData: svgDataTwo,
          );
        }
      } else {
        final AyahRenderState ayahRenderState =
            BlocProvider.of<AyahRenderBloc>(context).state;
        if (ayahRenderState is AyahRendered) {
          bool isCustomColor = context.isDarkMode
              ? (ayahRenderState.quranTextColor !=
                  QuranDetailsService.defaultQuranDarkThemeTextColor)
              : (ayahRenderState.quranTextColor !=
                  QuranDetailsService.defaultQuranTextColor);
          String updatedSvgData = ayahRenderState.svgData!;
          int pageNumber = ayahRenderState.pageIndex! + 1;
          updatedSvgData = AyahRenderBlocHelper.colorAya(
            context,
            surahNumber,
            ayahNumber,
            isCustomColor: isCustomColor,
            document: ayahRenderState.document!,
            elements: ayahRenderState.elements!,
          );
          // updatedSvgData = await AyahSvgServiceHelper.removeHisbSajdaSakta(
          //   updatedSvgData,
          //   pageNumber,
          // );
          AyahRenderBlocHelper.updatePage(
            context,
            svgData: updatedSvgData,
          );
        }
      }
    }
  }

  static int getCurrentPageUsingAyahAndSurahId({
    required int surahId,
    required int ayahId,
  }) {
    int pageNumberToReturn = 1;
    BuildContext? context = AppContext.getAppContext();
    if (context != null) {
      int firstPageNumber = AyahRenderBlocHelper.getPageIndex(context) + 1;
      if (ResponsiveFrameworkHelper().isTwoPaged()) {
        int secondPageNumber = firstPageNumber + 1;
        pageNumberToReturn = firstPageNumber;
        for (final ayah in allAyatWithTashkeel) {
          final AyahModel ayahDetails = AyahModel.fromJson(ayah);
          if (ayahDetails.page == firstPageNumber &&
              ayahDetails.surahNumber == surahId &&
              ayahDetails.numberInSurah == ayahId) {
            pageNumberToReturn = firstPageNumber;
          } else if (ayahDetails.page == secondPageNumber &&
              ayahDetails.surahNumber == surahId &&
              ayahDetails.numberInSurah == ayahId) {
            pageNumberToReturn = secondPageNumber;
          }
        }
      } else {
        pageNumberToReturn = firstPageNumber;
      }
    }
    return pageNumberToReturn;
  }
}
