import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_play_asset_delivery/flutter_play_asset_delivery.dart';

import '../../config/app_config/app_config.dart';

class PlayAssetDelivery {
  static const MethodChannel _platform = MethodChannel('play_asset_delivery');
  static String _assetPackPath = '';

  static Future<String> getSvgDataFromPlayAssetDelivery(
    String svgNumber, {
    bool isSvgFunctionActive = true,
  }) async {
    String toReturnString = '';
    try {
      await AppConfig.executeByEnvironment(
        developmentFunction: () async {
          String svgData = await rootBundle.loadString(
            'assets/ayah_svg/$svgNumber',
          );
          toReturnString = svgData;
        },
        stagingFunction: () async {
          File assetFile =
              await FlutterPlayAssetDelivery.getAssetFile(svgNumber);
          if (isSvgFunctionActive) {
            String svgData = await assetFile.readAsString();
            toReturnString = svgData;
          }
        },
        productionFunction: () async {
          File assetFile =
              await FlutterPlayAssetDelivery.getAssetFile(svgNumber);
          if (isSvgFunctionActive) {
            String svgData = await assetFile.readAsString();
            toReturnString = svgData;
          }
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return toReturnString;
  }

  // Method to download an asset pack by name
  static Future<void> downloadAssetPack(String assetPackName) async {
    try {
      // Call the native Android method 'downloadAssetPack' and pass the asset pack name
      final result = await _platform
          .invokeMethod('downloadAssetPack', {'name': assetPackName});
      print("Asset Pack Downloaded: $result");
      final String? assetPath = await _platform
          .invokeMethod('getAssetPackPath', {'name': assetPackName});
      if (assetPath != null) {
        _assetPackPath = assetPath;
      }
    } catch (e) {
      // Handle any errors from the platform channel
      print("Error downloading asset pack: $e");
    }
  }

  static String getAssetsPath() {
    return _assetPackPath;
  }

  // Method to fetch the path of an asset pack
  static Future<String?> getAssetPackPath(String assetPackName) async {
    try {
      final String? assetPath = await _platform
          .invokeMethod('getAssetPackPath', {'name': assetPackName});
      if (assetPath != null) {
        _assetPackPath = assetPath;
      }
      return assetPath;
    } catch (e) {
      print("Error fetching asset pack path: $e");
      return null;
    }
  }

  static Future<void> testMethod() async {
    try {
      final result = await _platform.invokeMethod('testMethod');
      print("Test Method Called: $result");
    } catch (e) {
      print("Error calling test method: $e");
    }
  }
}
