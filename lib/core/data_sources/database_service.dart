import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_play_asset_delivery/flutter_play_asset_delivery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/config/app_config/app_config.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static Database? shamelDb;
  static String tafseerTable = 'tafseer';
  static Future<void> cleanupOldCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dbFile = File('${tempDir.path}/shamel.db');
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (e) {
      debugPrint('Cache cleanup error: $e');
    }
  }

  static initializeShamelDb() async {
    openDatabaseFromAssets(
      AppAssets.shamelDb,
      'shamel.db',
    ).then((database) {
      if (database != null) {
        debugPrint('Database IS NOT NULL');
        shamelDb = database;
      } else {
        debugPrint('Database IS NULL');
      }
    });
  }

  static Future<File?> getDbFile(String dbAssetPath, String dbFileName) async {
    try {
      // Get the application documents directory instead of temp
      Directory docDir = await getApplicationDocumentsDirectory();
      String dbPath = path.join(docDir.path, 'databases', dbFileName);

      // Create the databases directory if it doesn't exist
      Directory dbDir = Directory(path.dirname(dbPath));
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }

      // Check if database already exists
      File dbFile = File(dbPath);
      if (await dbFile.exists()) {
        return dbFile;
      }

      // If not exists, create it from asset
      await AppConfig.executeByEnvironment(developmentFunction: () async {
        ByteData data = await rootBundle.load(dbAssetPath);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await dbFile.writeAsBytes(bytes, flush: true);
      }, stagingFunction: () async {
        File assetFile =
            await FlutterPlayAssetDelivery.getAssetFile(dbFileName);
        await assetFile.copy(dbPath);
      }, productionFunction: () async {
        File assetFile =
            await FlutterPlayAssetDelivery.getAssetFile(dbFileName);
        await assetFile.copy(dbPath);
      });

      return dbFile;
    } catch (e) {
      debugPrint("Error retrieving database file: $e");
      return null;
    }
  }

  static Future<Database?> openDatabaseFromAssets(
      String assetPath, String dbName) async {
    try {
      File? dbFile = await getDbFile(assetPath, dbName);
      if (dbFile != null) {
        return await openDatabase(
          dbFile.path,
          readOnly: true, // Add this if your database is read-only
        );
      }
    } catch (e) {
      debugPrint('Database open error: $e');
    }
    return null;
  }

  // Rest of your methods remain the same...
}
