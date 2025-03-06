import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/data_sources/image_size_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/data_sources/moshaf_hisb_sakta_sajda_service.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart';
import 'package:xml/xml.dart';

import '../../../../navigation_service.dart';
import '../../../qeerat/cubit/qeera_cubit.dart';
import '../../presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'moshaf_page_header_data.dart';

class AyahSvgServiceHelper {
  AyahSvgServiceHelper._();

  static String getStringFromColor(Color customColor) {
    return '#${customColor.value.toRadixString(16).substring(2)}';
  }

  //Ornaments Related Funcationality
  static String? getOintmentColorInlineString() {
    String? ointmentThemeString;
    if (getItInstance<NavigationService>().getContext()!.theme.brightness ==
        Brightness.dark) {
      ointmentThemeString = 'fill:#000000;stroke:#ffffff;stroke-width:0.5px;';
    }
    return ointmentThemeString;
  }

  //Zoom Funcationality
  static String zoomFunction(
    BuildContext context,
    String viewBoxData, {
    int zoomPercentage = 28,
    String type = "Center",
  }) {
    String viewBoxNewLength = viewBoxData;
    //Calculate Zoom Factor
    int percentageToShow = 100 - zoomPercentage;
    double zoomFactor = percentageToShow / 100;

    List<String> viewBoxValues = viewBoxData.split(' ');
    double viewBoxOriginalWidth = double.parse(viewBoxValues[2]);
    double viewBoxOriginalHeight = double.parse(viewBoxValues[3]);

    double newWidth = (viewBoxOriginalWidth * zoomFactor) + 80;
    double newHeight = viewBoxOriginalHeight * zoomFactor;

    double horizontalOffset = (viewBoxOriginalWidth - newWidth) / 2;
    double verticalOffset = (viewBoxOriginalHeight - newHeight) / 2;
    double height = MediaQuery.of(context).size.height;
    newHeight = newHeight + (height * 0.25);
    newHeight = newHeight - 40;
    verticalOffset = ZoomService().getZoomOffsetAccordingToZoomPercentage(
      context,
      verticalOffset,
    );
    if (type == 'Left') {
      //Left Aligned SVGs
      // horizontalOffset = horizontalOffset - 20;
      viewBoxNewLength =
          "$horizontalOffset $verticalOffset $newWidth $newHeight";
    } else if (type == 'Right') {
      //Right Aligned SVGs
      // horizontalOffset = horizontalOffset + 20;
      viewBoxNewLength =
          "$horizontalOffset $verticalOffset $newWidth $newHeight";
    } else {
      //Center
      viewBoxNewLength =
          "$horizontalOffset $verticalOffset $newWidth $newHeight";
    }
    // odd on the left
    // Even on the right
    // Except for first two
    // Original viewBox="0 0 382.6767883 547.0863647"
    // zoom Left Sized 10% viewBox="-09.1334 27.3543 344.4091 492.3777"
    // For Left Sized 25% viewBox="28.0846 68.3857 286.5076 410.3150"

    // Original viewBox="0 0 382.6767883 547.0863647"
    // zoom 10% viewBox="19.1334 27.3543 344.4091 492.3777"
    // zoom 25% viewBox="48.0846 68.3857 286.5076 410.3150"
    // zoom 50% viewBox="95.1692 136.7716 191.3384 273.5432"

    // Original viewBox="0 0 382.6767883 547.0863647"
    // zoom Right Sized 10% viewBox="39.1334 27.3543 344.4091 492.3777"
    // For Right Sized 25% viewBox="68.0846 68.3857 286.5076 410.3150"
    return viewBoxNewLength;
  }

  //Svg Theme Funcationality
  static String adjustSvgForTheme(String svgString, bool isDarkMode) {
    final document = XmlDocument.parse(svgString);

    // Find the style element
    final styleElement = document.findAllElements('style').first;
    var styleContent = styleElement.innerText;

    // Modify the style content based on the theme
    if (isDarkMode) {
      styleContent = styleContent
          .replaceAll(
              '.quran-text {fill: #000000;}', '.quran-text {fill: #ffffff;}')
          .replaceAll(
              '.aya-dark {fill:none;stroke:#000000;stroke-width:0.5px;}',
              '.aya-dark {fill:none;stroke:#ffffff;stroke-width:0.5px;}')
          .replaceAll('.day {} .night {display:none;}',
              '.day {display:none;} .night {}');
    } else {
      styleContent = styleContent
          .replaceAll(
              '.quran-text {fill: #ffffff;}', '.quran-text {fill: #000000;}')
          .replaceAll(
              '.aya-dark {fill:none;stroke:#ffffff;stroke-width:0.5px;}',
              '.aya-dark {fill:none;stroke:#000000;stroke-width:0.5px;}')
          .replaceAll('.day {display:none;} .night {}',
              '.day {} .night {display:none;}');
    }

    // Set the modified style content
    styleElement.innerText = styleContent;

    return document.toXmlString(pretty: true);
  }

