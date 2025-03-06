import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/data_sources/image_size_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/data_sources/moshaf_hisb_sakta_sajda_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'package:xml/xml.dart';

Future<String> addHisbWithoutSajdaSakta({
  required String svgString,
  required int pageNumber,
  required int zoomPercentage,
}) async {
  print('addHisbWithoutSajdaSakta: $pageNumber');

  final document = XmlDocument.parse(svgString);

  if (!ZoomService().isBorderEnable(zoomPercentage)) {
    MoshafHisbSaktaSajdaService moshafHisbSaktaSajdaService =
        MoshafHisbSaktaSajdaService();
    moshafHisbSaktaSajdaService.init();

    List<PageHisbSaktaSajda>? currentPageHisbSaktaSajda =
        moshafHisbSaktaSajdaService.pageMap[pageNumber];

    if (currentPageHisbSaktaSajda != null &&
        currentPageHisbSaktaSajda.isNotEmpty) {
      // Remove all 'sajda' and 'sakta' files
      List<PageHisbSaktaSajda> filteredFiles = currentPageHisbSaktaSajda
          .where((file) =>
              !file.fileName.contains('sajda') &&
              !file.fileName.contains('sakta'))
          .toList();

      if (filteredFiles.isEmpty) {
        print('No valid Hisb images found after filtering sajda/sakta.');
        return svgString; // Return unchanged SVG if no valid image remains
      }

      PageHisbSaktaSajda selectedFile = filteredFiles.first;

      print('Selected File: ${selectedFile.fileName}');

      ByteData bytes =
          await rootBundle.load('assets/hisb_icons/${selectedFile.fileName}');
      String base64Image = base64Encode(Uint8List.view(bytes.buffer));

      // Get the mask for the selected image
      String? mask = moshafHisbSaktaSajdaService.getMask(
        pageNumber,
        isDark: AppContext.getAppContext()!.isDarkMode,
      );

      if (mask != null) {
        print("Mask: $mask");

        ByteData maskBytes = await rootBundle.load('assets/hisb_icons/$mask');
        String maskBase64Image = base64Encode(Uint8List.view(maskBytes.buffer));

        // Get actual sizes
        final hizbSize = await getPngActualSize(
            'assets/hisb_icons/${selectedFile.fileName}');
        print(
            'Original Hizb Size -> Height: ${hizbSize.height}, Width: ${hizbSize.width}');

        final maskSize = await getPngActualSize('assets/hisb_icons/$mask');
        print(
            'Original Mask Size -> Height: ${maskSize.height}, Width: ${maskSize.width}');

        // Define scaling factors
        double hisbScaleFactor = 0.90; // Scale down the Hisb slightly
        double maskScaleFactor = 0.88; // Reduce the mask scaling slightly more

        // Scale the Hisb icon
        double imageWidth = hizbSize.width * hisbScaleFactor;
        double imageHeight = hizbSize.height * hisbScaleFactor;

        // Scale the mask while maintaining proportions (slightly smaller)
        double maskWidth = maskSize.width * maskScaleFactor;
        double maskHeight = maskSize.height * maskScaleFactor;

        print(
            'Scaled Hizb -> Height: $imageHeight, Width: $imageWidth | Scaled Mask -> Height: $maskHeight, Width: $maskWidth');
        print('');

        try {
          // Generate the mask image XML
          String maskImageString = moshafHisbSaktaSajdaService.getImageString(
            pageNumber: pageNumber,
            zoomPercentage: zoomPercentage,
            svgString: svgString,
            imageWidth: maskWidth,
            imageHeight: maskHeight,
            base64Image: maskBase64Image,
            currentIndex: 1,
            totalImagesToRender: 1,
            isMask: true,
            isLongMask: hizbSize.height > 200,
            isSajdaMask: false, // Sajda is already removed
          );

          XmlElement? maskImageElement =
              XmlDocument.parse(maskImageString).rootElement;
          maskImageElement.parent?.children.remove(maskImageElement);

          XmlElement? maskSvgElement =
              document.findAllElements('svg').firstOrNull;
          if (!maskSvgElement!.children.contains(maskImageElement)) {
            maskSvgElement.children.add(maskImageElement);
          }
        } catch (e) {
          debugPrint('Error processing mask: $e');
        }

        try {
          // Generate the Hisb image XML
          String imageStr = moshafHisbSaktaSajdaService.getImageString(
            pageNumber: pageNumber,
            zoomPercentage: zoomPercentage,
            svgString: svgString,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            base64Image: base64Image,
            currentIndex: 1,
            totalImagesToRender: 1,
          );

          XmlElement? imageElement = XmlDocument.parse(imageStr).rootElement;
          imageElement.parent?.children.remove(imageElement);

          XmlElement? svgElement = document.findAllElements('svg').firstOrNull;
          if (!svgElement!.children.contains(imageElement)) {
            svgElement.children.add(imageElement);
          }
          return document.toXmlString();
        } catch (e) {
          debugPrint('Error processing Hisb image: $e');
        }
      } else {
        print('No mask found for selected file.');
      }
    }
  }
  return svgString;
}
