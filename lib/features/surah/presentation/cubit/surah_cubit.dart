import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/core/api/end_points.dart';
import 'package:qeraat_moshaf_kwait/features/surah/data/models/surah_model.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/surah_state.dart';
import '../../../playlist/data/datasources/playlist_database.dart';
import '../../data/datasources/quran_soorah.dart';

class SurahCubit extends Cubit<SurahState> {
  SurahCubit() : super(SurahInitial());

  static SurahCubit get(context) => BlocProvider.of(context);

  // State variables
  List<SurahModel> surahs =
      surahList.map((surah) => SurahModel.fromJson(surah)).toList();
  SurahModel? currentSurah;
  String? appDirectory;
  String? _reciterDirectory;
  late File logFile;
  final Dio dio = Dio();
  Set<String> downloadedSurahIds = <String>{};
  bool isDownloading = false;
  String? downloadingSurahId;
  final PlaylistDatabase _playlistDatabase = PlaylistDatabase();

  // Getter for reciterDirectory with null check
  String? get reciterDirectory => _reciterDirectory;

  // Initialize the cubit
  Future<void> init(String? reciterName) async {
    try {
      // Set initial surah
      currentSurah =
          surahList.map((surah) => SurahModel.fromJson(surah)).toList().first;
      emit(ChangeCurrentReciterState(currentSurah!));

      // Get application directory
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (dir == null) {
        throw Exception("Failed to get application directory");
      }

      appDirectory = dir.path;
      debugPrint("App directory initialized: $appDirectory");

      // Set up reciter if provided
      if (reciterName != null) {
        await setReciter(reciterName);
        await syncDownloadedFiles();
      }
    } catch (e) {
      debugPrint("Initialization error: $e");
      emit(SurahError(msg: 'Initialization failed: ${e.toString()}'));
    }
  }

  // Set up reciter directory
  Future<void> setReciter(String currentReciter) async {
    if (appDirectory == null) {
      throw Exception("App directory not initialized");
    }

    try {
      // Create specific directory for surahs with reciter name
      _reciterDirectory = '$appDirectory/surah_$currentReciter';
      final reciterDir = Directory(_reciterDirectory!);

      if (!reciterDir.existsSync()) {
        await reciterDir.create(recursive: true);
        debugPrint("Created reciter directory: ${reciterDir.path}");
      }

      // Create log file
      logFile = File("$_reciterDirectory/log.txt");
      if (!logFile.existsSync()) {
        await logFile.create();
        debugPrint("Created log file: ${logFile.path}");
      }
    } catch (e) {
      debugPrint("SetReciter error: $e");
      throw Exception("Failed to set up reciter directory: $e");
    }
  }

  // Get file path for a surah
  String getSurahFilePath(String surahId) {
    if (_reciterDirectory == null) {
      throw Exception("Reciter directory not set");
    }
    return '$_reciterDirectory/surah_$surahId.mp3';
  }

  // Sync downloaded files
  Future<void> syncDownloadedFiles() async {
    if (_reciterDirectory == null) {
      debugPrint("Cannot sync files: Reciter directory not set");
      return;
    }

    try {
      final reciterDir = Directory(_reciterDirectory!);
      if (!reciterDir.existsSync()) {
        debugPrint("Reciter directory doesn't exist during sync");
        return;
      }

      final files = reciterDir.listSync();
      downloadedSurahIds = files
          .where((file) => file is File && file.path.endsWith('.mp3'))
          .map((file) {
        final filename = file.path.split('/').last;
        // Extract surah ID from "surah_001.mp3" format
        return filename.split('_').last.split('.').first;
      }).toSet();

      debugPrint("Synced ${downloadedSurahIds.length} downloaded surahs");
      emit(DownloadedFilesUpdated(downloadedSurahIds: downloadedSurahIds));
    } catch (e) {
      debugPrint("Sync error: $e");
    }
  }

  // Check if a surah is downloaded
  bool isSurahDownloaded(String reciter, String surahId) {
    try {
      final filePath = getSurahFilePath(surahId);
      final file = File(filePath);
      return file.existsSync();
    } catch (e) {
      debugPrint("Error checking surah download status: $e");
      return false;
    }
  }

  // Download a selected surah
  Future<String?> downloadSelectedSurah(
      String currentReciter, String selectedSurahId) async {
    debugPrint(
        'Starting download for surah $selectedSurahId from reciter $currentReciter');

    if (isDownloading) {
      emit(const SurahAudioDownloadError(
          msg: 'Download already in progress. Please wait.'));
      return null;
    }

    try {
      // Ensure reciter directory is set up
      await setReciter(currentReciter);

      if (_reciterDirectory == null) {
        throw Exception("Reciter directory not initialized after setReciter");
      }

      final filePath = getSurahFilePath(selectedSurahId);
      debugPrint("Download path: $filePath");

      final file = File(filePath);

      // Check if file already exists
      if (file.existsSync()) {
        debugPrint('Surah file already exists');
        emit(const SurahAudioDownloadSuccess(msg: ''));
        return filePath;
      }

      // Start download
      isDownloading = true;
      downloadingSurahId = selectedSurahId;
      emit(const SurahAudioDownloading(value: '0%'));

      var path =
          '${EndPoints.soorahMp3Path}$currentReciter/$selectedSurahId.mp3';
      final uri = Uri.parse(path);
      debugPrint("Downloading from: $path");

      final response = await dio.downloadUri(
        uri,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = ((received / total) * 100).toStringAsFixed(0);
            emit(SurahAudioDownloading(value: '$progress%'));
          }
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Download completed successfully');
        await syncDownloadedFiles();
        emit(const SurahAudioDownloadSuccess(msg: 'Download completed!'));
        return filePath;
      } else {
        throw Exception("Download failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Download error: $e');
      emit(SurahAudioDownloadError(msg: 'Download failed: ${e.toString()}'));
      return null;
    } finally {
      isDownloading = false;
      downloadingSurahId = null;
    }
  }

  // Insert surah into playlist
  Future<void> insertSurahInPlaylist({
    required int playlistId,
    required String surahId,
    required String surahName,
    required String reciterName,
    required String reciterArabicName,
    required String reciterEnglishName,
  }) async {
    try {
      final paddedSurahId = surahId.toString().padLeft(3, '0');

      // Ensure reciter is set before getting file path
      await setReciter(reciterName);
      final audioPath = getSurahFilePath(paddedSurahId);

      await _playlistDatabase.insertSurahToPlaylist(
        playlistId: playlistId,
        surahId: paddedSurahId,
        surahName: surahName,
        reciterName: reciterName,
        reciterArabicName: reciterArabicName,
        reciterEnglishName: reciterEnglishName,
        audioPath: audioPath,
        audioUrl: '${EndPoints.soorahMp3Path}$reciterName/$paddedSurahId.mp3',
      );
      emit(const PlaylistSuccess("Surah added to playlist successfully"));
    } catch (e) {
      debugPrint("Playlist insertion error: $e");
      emit(const PlaylistError("Failed to add surah to playlist"));
    }
  }

  // Change current surah
  void changeCurrentSurah(SurahModel surah) {
    currentSurah = surah;
    emit(ChangeCurrentReciterState(surah));
  }
}