  static String valueToColorHex(double value) {
    // Ensure the value is clamped between 0 and 100 to avoid out-of-range errors.
    value = value.clamp(0, 100);
    // Map the value from 0-100 to 255-0 (255 is white, 0 is black in grayscale)
    int grayScale = 255 - ((value / 100) * 255).round();
    // Convert the grayscale value to a hex string and format it as a color hex code
    String hexColor = grayScale.toRadixString(16).padLeft(2, '0');
    return '#$hexColor$hexColor$hexColor';
  }

  static Future<String> addPageHeader({
    required String svgString,
    required int pageNumber,
    required int zoomPercentage,
  }) async {
    final document = XmlDocument.parse(svgString);
    ByteData bytes = await rootBundle.load('assets/imgs/sora-frame.png');
    String base64Image = base64Encode(Uint8List.view(bytes.buffer));
    MoshafPageHeaderService moshafPageHeaderService = MoshafPageHeaderService();
    moshafPageHeaderService.init();

    String borderStr;
    List<PageHeader>? currentPageHeaders =
        moshafPageHeaderService.pageMap[pageNumber];
    if (currentPageHeaders != null) {
      for (final header in currentPageHeaders) {
        if (ZoomService().isBorderEnable(zoomPercentage)) {
          borderStr =
              '<image preserveAspectRatio="none" x="${header.x}" y="${header.y}" width="${header.width}" height="${header.height}" class="day" href="data:image/png;base64,$base64Image" />';
        } else {
          double x = 0, y = 0;
          (x, y) = AyahSvgServiceHelper.fetchNormalizedXY(svgString);
          bool isEven = pageNumber % 2 == 0;
          //Here we will check if there is hisb
          if (MoshafHisbSaktaSajdaService().isPageBeingAligned(pageNumber)) {
            print('Page_is_aligned ${isEven ? "Even " : "Odd "}: $pageNumber');
            if (isEven) {
              x = x - 13.9;
            } else {
              x = x - 12.7;
            }
          } else {
            print(
                'No Page_is_aligned ${isEven ? "Even " : "Odd "}: $pageNumber');

            x = x - 12.5;
          }

          borderStr =
              '<image preserveAspectRatio="none" x="${header.x - (x - 5.5)}" y="${header.y - y}" width="${header.width - 10}" height="${header.height}" class="day" href="data:image/png;base64,$base64Image" />';
        }
        try {
          XmlElement? imageElement = XmlDocument.parse(borderStr).rootElement;
          imageElement.parent?.children.remove(imageElement);

          late XmlElement? svgElement;
          svgElement = document.findAllElements('svg').firstOrNull;
          if (!svgElement!.children.contains(imageElement)) {
            svgElement.children.add(imageElement);
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }

    return document.toXmlString();
  }

  static Future<String> addSmallHisbSajdaSakta({
    required String svgString,
    required int pageNumber,
    required int zoomPercentage,
  }) async {
    final document = XmlDocument.parse(svgString);
    //Remove this condition if want Hisb on all the pages
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null && (ZoomService().isBorderEnable(zoomPercentage))) {
      MoshafHisbSaktaSajdaService moshafHisbSaktaSajdaService =
          MoshafHisbSaktaSajdaService();
      moshafHisbSaktaSajdaService.init();

      String imageStr;
      List<PageHisbSaktaSajda>? currentPageHisbSaktaSajda =
          moshafHisbSaktaSajdaService.pageMap[pageNumber];

      // Get the screen width and height

      // Calculate the center coordinates

      if (currentPageHisbSaktaSajda != null) {
        int index = 1;

        for (final pageHisbSaktaSajda in currentPageHisbSaktaSajda) {
          print(pageHisbSaktaSajda.fileName);
          try {
            ByteData bytes = await rootBundle
                .load('assets/border_hisb/${pageHisbSaktaSajda.fileName}');
            String base64Image = base64Encode(Uint8List.view(bytes.buffer));
            final Size logicalSize = moshafHisbSaktaSajdaService.getMaskSize(
                pageHisbSaktaSajda.pageNumber, pageHisbSaktaSajda.fileName);

            // final Size logicalSize = await getPngLogicalSize(
            //     'assets/border_hisb/${pageHisbSaktaSajda.fileName}');

            print(
                'OrignWidth: ${logicalSize.width}, Height: ${logicalSize.height}');

            double imageWidth = logicalSize.width;
            double imageHeight = logicalSize.height;

            imageStr = moshafHisbSaktaSajdaService.getSmallImageString(
              imageWidth: imageWidth,
              imageHeight: imageHeight,
              base64Image: base64Image,
              x: pageHisbSaktaSajda.x,
              y: pageHisbSaktaSajda.y,
            );
            XmlElement? imageElement = XmlDocument.parse(imageStr).rootElement;
            imageElement.parent?.children.remove(imageElement);

            late XmlElement? svgElement;
            svgElement = document.findAllElements('svg').firstOrNull;
            if (!svgElement!.children.contains(imageElement)) {
              svgElement.children.add(imageElement);
            }
          } catch (e) {
            debugPrint(e.toString());
          }
          index = index + 1;
        }
      }
    }
    return document.toXmlString();
  }

  static Future<String> addHisbSajdaSakta({
    required String svgString,
    required int pageNumber,
    required int zoomPercentage,
  }) async {
    final document = XmlDocument.parse(svgString);
    //Remove this condition if want Hisb on all the pages
    if (!ZoomService().isBorderEnable(zoomPercentage)) {
      MoshafHisbSaktaSajdaService moshafHisbSaktaSajdaService =
          MoshafHisbSaktaSajdaService();
      moshafHisbSaktaSajdaService.init();

      String imageStr, maskImageString;
      List<PageHisbSaktaSajda>? currentPageHisbSaktaSajda =
          moshafHisbSaktaSajdaService.pageMap[pageNumber];

      // Get the screen width and height

      double imageWidth = 70, imageHeight = 320;
      // Calculate the center coordinates

      if (currentPageHisbSaktaSajda != null) {
        int index = 1;
        for (final pageHisbSaktaSajda in currentPageHisbSaktaSajda) {
          print('PageHisbSaktaSajda: ${pageHisbSaktaSajda.fileName}');
          print('Page number : $pageNumber');

          ByteData bytes = await rootBundle
              .load('assets/hisb_icons/${pageHisbSaktaSajda.fileName}');
          String base64Image = base64Encode(Uint8List.view(bytes.buffer));

          String? maskList;
          if (pageHisbSaktaSajda.fileName.contains('sakta')) {
            maskList = moshafHisbSaktaSajdaService.longMaskListName;
          } else if (pageHisbSaktaSajda.fileName.contains('sajda')) {
            maskList = moshafHisbSaktaSajdaService.shortSajdaListName;
          }
          String? mask = moshafHisbSaktaSajdaService.getMask(
            pageNumber,
            isDark: AppContext.getAppContext()!.isDarkMode,
            listName: maskList,
          );
          if (mask != null) {
            print("Mask: $mask");
            ByteData maskBytes =
                await rootBundle.load('assets/hisb_icons/$mask');
            String maskBase64Image =
                base64Encode(Uint8List.view(maskBytes.buffer));
            double maskHeight = imageHeight;
            double maskWidth = imageHeight;
            bool isLongMask = false;
            bool isSajdaMask = false;
            if (moshafHisbSaktaSajdaService.longMaskList.contains(pageNumber)) {
              // maskWidth = imageWidth + 20;
              // maskHeight = imageHeight + 20;
              maskWidth = imageWidth + 35;
              maskHeight = imageHeight + 30;
              isLongMask = true;
            } else if (moshafHisbSaktaSajdaService.shortSajdaList
                .contains(pageNumber)) {
              // maskWidth = imageWidth + 45;
              // maskHeight = imageHeight + 50;
              maskWidth = imageWidth + 20;
              maskHeight = imageHeight + 30;
              isSajdaMask = true;
            } else {
              maskWidth = imageWidth + 20;
              maskHeight = imageHeight + 30;
            }

            try {
              maskImageString = moshafHisbSaktaSajdaService.getImageString(
                pageNumber: pageNumber,
                zoomPercentage: zoomPercentage,
                svgString: svgString,
                imageWidth: maskWidth,
                imageHeight: maskHeight,
                base64Image: maskBase64Image,
                currentIndex: index,
                totalImagesToRender: currentPageHisbSaktaSajda.length,
                isMask: true,
                isLongMask: isLongMask,
                isSajdaMask: isSajdaMask,
              );

              XmlElement? maskImageElement =
                  XmlDocument.parse(maskImageString).rootElement;
              maskImageElement.parent?.children.remove(maskImageElement);

              late XmlElement? maskSvgElement;
              maskSvgElement = document.findAllElements('svg').firstOrNull;
              if (!maskSvgElement!.children.contains(maskImageElement)) {
                maskSvgElement.children.add(maskImageElement);
              }

              imageStr = moshafHisbSaktaSajdaService.getImageString(
                pageNumber: pageNumber,
                zoomPercentage: zoomPercentage,
                svgString: svgString,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                base64Image: base64Image,
                currentIndex: index,
                totalImagesToRender: currentPageHisbSaktaSajda.length,
              );
              XmlElement? imageElement =
                  XmlDocument.parse(imageStr).rootElement;
              imageElement.parent?.children.remove(imageElement);

              late XmlElement? svgElement;
              svgElement = document.findAllElements('svg').firstOrNull;
              if (!svgElement!.children.contains(imageElement)) {
                svgElement.children.add(imageElement);
              }
            } catch (e) {
              debugPrint(e.toString());
            }
            index = index + 1;
            return document.toXmlString();
          } else {
            print('Mask is null');

            return svgString;
          }
        }
      }
    }
    return svgString;
  }

  static Future<String> removeHisbSajdaSakta(
    String svgString,
    int pageNumber,
  ) async {
    final document = XmlDocument.parse(svgString);

    // Define scaling factors (same as in addHisbWithoutSajdaSakta)
    double hisbScaleFactor = 0.90;
    double maskScaleFactor = 0.88; // Slightly smaller mask

    ZoomService zoomService = ZoomService();
    int zoomPercentage = zoomService.zoomPercentage[
        zoomService.getCurrentZoomEnum(AppContext.getAppContext()!)]!;

    if (!zoomService.isBorderEnable(zoomPercentage)) {
      MoshafHisbSaktaSajdaService moshafHisbSaktaSajdaService =
          MoshafHisbSaktaSajdaService();
      moshafHisbSaktaSajdaService.init();

      try {
        List<PageHisbSaktaSajda>? currentPageHisbSaktaSajda =
            moshafHisbSaktaSajdaService.pageMap[pageNumber];

        if (currentPageHisbSaktaSajda != null) {
          for (final pageHisbSaktaSajda in currentPageHisbSaktaSajda) {
            // Get the actual Hisb image size
            final hizbSize = await getPngActualSize(
                'assets/hisb_icons/${pageHisbSaktaSajda.fileName}');
            double imageWidth = hizbSize.width * hisbScaleFactor;
            double imageHeight = hizbSize.height * hisbScaleFactor;

            print(
                '🔹 Removing Hisb: ${pageHisbSaktaSajda.fileName} (Scaled to -> Width: $imageWidth, Height: $imageHeight)');

            // Load the Hisb image and convert to base64
            ByteData bytes = await rootBundle
                .load('assets/hisb_icons/${pageHisbSaktaSajda.fileName}');
            String base64Image = base64Encode(Uint8List.view(bytes.buffer));

            // Remove the Hisb image
            final imageElement = document.findAllElements('image').firstWhere(
              (element) {
                final href = element.getAttribute('href');
                final width =
                    double.tryParse(element.getAttribute('width') ?? '0') ?? 0;
                final height =
                    double.tryParse(element.getAttribute('height') ?? '0') ?? 0;

                return href == 'data:image/png;base64,$base64Image' &&
                    (width - imageWidth).abs() < 1.0 &&
                    (height - imageHeight).abs() < 1.0;
              },
              orElse: () => XmlElement(XmlName('dummy')),
            );

            if (imageElement.name.local != 'dummy') {
              print('✅ Removing Hisb Image: ${pageHisbSaktaSajda.fileName}');
              imageElement.parent?.children.remove(imageElement);
            } else {
              print('⚠️ Hisb Image Not Found: ${pageHisbSaktaSajda.fileName}');
            }

            // Handle mask removal
            String? maskList;
            if (pageHisbSaktaSajda.fileName.contains('sakta')) {
              maskList = moshafHisbSaktaSajdaService.longMaskListName;
            } else if (pageHisbSaktaSajda.fileName.contains('sajda')) {
              maskList = moshafHisbSaktaSajdaService.shortSajdaListName;
            }

            String? maskFile = moshafHisbSaktaSajdaService.getMask(
              pageNumber,
              isDark: AppContext.getAppContext()!.isDarkMode,
              listName: maskList,
            );

            if (maskFile != null) {
              // Get the actual mask size
              final maskSize =
                  await getPngActualSize('assets/hisb_icons/$maskFile');
              double maskWidth = maskSize.width * maskScaleFactor;
              double maskHeight = maskSize.height * maskScaleFactor;

              print(
                  '🔹 Removing Mask: $maskFile (Scaled to -> Width: $maskWidth, Height: $maskHeight)');

              ByteData maskBytes =
                  await rootBundle.load('assets/hisb_icons/$maskFile');
              String maskBase64Image =
                  base64Encode(Uint8List.view(maskBytes.buffer));

              // Remove the mask image
              final maskImageElement =
                  document.findAllElements('image').firstWhere(
                (element) {
                  final href = element.getAttribute('href');
                  final width =
                      double.tryParse(element.getAttribute('width') ?? '0') ??
                          0;
                  final height =
                      double.tryParse(element.getAttribute('height') ?? '0') ??
                          0;

                  return href == 'data:image/png;base64,$maskBase64Image' &&
                      (width - maskWidth).abs() < 1.0 &&
                      (height - maskHeight).abs() < 1.0;
                },
                orElse: () => XmlElement(XmlName('dummy')),
              );

              if (maskImageElement.name.local != 'dummy') {
                print('✅ Removing Mask Image: $maskFile');
                maskImageElement.parent?.children.remove(maskImageElement);
              } else {
                print('⚠️ Mask Image Not Found: $maskFile');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Error removing Hisb: $e');
      }
    }

    return document.toXmlString();
  }

  static Future<String> addSvgBorder({
    required String svgString,
    required int pageNumber,
  }) async {
    final document = XmlDocument.parse(svgString);
    ByteData bytes;
    if (pageNumber < 3) {
      bytes = await rootBundle.load('assets/imgs/first_second_border.png');
    } else {
      bytes = await rootBundle.load('assets/imgs/border.png');
    }
    String base64Image = base64Encode(Uint8List.view(bytes.buffer));
    String alignment = getPageAlignment(pageNumber);
    String borderStr;
    if (alignment == 'Left') {
      borderStr =
          '<image preserveAspectRatio="none" x="12.00" y="34.16" width="310.91" height="473.05" class="day" href="data:image/png;base64,$base64Image" />';
    } else if (alignment == 'Right') {
      borderStr =
          '<image preserveAspectRatio="none"  objectid="0" x="58.28" y="34.16" width="310.91" height="473.05" class="day" href="data:image/png;base64,$base64Image" />';
    } else {
      // alignment == 'Center'
      if (pageNumber < 3) {
        borderStr =
            '<image preserveAspectRatio="none"  objectid="0" x="2.14" y="-20.0" width="380.092" height="580.66" class="day" href="data:image/png;base64,$base64Image" />';
      } else {
        borderStr =
            '<image preserveAspectRatio="none"  objectid="0" x="35.14" y="34.16" width="310.91" height="473.05" class="day" href="data:image/png;base64,$base64Image" />';
      }
    }
    XmlElement? imageElement = XmlDocument.parse(borderStr).rootElement;
    imageElement.parent?.children.remove(imageElement);

    late XmlElement? svgElement;
    svgElement = document.findAllElements('svg').firstOrNull;
    if (!svgElement!.children.contains(imageElement)) {
      svgElement.children.add(imageElement);
    }

    return document.toXmlString();
  }

  static Rect parseRectFromString(String rectString) {
    // Split the string by spaces to get each part of the rect
    List<String> rectParts = rectString.split(',');

    // Parse the values as doubles
    double left = double.parse(rectParts[0]);
    double top = double.parse(rectParts[1]);
    double right = double.parse(rectParts[2]);
    double bottom = double.parse(rectParts[3]);

    // Create and return the Rect object
    return Rect.fromLTRB(left, top, right, bottom);
  }

  static Rect getElementRect(XmlElement element) {
    final isPathClassLight1 = element.getAttribute('rect');
    // Split the string by spaces to get each part of the rect
    List<String> rectParts = isPathClassLight1!.split(',');

    // Parse the values as doubles
    double left = double.parse(rectParts[0]);
    double top = double.parse(rectParts[1]);
    double right = double.parse(rectParts[2]);
    double bottom = double.parse(rectParts[3]);

    // Create and return the Rect object
    return Rect.fromLTRB(left, top, right, bottom);
  }

  // Qeerat Style Update
  static String updateQeeratStyles({
    required String svgString,
  }) {
    final document = XmlDocument.parse(svgString);
    final BuildContext? currentContext = AppContext.getAppContext();
    if (currentContext != null) {
      final qaraaList = currentContext.read<QeraatCubit>().state;

      // Iterate over each element with the 'qeraat' class
      final elementsWithClassQeraat = document
          .findAllElements('svg')
          .firstOrNull
          ?.descendants
          .whereType<XmlElement>()
          .where((element) {
        final classAttribute = element.getAttribute('class');
        return classAttribute != null &&
            classAttribute.split(' ').contains('qeraat');
      }).toList();

      if (elementsWithClassQeraat != null &&
          elementsWithClassQeraat.isNotEmpty) {
        for (var element in elementsWithClassQeraat) {
          final classAttribute = element.getAttribute('class');
          for (var qaraa in qaraaList) {
            if ((classAttribute?.split(' ').contains(qaraa.imam1.id) ??
                    false) &&
                qaraa.imam1.isEnabled) {
              element.setAttribute("style", "stroke: red; stroke-width: 1;");
            } else if ((classAttribute?.split(' ').contains(qaraa.imam2.id) ??
                    false) &&
                qaraa.imam2.isEnabled) {
              element.setAttribute("style", "stroke: red; stroke-width: 1;");
            }
          }
        }
      }
    }
    return document.toXmlString();
  }

  //Remove border and max zoom
  static Future<String> removeBorderAndMaxZoom({
    required String svgString,
    required int pageNumber,
    required int zoomPercentage,
  }) async {
    final document = XmlDocument.parse(svgString);
    final svgElement = document.findAllElements('svg').firstOrNull;
    if (svgElement == null) {
      return svgString;
    }

    final String? viewBox = svgElement.getAttribute('viewBox');
    if (viewBox == null) {
      return svgString;
    }

    List<String> rectParts = viewBox.split(' ');
    double.parse(rectParts[2]);
    double.parse(rectParts[3]);
    late XmlElement? pageInnerElement;
    late XmlElement? pageOuterElement;

    try {
      pageInnerElement = svgElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('class') == 'page-inner',
          );
    } catch (e) {
      pageInnerElement = null;
    }

    if (pageInnerElement == null) {
      return svgString;
    }

    String? rectstr = pageInnerElement.getAttribute('rect');
    if (rectstr == null) {
      return svgString;
    }
    Rect pageInnerRect = parseRectFromString(rectstr);

    try {
      pageOuterElement = svgElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('class') == 'page-outer',
          );
    } catch (e) {
      pageOuterElement = null;
    }

    if (pageOuterElement == null) {
      return svgString;
    }

    late XmlElement? SoraNameElement;
    late XmlElement? SoraNameElementZoomed;
    late XmlElement? JozaaNameElement;
    late XmlElement? JozaaNameElementZoomed;
    late XmlElement? PageNumberElement;
    late XmlElement? PageNumberElementZoomed;

    late Rect SoraNameElementZoomedRect;
    late Rect JozaaNameElementZoomedRect;
    late Rect PageNumberElementZoomedRect;

    try {
      SoraNameElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1005',
          );
    } catch (e) {
      SoraNameElement = null;
    }

    if (SoraNameElement == null) {
      return svgString;
    }

    try {
      JozaaNameElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1004',
          );
    } catch (e) {
      JozaaNameElement = null;
    }

    if (JozaaNameElement == null) {
      return svgString;
    }

    try {
      PageNumberElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1000',
          );
    } catch (e) {
      PageNumberElement = null;
    }
    if (PageNumberElement == null) {
      return svgString;
    }

    SoraNameElementZoomed = SoraNameElement.copy();
    JozaaNameElementZoomed = JozaaNameElement.copy();
    PageNumberElementZoomed = PageNumberElement.copy();

    SoraNameElementZoomedRect = getElementRect(SoraNameElementZoomed);
    double x = pageInnerRect.left - SoraNameElementZoomedRect.left;
    double y = pageInnerRect.top -
        SoraNameElementZoomedRect.bottom -
        14.0; //14.0 is vertical space I added
    SoraNameElementZoomed.setAttribute("transform", "translate($x, $y)");

    JozaaNameElementZoomedRect = getElementRect(JozaaNameElementZoomed);
    x = pageInnerRect.right - JozaaNameElementZoomedRect.right;
    y = pageInnerRect.top -
        JozaaNameElementZoomedRect.bottom -
        14.0; //14.0 is vertical space I added
    JozaaNameElementZoomed.setAttribute("transform", "translate($x, $y)");

    PageNumberElementZoomedRect = getElementRect(PageNumberElementZoomed);
    x = 0;
    y = pageInnerRect.bottom -
        PageNumberElementZoomedRect.bottom +
        20; //14.0 is vertical space I added
    PageNumberElementZoomed.setAttribute("transform", "translate($x, $y)");

    if (svgElement.children.contains(pageOuterElement)) {
      svgElement.children.remove(pageOuterElement);
    }
    if (!pageInnerElement.children.contains(SoraNameElementZoomed)) {
      pageInnerElement.children.add(SoraNameElementZoomed);
    }
    if (!pageInnerElement.children.contains(JozaaNameElementZoomed)) {
      pageInnerElement.children.add(JozaaNameElementZoomed);
    }
    if (!pageInnerElement.children.contains(PageNumberElementZoomed)) {
      pageInnerElement.children.add(PageNumberElementZoomed);
    }
    double h = max(
        JozaaNameElementZoomedRect.bottom - JozaaNameElementZoomedRect.top,
        SoraNameElementZoomedRect.bottom - SoraNameElementZoomedRect.top);
    x = pageInnerRect.right - pageInnerRect.left;
    y = pageInnerRect.bottom - pageInnerRect.top + h + 14.0 + 20;

    x = x + 25;
    y = y + 25;

    svgElement.setAttribute('viewBox', "0 0 $x $y");

    x = pageInnerRect.left;
    y = pageInnerRect.top -
        max(JozaaNameElementZoomedRect.bottom,
            SoraNameElementZoomedRect.bottom);

    x = x - 12;
    pageInnerElement.setAttribute("transform", "translate(-$x, -$y)");
    return document.toXmlString();
  }

  //Remove default Hisb Icon
  static Future<String> removeDefaultHisbIcon({
    required String svgString,
    required int pageNumber,
  }) async {
    final document = XmlDocument.parse(svgString);
    final svgElement = document.findAllElements('svg').firstOrNull;
    if (svgElement == null) {
      return svgString;
    }

    final String? viewBox = svgElement.getAttribute('viewBox');
    if (viewBox == null) {
      return svgString;
    }

    late XmlElement? pageInnerElement;
    late XmlElement? pageOuterElement;

    try {
      pageInnerElement = svgElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('class') == 'page-inner',
          );
    } catch (e) {
      pageInnerElement = null;
    }

    if (pageInnerElement == null) {
      return svgString;
    }

    String? rectstr = pageInnerElement.getAttribute('rect');
    if (rectstr == null) {
      return svgString;
    }

    try {
      pageOuterElement = svgElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('class') == 'page-outer',
          );
    } catch (e) {
      pageOuterElement = null;
    }

