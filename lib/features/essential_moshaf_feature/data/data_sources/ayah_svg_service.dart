import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/play_asset_delivery.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/svg_element.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/quran_details_cubit/quran_details_service.dart';
import 'package:xml/xml.dart';

import '../../presentation/cubit/essential_moshaf_cubit.dart';
import '../../presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'ayah_svg_service_helper.dart';

class AyahSvgService {
  static late String svgData;
  static Future<List<SvgElement>>? svgElementsFuture;
  static late double SVGwidth;
  static late double SVGheight;
  static late List<XmlElement> elements;
  static late XmlDocument document;
  // static late XmlDocument XmlElement?document;
  static late List<SvgElement> SVGgElements;
  static late String currentPage;
  static late VoidCallback savedAfterExecutionFunction;
  static late BuildContext layoutContext;
  static late Color quranTextColor;
  static late int darkThemeTextShade;
  static late String originalViewBox;

  static void init(
    BuildContext context,
    String svgNumber, {
    VoidCallback? afterExecutionFunction,
    int zoomPercentage = 28,
  }) async {
    currentPage = svgNumber;

    svgData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
      '$svgNumber.svg',
    );
    // String assetPath =
    //     await PlayAssetDelivery.getAssetPackPath("app_asset_pack") ?? '';
    // svgData = await rootBundle.loadString(
    //   'assets/ayah_svg/$svgNumber.svg',
    // );
    // svgElement = document.findAllElements('svg').firstOrNull;

    if (context.theme.brightness != Brightness.dark) {
      svgData =
          AyahSvgServiceHelper.removePathByClass(svgData, 'aya-dark night');
    } else {
      svgData =
          AyahSvgServiceHelper.removePathByClass(svgData, 'aya-light-2 day');
      svgData =
          AyahSvgServiceHelper.removePathByClass(svgData, 'aya-light-1 day');
    }
    svgData = AyahSvgServiceHelper.adjustSvgForTheme(
        svgData, context.theme.brightness == Brightness.dark);

    svgData = adjustSvgForFontSize(
      context,
      svgString: svgData,
      pageNumber: int.parse(svgNumber),
      zoomPercentage: zoomPercentage,
    );

    // svgData = await AyahSvgServiceHelper.addSvgBorder(
    //   svgString: svgData,
    //   pageNumber: int.parse(svgNumber),
    // );

