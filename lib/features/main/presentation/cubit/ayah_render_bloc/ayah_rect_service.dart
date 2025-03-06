import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class AyahDetailsWithRect {
  final int page;
  final int objectId;
  final int sora;
  final int aya;
  final Rect rect;

  AyahDetailsWithRect(this.page, this.objectId, this.sora, this.aya, this.rect);
}

class AyahRectService {
  AyahRectService._();
  static List<AyahDetailsWithRect> ayahs = [];
  static String databaseString = 'assets/database/words_rects.csv';

  static Future<void> init() async {
    try {
      final String csvString = await rootBundle.loadString(databaseString);
      final List<List<dynamic>> csvData =
          const CsvToListConverter().convert(csvString);

      for (var i = 1; i < csvData.length; i++) {
        // Skip the header

        final int page = int.parse(csvData[i][0].toString());
        final int objectId = int.parse(csvData[i][1].toString());
        final int sora = int.parse(csvData[i][2].toString());
        final int aya = int.parse(csvData[i][3].toString());
        final double left = double.parse(csvData[i][4].toString());
        final double top = double.parse(csvData[i][5].toString());
        final double right = double.parse(csvData[i][6].toString());
        final double bottom = double.parse(csvData[i][7].toString());
        final Rect rect = Rect.fromLTWH(left, top, right - left, bottom - top);

        ayahs.add(
          AyahDetailsWithRect(
            page,
            objectId,
            sora,
            aya,
            rect,
          ),
        );
      }
    } catch (e) {
      print('Error processing CSV: $e');
    }
  }

  static AyahDetailsWithRect? findAyahByRect(
    double x,
    double y,
    int pageNumber,
  ) {
    List<AyahDetailsWithRect> pageAyahs = findRectsByPage(pageNumber);
    for (var ayah in pageAyahs) {
      final rect = ayah.rect;
      if (rect.contains(Offset(x, y))) {
        return ayah;
      }
    }
    const double threshold = 20;
    for (var ayah in pageAyahs) {
      final rect = ayah.rect;
      if (x >= rect.left + threshold &&
          x < rect.right + threshold &&
          y >= rect.top + threshold &&
          y < rect.bottom + threshold) {
        return ayah;
      }
    }
    // AyahDetailsWithRect? nearestRect;
    // double nearestDistance = double.infinity;

    // for (var ayah in pageAyahs) {
    //   // Find the nearest point on the current rect
    //   double nearestX = x.clamp(ayah.rect.left, ayah.rect.right);
    //   double nearestY = y.clamp(ayah.rect.top, ayah.rect.bottom);
    //   Offset nearestPointOnRect = Offset(nearestX, nearestY);

    //   // Calculate the distance from the given point to the nearest point on the rect
    //   double distance = (Offset(x, y) - nearestPointOnRect).distance;

    //   // Update the nearest rect if this one is closer
    //   if (distance < nearestDistance) {
    //     nearestDistance = distance;
    //     nearestRect = ayah;
    //   }

    //   return nearestRect;
    // }
    return null;
  }

  static List<AyahDetailsWithRect> findRectsByPage(int pageNumber) {
    return ayahs.where((ayah) => ayah.page == pageNumber).toList();
  }
}
