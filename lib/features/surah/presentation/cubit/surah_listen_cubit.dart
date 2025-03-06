import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/core/api/end_points.dart';

import '../../../../core/enums/moshaf_type_enum.dart';
import '../../../../core/utils/audio_handler.dart';
import '../../data/datasources/quran_soorah.dart';
import '../../data/models/surah_model.dart';

part 'surah_listen_state.dart';

class SurahListenCubit extends Cubit<SurahListenState> {
  // Audio related variables
  late AudioPlayer player;
  late AudioPlayerHandler playerHandler;
  PageController? controller;
  LoopModeState currentLoopMode = LoopModeState.none;
  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<Duration?>? durationSubscription;
  Duration currentAudioPosition = Duration.zero;
  Duration? totalAudioDuration;
  String? currentReciterPlaying;
  String? currentSurahPlaying;

  // Directory and file management
  String? appDirectory;
  String? _reciterDirectory;
  late File logFile;
  final Dio dio = Dio();
  late List<SurahModel> surahs;
  Set<String> downloadedSurahIds = <String>{};
  bool isDownloading = false;
  String? downloadingReciter;
  String? downloadingSurahId;
  // Getter for reciterDirectory
  String? get reciterDirectory => _reciterDirectory;

  SurahListenCubit({
    required this.player,
    required this.playerHandler,
  }) : super(SurahListenInitial()) {
    surahs = surahList.map((surah) => SurahModel.fromJson(surah)).toList();
    controller = PageController();
  }

  Future<void> init(String? reciterName) async {
    try {
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (dir == null) {
        throw Exception("Failed to get application directory");
      }

      appDirectory = dir.path;
      debugPrint("App directory initialized: $appDirectory");

      if (reciterName != null) {
        await setReciter(reciterName);
        await syncDownloadedFiles();
      }
    } catch (e) {
      debugPrint("Init error: $e");
      emit(SurahListenError(msg: 'Initialization failed: ${e.toString()}'));
    }
  }

  Future<void> setReciter(String currentReciter) async {
    if (appDirectory == null) {
      throw Exception("App directory not initialized");
    }

    try {
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

  String getSurahFilePath(String surahId) {
    if (_reciterDirectory == null) {
      throw Exception("Reciter directory not set");
    }
    return '$_reciterDirectory/surah_$surahId.mp3';
  }

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
        return filename.split('_').last.split('.').first;
      }).toSet();