    if (pageOuterElement == null) {
      return svgString;
    }

    late XmlElement? SoraNameElement;

    late XmlElement? JozaaNameElement;

    late XmlElement? PageNumberElement;

    late XmlElement? HisbIconElement;

    try {
      SoraNameElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1005',
          );
    } catch (e) {
      SoraNameElement = null;
    }

    if (SoraNameElement == null) {
      return svgString;
    }

    try {
      JozaaNameElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1004',
          );
    } catch (e) {
      JozaaNameElement = null;
    }

    if (JozaaNameElement == null) {
      return svgString;
    }

    try {
      PageNumberElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1000',
          );
    } catch (e) {
      PageNumberElement = null;
    }
    if (PageNumberElement == null) {
      return svgString;
    }

    try {
      HisbIconElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1001',
          );

      if (pageOuterElement.children.contains(HisbIconElement)) {
        pageOuterElement.children.remove(HisbIconElement);
      }
    } catch (e) {
      HisbIconElement = null;
      print("HisbIconElement is null: $e");
    }

    return document.toXmlString();
  }

  static (double, double) fetchNormalizedXY(
    String svgString,
  ) {
    final document = XmlDocument.parse(svgString);
    final svgElement = document.findAllElements('svg').firstOrNull;
    if (svgElement == null) {
      return (0, 0);
    }

    final String? viewBox = svgElement.getAttribute('viewBox');
    if (viewBox == null) {
      return (0, 0);
    }

    List<String> rectParts = viewBox.split(' ');
    double.parse(rectParts[2]);
    double.parse(rectParts[3]);
    late XmlElement? pageInnerElement;
    late XmlElement? pageOuterElement;

    try {
      pageInnerElement = svgElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('class') == 'page-inner',
          );
    } catch (e) {
      pageInnerElement = null;
    }

    if (pageInnerElement == null) {
      return (0, 0);
    }

    String? rectstr = pageInnerElement.getAttribute('rect');
    if (rectstr == null) {
      return (0, 0);
    }
    Rect pageInnerRect = parseRectFromString(rectstr);

    try {
      pageOuterElement = svgElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('class') == 'page-outer',
          );
    } catch (e) {
      pageOuterElement = null;
    }

    if (pageOuterElement == null) {
      return (0, 0);
    }

    late XmlElement? SoraNameElement;
    late XmlElement? SoraNameElementZoomed;
    late XmlElement? JozaaNameElement;
    late XmlElement? JozaaNameElementZoomed;

    late Rect SoraNameElementZoomedRect;
    late Rect JozaaNameElementZoomedRect;
    try {
      SoraNameElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1005',
          );
    } catch (e) {
      SoraNameElement = null;
    }

    if (SoraNameElement == null) {
      return (0, 0);
    }

    try {
      JozaaNameElement = pageOuterElement.findAllElements('g').firstWhere(
            (element) => element.getAttribute('objectid') == '1004',
          );
    } catch (e) {
      JozaaNameElement = null;
    }

    if (JozaaNameElement == null) {
      return (0, 0);
    }

    SoraNameElementZoomed = SoraNameElement.copy();
    JozaaNameElementZoomed = JozaaNameElement.copy();

    SoraNameElementZoomedRect = getElementRect(SoraNameElementZoomed);
    double x = pageInnerRect.left - SoraNameElementZoomedRect.left;
    double y = pageInnerRect.top -
        SoraNameElementZoomedRect.bottom -
        14.0; //14.0 is vertical space I added
    SoraNameElementZoomed.setAttribute("transform", "translate($x, $y)");

    JozaaNameElementZoomedRect = getElementRect(JozaaNameElementZoomed);
    x = pageInnerRect.right - JozaaNameElementZoomedRect.right;
    y = pageInnerRect.top -
        JozaaNameElementZoomedRect.bottom -
        14.0; //14.0 is vertical space I added
    JozaaNameElementZoomed.setAttribute("transform", "translate($x, $y)");

    svgElement.setAttribute('viewBox', "0 0 $x $y");
    x = pageInnerRect.left;
    y = pageInnerRect.top -
        max(JozaaNameElementZoomedRect.bottom,
            SoraNameElementZoomedRect.bottom);
    return (x, y);
  }

  //Svg Management Functionality
  static String removePathByClass(String svgString, String className) {
    final document = XmlDocument.parse(svgString);
    final elementsToRemove = document.findAllElements('path').where((element) {
      return element.getAttribute('class')?.contains(className) ?? false;
    }).toList();

    for (var element in elementsToRemove) {
      element.parent?.children.remove(element);
    }

    return document.toXmlString();
  }

  static String getPageAlignment(int pageNumber) {
    String alignment = "Center";
    if (pageNumber == 1 || pageNumber == 2) {
      alignment = "Center";
    } else if (pageNumber % 2 != 0) {
      alignment = "Left";
    } else if (pageNumber % 2 == 0) {
      alignment = "Right";
    }
    return alignment;
  }

  static Offset getCenter(Rect rect) {
    return Offset((rect.left + rect.right) / 2, (rect.top + rect.bottom) / 2);
  }
}
