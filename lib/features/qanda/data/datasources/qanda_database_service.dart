import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_play_asset_delivery/flutter_play_asset_delivery.dart';
import 'package:qeraat_moshaf_kwait/config/app_config/app_config.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/data/models/qanda_model.dart';

class QAndADatabaseService {
  QAndADatabaseService._();

  static String databaseString = 'assets/database/quran_quiz.csv';

  static Future<List<QuizQuestion>> loadCsvData() async {
    final List<QuizQuestion> quizQuestions = [];
    try {
      String csvString = '';
      await AppConfig.executeByEnvironment(
        developmentFunction: () async {
          csvString = await rootBundle.loadString(databaseString);
        },
        stagingFunction: () async {
          File csvFile = await FlutterPlayAssetDelivery.getAssetFile(
            'quran_quiz.csv',
          );

          csvString = await csvFile.readAsString();
        },
        productionFunction: () async {
          File csvFile = await FlutterPlayAssetDelivery.getAssetFile(
            'quran_quiz.csv',
          );

          csvString = await csvFile.readAsString();
        },
      );

      // Convert the CSV string to a List of List<dynamic>
      final List<List<dynamic>> csvData =
          const CsvToListConverter().convert(csvString);
      print("CSV length is ${csvData.length}");
      // Convert each row into a QuizQuestion object, skipping the header row if necessary
      for (var i = 1; i < csvData.length; i++) {
        // Start from 1 to skip header
        quizQuestions.add(QuizQuestion.fromCsv(i, csvData[i]));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    // Read the file as a string

    return quizQuestions;
  }
}