      debugPrint("Synced ${downloadedSurahIds.length} downloaded surahs");
      emit(DownloadedFilesUpdated(downloadedSurahIds: downloadedSurahIds));
    } catch (e) {
      debugPrint("Sync error: $e");
    }
  }

  bool isSurahDownloaded(String reciter, String surahId) {
    try {
      // First ensure we're checking the correct reciter directory
      if (_reciterDirectory == null || !_reciterDirectory!.contains(reciter)) {
        // We need to construct the correct path for the reciter we're checking
        String reciterPath = '$appDirectory/surah_$reciter';
        final filePath = '$reciterPath/surah_$surahId.mp3';
        final file = File(filePath);
        return file.existsSync();
      } else {
        // We're already in the correct reciter directory
        final filePath = getSurahFilePath(surahId);
        final file = File(filePath);
        return file.existsSync();
      }
    } catch (e) {
      debugPrint("Error checking surah download status: $e");
      return false;
    }
  }

  void setupPlayerStateListener() {
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        forceStopPlayer();
      }
    });
  }

  Future<void> prepareAndPlaySurah(
    String currentReciter,
    String selectedSurahId,
  ) async {
    if (isSurahCurrentlyPlaying(currentReciter, selectedSurahId)) {
      emit(PlayerAlreadyPlaying());
      return;
    }

    await forceStopPlayer();

    try {
      // Ensure reciter directory is set up
      await setReciter(currentReciter);

      currentReciterPlaying = currentReciter;
      currentSurahPlaying = selectedSurahId;

      final filePath = getSurahFilePath(selectedSurahId);
      final file = File(filePath);

      if (file.existsSync()) {
        debugPrint('File found, playing... $currentReciter');
        final singleSurah = AudioSource.file(filePath);
        await player.setAudioSource(singleSurah);
        player.play();
        setupPlayerStateListener();
        emit(SurahPlayerStart());
        _listenToAudioPositionAndDuration();
      } else {
        debugPrint('File not found, playing from URL...');
        final audioUrl = buildAudioUrl(currentReciter, selectedSurahId);
        final singleSurah = AudioSource.uri(Uri.parse(audioUrl));
        await player.setAudioSource(singleSurah);
        player.play();
        setupPlayerStateListener();
        emit(SurahPlayerStart());
        _listenToAudioPositionAndDuration();
      }
    } catch (e) {
      debugPrint('Error preparing/playing surah: $e');
      currentSurahPlaying = null;
      currentReciterPlaying = null;
      emit(SurahListenAudioDownloadError());
    }
  }

  Future<void> downloadSelectedSurah(
      String currentReciter, String selectedSurahId) async {
    // If already downloading this specific surah
    if (isDownloading &&
        downloadingReciter == currentReciter &&
        downloadingSurahId == selectedSurahId) {
      debugPrint('Already downloading this surah');
      return;
    }

    try {
      await setReciter(currentReciter);

      if (_reciterDirectory == null) {
        throw Exception("Reciter directory not initialized after setReciter");
      }

      final filePath = getSurahFilePath(selectedSurahId);
      debugPrint("Download path: $filePath");

      final file = File(filePath);

      if (file.existsSync()) {
        debugPrint('Surah file already exists');
        emit(const SurahListenAudioDownloadSuccess(
            msg: 'File already downloaded!'));
        await prepareAndPlaySurah(currentReciter, selectedSurahId);
        return;
      }

      // Set downloading state
      isDownloading = true;
      downloadingReciter = currentReciter;
      downloadingSurahId = selectedSurahId;

      emit(SurahDownloadStarted(
          reciter: currentReciter, surahId: selectedSurahId, progress: '0%'));

      final uri = Uri.parse(buildAudioUrl(currentReciter, selectedSurahId));
      debugPrint("Downloading from: $uri");

      final response = await dio.downloadUri(
        uri,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = ((received / total) * 100).toStringAsFixed(0);
            emit(SurahDownloadProgress(
                reciter: currentReciter,
                surahId: selectedSurahId,
                progress: '$progress%'));
          }
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Download completed successfully');
        await syncDownloadedFiles();
        emit(SurahDownloadCompleted(
            reciter: currentReciter, surahId: selectedSurahId));
        await prepareAndPlaySurah(currentReciter, selectedSurahId);
      } else {
        throw Exception("Download failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Download error: $e');
      emit(SurahDownloadError(
          reciter: currentReciter,
          surahId: selectedSurahId,
          error: e.toString()));
    } finally {
      // Clear downloading state
      isDownloading = false;
      downloadingReciter = null;
      downloadingSurahId = null;
    }
  }

  // Add helper method to check if specific surah is downloading
  bool isSurahDownloading(String reciter, String surahId) {
    return isDownloading &&
        downloadingReciter == reciter &&
        downloadingSurahId == surahId;
  }

  String buildAudioUrl(String reciter, String surahId) {
    debugPrint('Building URL for reciter: $reciter, surahId: $surahId');
    var path = '${EndPoints.soorahMp3Path}$reciter/$surahId.mp3';
    debugPrint('Generated URL: $path');
    return path;
  }

  // [Rest of the audio control methods remain unchanged]
  void _listenToAudioPositionAndDuration() {
    positionSubscription = player.positionStream.listen((position) {
      currentAudioPosition = position;
      emit(SurahDurationStateUpdated(
        currentPosition: currentAudioPosition,
        totalDuration: totalAudioDuration,
      ));
    });

    durationSubscription = player.durationStream.listen((duration) {
      totalAudioDuration = duration;
      emit(SurahDurationStateUpdated(
        currentPosition: currentAudioPosition,
        totalDuration: totalAudioDuration,
      ));
    });
  }

  Future<void> forceStopPlayer() async {
    await player.stop();
    await player.dispose();
    currentSurahPlaying = null;
    currentReciterPlaying = null;
    player = AudioPlayer();
    emit(SurahPlayerStopped());
  }

  Future<void> pauseSurah() async {
    await player.pause();
  }

  void toggleLoopMode() {
    switch (currentLoopMode) {
      case LoopModeState.none:
        currentLoopMode = LoopModeState.one;
        player.setLoopMode(LoopMode.one);
        break;
      case LoopModeState.one:
        currentLoopMode = LoopModeState.none;
        player.setLoopMode(LoopMode.off);
        break;
    }
    emit(SurahListenStateUpdated(loopMode: currentLoopMode));
  }

  Future<void> previousSurah(
      String currentReciter, String selectedSurahId) async {
    await forceStopPlayer();
    final currentPage = controller?.page?.round() ?? 0;

    if (currentPage > 0) {
      controller?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      final previousSurahId = surahs[currentPage - 1].id;
      await prepareAndPlaySurah(
        currentReciter,
        previousSurahId.toString().padLeft(3, '0'),
      );
    }
  }

  Future<void> nextSurah(String currentReciter, String selectedSurahId) async {
    await forceStopPlayer();
    final currentPage = controller?.page?.round() ?? 0;

    if (currentPage < surahs.length - 1) {
      controller?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      final nextSurahId = surahs[currentPage + 1].id;
      await prepareAndPlaySurah(
        currentReciter,
        nextSurahId.toString().padLeft(3, '0'),
      );
    }
  }

  void seekForward() {
    final currentPos = player.position;
    final maxDuration = player.duration ?? Duration.zero;
    final newPosition = currentPos + const Duration(seconds: 10);

    final seekPosition = newPosition < maxDuration ? newPosition : maxDuration;

    player.seek(seekPosition);
    emit(SurahDurationStateUpdated(
      currentPosition: seekPosition,
      totalDuration: maxDuration,
    ));
  }

  bool isSurahCurrentlyPlaying(String reciter, String surahId) {
    return isReciterCurrentlyPlaying(reciter) && currentSurahPlaying == surahId;
  }

  bool isReciterCurrentlyPlaying(String reciter) {
    return currentReciterPlaying == reciter;
  }

  void seekAudio(Duration position) {
    player.seek(position);
    emit(SurahDurationStateUpdated(
      currentPosition: position,
      totalDuration: totalAudioDuration,
    ));
  }

  void seekBackward() {
    final currentPos = player.position;
    final newPosition = currentPos - const Duration(seconds: 10);

    final seekPosition =
        newPosition > Duration.zero ? newPosition : Duration.zero;

    player.seek(seekPosition);
    emit(SurahDurationStateUpdated(
      currentPosition: seekPosition,
      totalDuration: player.duration ?? Duration.zero,
    ));
  }

  @override
  Future<void> close() {
    positionSubscription?.cancel();
    durationSubscription?.cancel();
    controller?.dispose();
    player.dispose();
    return super.close();
  }
}