    bool isCustomColor = false;
    if (quranTextColor != QuranDetailsService.defaultQuranTextColor) {
      isCustomColor = true;
    }
    svgElementsFuture = loadSVGAndExtractData(
      context,
      svgData,
      isCustomColor: isCustomColor,
    );
    // AyahSvgService.colorAllAyaCustom(
    //   context,
    //   customColor: AyahSvgService.quranTextColor,
    // );
    if (afterExecutionFunction != null) {
      savedAfterExecutionFunction = afterExecutionFunction;

      afterExecutionFunction();
    }
  }

  //View Box Functionality
  static Future<void> fetchViewBox(
      BuildContext context, String svgNumber) async {
    String? originalViewString = await AyahSvgService.getSvgViewBox(
      context,
      svgNumber,
    );

    if (originalViewString != null) {
      AyahSvgService.originalViewBox = originalViewString;
    }
  }

  static void initWithZoom(
    BuildContext context, {
    required int zoomPercentage,
  }) {
    init(
      context,
      currentPage,
      zoomPercentage: zoomPercentage,
      afterExecutionFunction: () {
        ZoomService zoomService = ZoomService();
        zoomService.updateZoom(
          context,
          zoom: zoomService.getZoomEnumFromPercentage(
            zoomPercentage,
          ),
        );
      },
    );
  }

  static Future<List<SvgElement>> loadSVGAndExtractData(
    BuildContext context,
    String svgData, {
    bool isCustomColor = false,
  }) async {
    document = XmlDocument.parse(svgData);
    elements = document
        .findAllElements('g')
        .where((element) => element.getAttribute('objectid') != null)
        .toList();
    if (context.theme.brightness == Brightness.dark) {
      _hideShowAyaMarkNight(true);
      _hideShowAyaMarkLight(false);
      _colorAllAya(
        (0 + (100 - darkThemeTextShade)).toDouble(),
        isCustom: isCustomColor,
      );
    } else {
      _hideShowAyaMarkNight(false);
      _hideShowAyaMarkLight(true);
      _colorAllAya(
        100,
        isCustom: isCustomColor,
      );
    }

    // Find the <svg> element. Assuming there's only one <svg> tag in your SVG file
    final XmlElement? svgElement = document.findAllElements('svg').firstOrNull;
    if (svgElement != null) {
      // Extract width and height attributes
      final String? viewBox = svgElement.getAttribute('viewBox');
      final String? widthStr = svgElement.getAttribute('width');
      final String? heightStr = svgElement.getAttribute('height');

      if (viewBox != null) {
        List<String> viewBoxValues = viewBox.split(' ');
        SVGwidth = double.parse(viewBoxValues[2]);
        SVGheight = double.parse(viewBoxValues[3]);
      } else {
        print('Width or height attribute is missing.');
      }
      // if (widthStr != null && heightStr != null) {
      //   // Parse width and height, removing 'px' and converting to integers
      //   if (widthStr.contains('px')) {
      //     SVGwidth = int.parse(widthStr.replaceAll('px', ''));
      //   } else {
      //     SVGwidth = int.parse(widthStr.replaceAll('%', ''));
      //   }
      //   if (heightStr.contains('px')) {
      //     SVGheight = int.parse(heightStr.replaceAll('px', ''));
      //   } else {
      //     SVGheight = int.parse(heightStr.replaceAll('%', ''));
      //   }
      // } else {
      //   print('Width or height attribute is missing.');
      // }
    } else {
      print('SVG element not found.');
    }
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

  static void fixOuterClasses() {
    final pageOuterGroups = document.findAllElements('g').where((element) {
      return element.getAttribute('class') == 'page-outer';
    });

    // Modify the class attribute of child elements
    for (final group in pageOuterGroups) {
      for (final child in group.children) {
        if (child is XmlElement) {
          child.setAttribute('class', 'quran-text');
        }
      }
    }
  }

  static Future<String?> getSvgViewBox(
    BuildContext context,
    String svgNumber,
  ) async {
    String? viewBox;
    // String svgNewData = await rootBundle.loadString(
    //   'assets/ayah_svg/$svgNumber.svg',
    // );

    String svgNewData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
      '$svgNumber.svg',
    );
    svgNewData = adjustSvgForFontSize(
      context,
      svgString: svgNewData,
      zoomPercentage:
          ZoomService().zoomPercentage[ZoomService().getCurrentZoomEnum(
        layoutContext,
      )]!,
      pageNumber: int.parse(svgNumber),
    );
    final XmlDocument documentNewFetched = XmlDocument.parse(svgNewData);
    final XmlElement? svgElement =
        documentNewFetched.findAllElements('svg').firstOrNull;
    if (svgElement != null) {
      // Extract width and height attributes
      viewBox = svgElement.getAttribute('viewBox');
    }
    return viewBox;
  }

  static void _colorAllAya(
    double value, {
    bool isCustom = false,
  }) {
    String tectColor = AyahSvgServiceHelper.valueToColorHex(value);
    if (isCustom) {
      tectColor = AyahSvgServiceHelper.getStringFromColor(quranTextColor);
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
    svgData = document.toXmlString(pretty: true);
  }

  static void _hideShowAyaMarkNight(bool visibleFlag) {
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
    svgData = document.toXmlString(pretty: true);
  }

  static void _hideShowAyaMarkLight(bool visibleFlag) {
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
    svgData = document.toXmlString(pretty: true);
  }

  static String adjustSvgForFontSize(
    BuildContext context, {
    required String svgString,
    required int zoomPercentage,
    required int pageNumber,
  }) {
    final documentFetched = XmlDocument.parse(svgString);
    final XmlElement? svgElement =
        documentFetched.findAllElements('svg').firstOrNull;
    if (svgElement != null) {
      // Extract width and height attributes
      String? oldViewBox = svgElement.getAttribute('viewBox');

      if (oldViewBox != null) {
        String alignment = AyahSvgServiceHelper.getPageAlignment(pageNumber);

        String newViewBox = AyahSvgServiceHelper.zoomFunction(
          context,
          oldViewBox,
          zoomPercentage:
              (pageNumber > 3) ? zoomPercentage : zoomPercentage - 6,
          type: alignment,
        );

        final RegExp viewBoxRegex = RegExp(r'viewBox="([^"]+)"');
        final match = viewBoxRegex.firstMatch(svgString);

        if (match == null) {
          // No viewBox found in the SVG data
          return svgString;
        }

        final viewBox = match.group(1)!;
        final viewBoxValues = viewBox.split(' ').map(double.parse).toList();

        if (viewBoxValues.length != 4) {
          // Invalid viewBox format
          return svgString;
        }
        return svgString.replaceFirst(viewBoxRegex, 'viewBox="$newViewBox"');
      } else {
        print('Viewbox attribute is missing.');
      }
    } else {
      print('SVG element not found.');
    }
    return document.toXmlString(pretty: true);
  }

  static void colorAya(
    BuildContext context,
    int suraId,
    int ayaId, {
    bool isCustomColor = false,
  }) {
    // colorAllAyaBlack(context);
    if (context.theme.brightness == Brightness.dark) {
      _colorAllAya((0 + (100 - darkThemeTextShade)).toDouble(),
          isCustom: isCustomColor);
    } else {
      _colorAllAya(100, isCustom: isCustomColor);
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
          }
        }
      } else {
        debugPrint('Is SorahName or Is Bismalla: $lineType');
      }
    }
    // Convert the modified XmlDocument back to a string
    svgData = document.toXmlString(pretty: true);
  }

  static void colorAllAyaCustom(
    BuildContext context, {
    Color? customColor,
  }) {
    String colorToChangeValue =
        AyahSvgServiceHelper.getStringFromColor(customColor!);
    if (context.theme.brightness == Brightness.dark &&
        AyahSvgService.darkThemeTextShade !=
            QuranDetailsService.defaultTextShadeInDarkValue) {
      colorToChangeValue = AyahSvgServiceHelper.valueToColorHex(
        (0 + (100 - darkThemeTextShade)).toDouble(),
      );
    }
    print('ColorPath: fill:$colorToChangeValue');
    for (final XmlElement element in elements) {
      // Check for the specified attributes and values
      final hasObjectId = element.getAttribute('objectID') != null;
      final isObjectTypeNotAyaMark =
          element.getAttribute('objecttype') != 'otAyaMark';

      if (isObjectTypeNotAyaMark) {
        List<XmlElement> allPathElements =
            element.findAllElements('path').toList();
        final Iterable<XmlElement> pathElements = element.findElements('path');
        for (final XmlElement pathElement in allPathElements) {
          pathElement.setAttribute('style', 'fill:$colorToChangeValue');
        }
      }
    }
    // Convert the modified XmlDocument back to a string
    svgData = document.toXmlString(pretty: true);
  }

  static List<int> checkHotspots(
    Offset position,
    BuildContext context,
  ) {
    bool isCustomColor =
        (quranTextColor != QuranDetailsService.defaultQuranTextColor);
    debugPrint("Checking headings");
    List<XmlElement> savedHeadings = [];
    for (final XmlElement element in elements) {
      final hasObjectId = element.getAttribute('objectid') != null;
      final hasNoObjectType = element.getAttribute('objecttype') == null;
      final hasEmptyClass = element.getAttribute('class') == '';
      if (hasObjectId && hasNoObjectType && hasEmptyClass) {
        debugPrint("Found A Heading");
        savedHeadings.add(element);
      }
    }
    print('Length Of Saved headings: ${savedHeadings.length}');
    int suraId = -1;
    int ayaId = -1;
    try {
      double screenHeight = MediaQuery.of(context).size.height * 0.91;
      double screenWidth = MediaQuery.of(context).size.width;
      print(
        'Screen width: $screenWidth, Screen height: $screenHeight',
      );
      print(
        'Tap position: $position',
      );
      //Getting SVGWIDTH
      double svgWidth = 1;
      double scale = screenWidth / SVGwidth;
      Offset scaledOffset = const Offset(0, 0);
      if (originalViewBox.isNotEmpty) {
        List<String> viewBoxValues = originalViewBox.split(' ');
        double viewBoxX = double.parse(viewBoxValues[0]);
        double viewBoxY = double.parse(viewBoxValues[1]);
        double viewBoxWidth = double.parse(viewBoxValues[2]);
        double viewBoxHeight = double.parse(viewBoxValues[3]);

        // Debug output for viewBox values
        print(
          'ViewBox values - X: $viewBoxX, Y: $viewBoxY, Width: $viewBoxWidth, Height: $viewBoxHeight',
        );
        // Calculate scaling factors
        double scaleX = screenWidth / viewBoxWidth;
        double scaleY = screenHeight / viewBoxHeight;

        // Translate and scale tap position
        double scaledX = position.dx / scaleX + viewBoxX;
        double scaledY = position.dy / scaleY + viewBoxY;
        scaledOffset = Offset(scaledX, scaledY);

        // Debug output for translated coordinates
        print(
          'Translated position: $scaledOffset',
        );
        print(
          'Scale factors - X: $scaleX, Y: $scaleY',
        );

        // svgWidth = double.parse(viewBoxValues[2]);
        // scale = screenWidth / svgWidth;
      }
      // double scaleX = screenWidth / SVGwidth;
      // double scaleY = screenHeight / SVGheight;

      // Offset scaledOffset = Offset(position.dx / scaleX, position.dy / scaleY);
      // Offset scaledOffset = Offset(position.dx / scale, position.dy / scale);
      print(screenWidth);
      print(scale);
      print(scaledOffset);
      for (var element in SVGgElements) {
        try {
          if (element.rect.contains(scaledOffset)) {
            print("CONTAINS");
            // Assuming 'Rect' has a method 'contains(Point p)'
            suraId = int.parse(element.sora);
            ayaId = int.parse(element.aya);
            // showAlert(suraId, ayaId);
            // print ("element: ${element.objectId}");
            if (suraId == 0 && ayaId == 0) {
              suraId = 0;
              ayaId = 0;
              debugPrint("ZERO CHECK");
            } else {
              colorAya(
                context,
                suraId,
                ayaId,
                isCustomColor: isCustomColor,
              ); // This line updates the state of _counter
            }
          }
        } catch (e) {
          debugPrint("Inside First");
          debugPrint(e.toString());
        }
      }

      if (suraId == -1 && ayaId == -1) {
        debugPrint('Apply normalization');
        Offset nearestCenter =
            AyahSvgServiceHelper.getCenter(SVGgElements.first.rect);
        double nearestDistance = (scaledOffset - nearestCenter).distance;

        for (var element in SVGgElements) {
          Offset center = AyahSvgServiceHelper.getCenter(element.rect);
          double distance = (scaledOffset - center).distance;
          if (distance < nearestDistance) {
            nearestCenter = center;
            nearestDistance = distance;
          }
        }

        // Normalize the widget's offset to the nearest center or tapped offset
        Offset normalizedOffset = nearestCenter;
        double threshold = 50.0; // Define a threshold for the nearest distance
        if (nearestDistance > threshold) {
          normalizedOffset = scaledOffset;
        }
        debugPrint('Now coloring with normalized offset');
        for (var element in SVGgElements) {
          try {
            if (element.rect.contains(normalizedOffset)) {
              // Assuming 'Rect' has a method 'contains(Point p)'
              suraId = int.parse(element.sora);
              ayaId = int.parse(element.aya);
              // showAlert(suraId, ayaId);
              // print ("element: ${element.objectId}");

              if (suraId == 0 && ayaId == 0) {
                suraId = 0;
                ayaId = 0;
                debugPrint("ZERO CHECK");
              } else {
                colorAya(
                  context,
                  suraId,
                  ayaId,
                  isCustomColor: isCustomColor,
                ); // This line updates the state of _counter
              }
            }
          } catch (e) {
            debugPrint("Inside Second");
            debugPrint(e.toString());
          }
        }

        print("Processing Headings 1");
        if (suraId == -1 && ayaId == -1) {
          print("Processing Heading 2 s");
          for (var element in savedHeadings) {
            print(element);
            final String rectData = element.getAttribute('rect') ?? '0,0,0,0';
            final List<double> rectValues = rectData
                .split(',')
                .map((value) => double.tryParse(value) ?? 0.0)
                .toList();
            if (rectValues.length == 4) {
              final Rect rect = Rect.fromLTWH(rectValues[0], rectValues[1],
                  rectValues[2] - rectValues[0], rectValues[3] - rectValues[1]);
              print("GOT RECT");
              final cubit = EssentialMoshafCubit.get(context);

              if (scaledOffset.dy < MediaQuery.of(context).size.height * 0.3) {
                cubit.changeBottomNavBar(0);
                cubit.toggleRootView();
                if (scaledOffset.dx < MediaQuery.of(context).size.width * 0.5) {
                  cubit.changeFihrisView(1);
                  return [suraId, ayaId];
                } else {
                  cubit.changeFihrisView(0);
                  return [suraId, ayaId];
                }
              }
              if (rect.contains(scaledOffset)) {
                print("SCALEDDDD");
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return [(suraId == 0) ? -1 : suraId, (ayaId == 0) ? -1 : ayaId];
  }
}
