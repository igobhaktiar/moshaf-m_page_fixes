import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/utils/assets_manager.dart';
import '../../tenReadings/data/models/khelafia_word_model.dart';

enum QeeratState {
  qeerat,
  osoul,
  shawahed,
  hawamesh,
}

class QeeratService {
  QeeratService._();

  static String _getLastTwoSegments(String filePath) {
    // Split the path by "/"
    List<String> segments = filePath.split('/');

    // Check if there are at least two segments
    if (segments.length >= 2) {
      // Join the last two segments with a "/"
      return '${segments[segments.length - 2]}/${segments.last}';
    } else {
      // If not enough segments, return the original path or handle accordingly
      return filePath;
    }
  }

  static String convertFileToAssetsPath(String originalPath) {
    // Define the prefix in the original path that you want to replace
    String prefixRemoved = _getLastTwoSegments(originalPath);

    // Check if the original path starts with the prefix and replace it

    return 'assets/ten_readings/$prefixRemoved';
  }

  static Future<List<dynamic>> getQeeratPageJson(
      int pageNumber, QeeratState state) async {
    String extension = '';

    if (state == QeeratState.qeerat) {
      extension = 'Qeraat_';
      String jsonString = await rootBundle
          .loadString(AppAssets.getQeeratPageJson(pageNumber, extension));
      final jsonData = json.decode(jsonString);
      List<KhelafiaWordModel> khelafiaWordModelList = [];
      for (final item in jsonData) {
        // Decode the JSON string into a Map
        khelafiaWordModelList.add(KhelafiaWordModel.fromJson(item));
      }
      return khelafiaWordModelList;
    } else if (state == QeeratState.osoul) {
      extension = 'Osoul_';
      String jsonString = await rootBundle
          .loadString(AppAssets.getQeeratPageJson(pageNumber, extension));
      final jsonData = json.decode(jsonString);
      List<OsoulModel> oSoulWordModelList = [];
      for (final item in jsonData) {
        // Decode the JSON string into a Map
        oSoulWordModelList.add(OsoulModel.fromJson(item));
      }
      return oSoulWordModelList;
    } else if (state == QeeratState.shawahed) {
      extension = 'Shawahed_';
      String jsonString = await rootBundle
          .loadString(AppAssets.getQeeratPageJson(pageNumber, extension));
      final jsonData = json.decode(jsonString);
      List<ShwahidDalalatGroupModel> shawahedWordModelList = [];
      for (final item in jsonData) {
        // Decode the JSON string into a Map
        shawahedWordModelList.add(ShwahidDalalatGroupModel.fromJson(item));
      }
      return shawahedWordModelList;
    } else if (state == QeeratState.hawamesh) {
      extension = 'Hawamesh_';
      String jsonString = await rootBundle
          .loadString(AppAssets.getQeeratPageJson(pageNumber, extension));
      final jsonData = json.decode(jsonString);
      List<HwamishModel> hawameshWordModelList = [];
      for (final item in jsonData) {
        // Decode the JSON string into a Map
        hawameshWordModelList.add(HwamishModel.fromJson(item));
      }
      return hawameshWordModelList;
    }

    return [];
  }
}
