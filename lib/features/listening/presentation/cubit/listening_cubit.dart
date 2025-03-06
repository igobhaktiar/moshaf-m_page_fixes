// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_single_cascade_in_expression_statements

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/core/api/end_points.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/utils/encode_arabic_digits.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import 'package:qeraat_moshaf_kwait/features/listening/data/datasources/available_reciters.dart';
import 'package:qeraat_moshaf_kwait/features/listening/data/models/Ayah_sound_model.dart';
import 'package:qeraat_moshaf_kwait/features/listening/data/models/reciter_model.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/screens/section_repeat_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/data_sources/all_ayat_without_tashkeel.dart';
import '../../../../core/responsiveness/responsive_framework_helper.dart';
import '../../../../core/utils/audio_handler.dart';
import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import '../../../tafseer/data/models/tafseer_reading_model.dart';

part 'listening_state.dart';

class ListeningCubit extends Cubit<ListeningState> {
  ListeningCubit(
      {required this.dioConsumer,
      required this.player,
      required this.playerHandler,
      required this.sharedPreferences,
      required this.internetConnectionChecker})
      : super(ListeningInitial());
  static ListeningCubit get(context) => BlocProvider.of(context);
  DioConsumer dioConsumer;
  AudioPlayer player;
  final AudioPlayerHandler playerHandler;
  final SharedPreferences sharedPreferences;
  final InternetConnectionChecker internetConnectionChecker;

  List<AyahModel> get allAyat => allAyatWithoutTashkelMapList
      .map((ayah) => AyahModel.fromJson(ayah))
      .toList();
  bool isToChooseRepeat = false;
  bool isToChooseSheikh = false;
  int currentPage = 1;
  int pageBeingCached = 1;
  List<int> downloadingZipFilesListForSheikh = [];
  List<String> zipFilesDownloadProgress = [];
  List<TafseerReadingModel> tafseersList = [
    TafseerReadingModel(
      tafseerCode: 'tafseerCode',
      tafseerNameArabic: ' tafseerNameArabic',
      tafseerNameEnglish: ' tafseerNameEnglish',
      tafseerImage: '',
      tafseerDescription: '',
      color: Colors.purple,
    )
  ];

  bool isDownloading = false;
  bool allowContinuousListening = false;

  String? appDirectory;
  late File logFile;
  late String currentReciterFolderPath;
  List<ReciterModel> recitersList = availableReciters
      .map((reciter) => ReciterModel.fromJson(reciter))
      .toList();
  ReciterModel? currentReciter;
  List<AyahModel> ayatPlayList = [];
  bool enablePlayInBackground = true;

  //* Methods

  Future<void> init() async {
    player = AudioPlayer();
    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    appDirectory = dir!.path;
    logFile = File("$appDirectory/download_log.txt")..createSync();
    var savedReciterId = sharedPreferences.getInt(AppStrings.savedReciterKey);
    if (savedReciterId != null) {
      currentReciter = availableReciters
          .map((reciter) => ReciterModel.fromJson(reciter))
          .toList()
          .where((element) => element.id == savedReciterId)
          .toList()
          .first;
    } else {
      currentReciter = availableReciters
          .map((reciter) => ReciterModel.fromJson(reciter))
          .toList()
          .first;
    }

    emit(ChangeCurrentReciterState(currentReciter!));
    currentReciterFolderPath =
        "${appDirectory!}/${encodeArabbicCharToEn(currentReciter!.nameEnglish.toString())}/";
    await Directory(currentReciterFolderPath).create();
    log("appDirectory=$appDirectory");
    log("defaultReciterFolderPath=$currentReciterFolderPath");
    setEnablePlayInBackground(
        sharedPreferences.getBool(AppStrings.enablePlayInBackgroundKey) ??
            true);
    _listenToPlayerIndex();
    _listenToPlayerState();
  }

  _listenToPlayerIndex() {
    player.currentIndexStream.listen((currentIndex) async {
      int currentPageNumber =
          AyahRenderBlocHelper.getCurrentPageUsingAyahAndSurahId(
        surahId: BottomWidgetService.surahId,
        ayahId: BottomWidgetService.ayahId,
      );
      if (currentIndex != null) {
        if (ayatPlayList.isNotEmpty) {
          if (ayatPlayList[currentIndex].page != currentPageNumber &&
              allowContinuousListening == false) {
            await _navigateToCurrentAyahPage(ayatPlayList[currentIndex].page ??
                ayatPlayList[currentIndex + 1].page!);
            await Future.delayed(const Duration(seconds: 1));
          }
          if (allowContinuousListening &&
              pageBeingCached == currentPageNumber) {
            pageBeingCached = currentPageNumber + 1;
            _startCachingNextPage(pageBeingCached);
          }

          //todo: emit a state containing the current playing ayah
          await addAyahToMediaItem(ayah: ayatPlayList[currentIndex]);
          if (ayatPlayList[currentIndex].surahNumber != null &&
              ayatPlayList[currentIndex].numberInSurah != null) {
            AyahRenderBlocHelper.colorAyaAndUpdateBloc(
              surahNumber: ayatPlayList[currentIndex].surahNumber!,
              ayahNumber: ayatPlayList[currentIndex].numberInSurah!,
            );
          }
          emit(ChangeHighlightedAyah(ayatPlayList[currentIndex]));
        }
      }
    });
  }

  _listenToPlayerState() {
    player.playerStateStream.distinct().listen((currentPlayerState) {
      log("🎵playerStateStream: playing=${currentPlayerState.playing}, proccessState=${currentPlayerState.processingState}");
      if ([ProcessingState.idle].contains(currentPlayerState.processingState)) {
        emit(PlayerStopped());
      } else if (currentPlayerState.processingState ==
          ProcessingState.completed) {
        if (allowContinuousListening &&
            state is! AudioDownloading &&
            state is! ChangeCurrentPageState &&
            state is! NavigateToCurrentAyahPageState) {
          int currentPageNumber =
              AyahRenderBlocHelper.getCurrentPageUsingAyahAndSurahId(
            surahId: BottomWidgetService.surahId,
            ayahId: BottomWidgetService.ayahId,
          );
          _navigateToCurrentAyahPage(currentPageNumber + 1);
          Future.delayed(const Duration(seconds: 0), () {
            listenToCurrentPage(repeatType: SectionRepeatType.continuous);
          });
          return;
        }
        player.stop();
      }
    });
  }

  Future<void> forceStopPlayer() async {
    await player.stop();
    emit(PlayerStopped());
  }

  void returnToControllersView() {
    emit(ListeningInitial());
    isToChooseRepeat = false;
    isToChooseSheikh = false;
  }

  void showChooseShiekh() {
    emit(ListeningInitial());
    isToChooseRepeat = false;
    isToChooseSheikh = true;
    emit(ShowShiekhViewState());
  }

  void showChooseRepeat() {
    emit(ListeningInitial());
    isToChooseSheikh = false;
    isToChooseRepeat = true;
    emit(ShowShiekhViewState());
  }

  Future<void> changeCurrentPage(int newPage) async {
    currentPage = newPage;
    pageBeingCached = newPage;
    emit(ChangeCurrentPageState(currentPage));
    log("ListeningCubit=> currentPage=$currentPage");

    // player.setLoopMode(LoopMode.all);
  }

  //* methods to handle downloading undownloaded files yet

  Future<Response?> downloadAyahMp3FileForDefaultReciter(
      {required AyahModel ayahModel}) async {
    return await dioConsumer
        .get(
            "${EndPoints.defualtReciterAyahFile}${ayahModel.surahNumber}/${ayahModel.numberInSurah}")
        .then((response) async {
      log("📩ListeningCubit=> get ${ayahModel.surahNumber}:${ayahModel.numberInSurah} metadata responseData= ${response.data}");
      if (response.statusCode == 200) {
        //todo: when success start downloading the file
        AyahSoundModel ayahSoundModel =
            AyahSoundModel.fromJson(jsonDecode(response.data));
        await downloadAyahFile(
            ayahModel: ayahModel,
            remoteFilePath: ayahSoundModel.file!,
            shiekhFolderPath: currentReciterFolderPath);
      } else {
        //todo: network error orr file path is not correct
      }
      return null;
    });
  }

  Future<File> downloadZipFile(
      String url, String reciterFolderPath, int reciterId) async {
    var dio = Dio();
    var dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    var zipFileName = '$reciterId' + url.split(RegExp(r'/')).last;
    File zipFile = File('${dir!.path}/$zipFileName');
    if (await zipFile.exists()) {
      debugPrint("File already downloaded");
      await zipFile.delete();
    }
    downloadingZipFilesListForSheikh.add(reciterId);
    zipFilesDownloadProgress.add("0 %");
    emit(AudioDownloading(value: "$reciterId"));
    var response = await dio.download(url, zipFile.path,
        onReceiveProgress: (received, total) {
      var percentage = (received / total * 100);
      zipFilesDownloadProgress[downloadingZipFilesListForSheikh
          .indexOf(reciterId)] = "${percentage.toStringAsFixed(2)} %";
      if (percentage == 100) {
        //todo: show unzipping icon [enhancement]
      }
      emit(AudioDownloading(value: "$percentage%$reciterId"));
      debugPrint("Downloading: $reciterId-${percentage.toStringAsFixed(2)}%");
    });
    await extractZipFile(zipFile, reciterFolderPath, reciterId);
    return zipFile;
  }

  Future<List<File>> extractZipFile(
    File zipFile,
    String reciterFolderPath,
    int? reciterId,
  ) async {
    try {
      var archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
      var mp3Files = <File>[];
      var dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
      var fileName = zipFile.path
          .split(RegExp(r'/'))
          .last
          .split('.')[0]; // get the zip file name
      var zipFolder = Directory(reciterFolderPath)
        ..createSync(
            recursive: true); // create the folder to store extracted files

      for (var file in archive) {
        if (file.isFile) {
          if (file.name.endsWith('.mp3')) {
            var fileName = file.name;
            var content = file.content;
            var newFile = File('${zipFolder.path}/$fileName');
            var parent = newFile.parent;
            if (!await parent.exists()) {
              await parent.create(recursive: true);
            }
            await newFile.writeAsBytes(content);
            mp3Files.add(newFile);
            debugPrint("📥ListeningCubit=> file extracted: ${newFile.path}");
          }
        } else if (await AppConstants.isDirectory(file.name)) {
          var dirName = file.name;
          var newDir = Directory('${zipFolder.path}/$dirName');
          if (!await newDir.exists()) {
            await newDir.create(recursive: true);
          }
        }
      }
      zipFilesDownloadProgress
          .removeAt(downloadingZipFilesListForSheikh.indexOf(reciterId!));
      downloadingZipFilesListForSheikh.remove(reciterId);
      emit(AudioDownloadSuccess(msg: "$reciterId"));
      zipFile..deleteSync(); //delete zip file after extracting
      return mp3Files;
    } catch (e) {
      debugPrint(e.toString());
      zipFilesDownloadProgress
          .removeAt(downloadingZipFilesListForSheikh.indexOf(reciterId!));
      downloadingZipFilesListForSheikh.remove(reciterId);
      emit(AudioDownloadError());
      throw Exception('Error extracting zip file: $e');
    }
  }

  Future<Response?> downloadAyahFile(
      {required AyahModel ayahModel,
      required String remoteFilePath,
      required String shiekhFolderPath,
      bool isPreCacheMode = false,
      bool isToEmitDownloading = true,
      bool isToEmitNoInternet = true}) async {
    String storagePath =
        "$shiekhFolderPath${encodeCorrectAyahFileNameToStoreLocally(ayahModel)}";
    if (File(storagePath).existsSync()) {
      return null;
    }
    if (!isPreCacheMode) {
      isDownloading = true;
    }
    emit(const AudioDownloading());
    Dio dio = Dio();
    final DioConsumer downloadConsumer = DioConsumer(client: dio);

    return downloadConsumer
        .download(
            remoteUrl: remoteFilePath,
            storagePath: storagePath,
            onRecieveProgress: (received, total) {
              if (total != -1 && isToEmitDownloading == true) {
                emit(AudioDownloading(value: (received / total).toString()));
                if ((received / total) == 1) {
                  String contents = logFile.readAsStringSync();
                  contents += '\n$storagePath';
                  logFile.writeAsStringSync(contents);
                  emit(const AudioDownloadSuccess());
                }
              }
            })
        .onError((e, _) {
      throw e!;
    }).catchError((e) {
      isDownloading = false;
      if (!isPreCacheMode) {
        forceStopPlayer();
      }
      if (isToEmitNoInternet) {
        emit(CheckYourNetworkConnectionState());
      }
      return Response(requestOptions: RequestOptions(path: remoteFilePath));
    });
  }

  String encodeCorrectAyahFileNameToStoreLocally(AyahModel ayahModel) {
    // todo: complete this to be like 001-002.mp3 for surah #1 and ayah #2
    String surahString = numberTo3DigitString(ayahModel.surahNumber!);
    String ayahString = numberTo3DigitString(ayahModel.numberInSurah!);
    return "$surahString/$surahString-$ayahString.mp3";
  }

  String numberTo3DigitString(num input) {
    String buffer = input.toInt().toString();
    buffer = buffer.length == 1
        ? "00$buffer"
        : buffer.length == 2
            ? "0$buffer"
            : buffer;
    return buffer;
  }

  String encodeRemoteMp3FilePath(AyahModel ayahModel,
      {int reciterId = 1, ReciterModel? reciter}) {
    String surahString = numberTo3DigitString(ayahModel.surahNumber!);
    String ayahString = numberTo3DigitString(ayahModel.numberInSurah!);
    return "${EndPoints.ayahMp3Path}/${reciter != null ? reciter.folderName! : currentReciter!.folderName}/$surahString/$surahString-$ayahString.mp3";
  }

  bool isAllFilesDownloaded(List<AyahModel> ayatInCurrentSection) {
    return ayatInCurrentSection.every((ayah) {
      String pathToCheck = File(
              "$currentReciterFolderPath${encodeCorrectAyahFileNameToStoreLocally(ayah)}")
          .path;
      return File(pathToCheck).existsSync();
    });
  }

  void setCurrentReciter(ReciterModel newReciter) async {
    emit(ListeningInitial());
    currentReciter = newReciter;
    sharedPreferences.setInt(AppStrings.savedReciterKey, newReciter.id!);
    currentReciterFolderPath =
        "${appDirectory!}/${encodeArabbicCharToEn(newReciter.nameEnglish.toString())}/";
    Directory(currentReciterFolderPath).createSync();
    player.stop();

    returnToControllersView();
    emit(ChangeCurrentReciterState(newReciter));
  }

  String getReciterFolderPath(reciterModel) {
    if (appDirectory != null) {
      return "${appDirectory!}/${encodeArabbicCharToEn(reciterModel.nameEnglish.toString())}/";
    } else {
      return '';
    }
  }

  void deleteAllFilesForReciter(
      {required ReciterModel reciterModel, required String reciterFolderPath}) {
    try {
      if (!Directory(reciterFolderPath).existsSync()) {
        emit(ReciterFilesDeleteError());
        emit(ListeningInitial());
        return;
      }
      if (currentReciter!.id == reciterModel.id) {
        player.stop();
      }
      Directory(reciterFolderPath).deleteSync(recursive: true);
      String contents = logFile.readAsStringSync();
      contents =
          contents.replaceAll(RegExp(r'' + reciterFolderPath + r'.*'), '');
      logFile.writeAsString(contents);
      emit(ReciterFilesDeletedSuccessfully(
          reciterFolderPath: reciterFolderPath));
    } catch (e) {
      emit(ReciterFilesDeleteError());
      emit(ListeningInitial());
    }
  }

  void downloadFullQuranForReciter(ReciterModel reciterModel) {}

  void listenToAyah({required AyahModel ayah}) {
    returnToControllersView();
    if (ayah.surahNumber != null && ayah.numberInSurah != null) {
      AyahRenderBlocHelper.colorAyaAndUpdateBloc(
        surahNumber: ayah.surahNumber!,
        ayahNumber: ayah.numberInSurah!,
      );
    }
    emit(ChangeHighlightedAyah(ayah));
    listenToCurrentPage(ayatForCustomRange: [ayah.number, ayah.number]);
  }

  void startListenFromAyah({required AyahModel ayah}) {
    if (ayah.surahNumber != null && ayah.numberInSurah != null) {
      AyahRenderBlocHelper.colorAyaAndUpdateBloc(
        surahNumber: ayah.surahNumber!,
        ayahNumber: ayah.numberInSurah!,
      );
    }
    emit(ChangeHighlightedAyah(ayah));
    listenToCurrentPage(
        repeatType: SectionRepeatType.continuous,
        ayatForCustomRange: [ayah.number, null]);
  }

  setEnablePlayInBackground(bool enabled) {
    enablePlayInBackground = enabled;
    sharedPreferences.setBool(AppStrings.enablePlayInBackgroundKey, enabled);
    log("enablePlayInBackground=$enablePlayInBackground");
    if (!enabled) {
    } else {}
    emit(ChangeEnablePlayInBackgroundState(enabled: enabled));
  }

  Future<void> addAyahToMediaItem({required AyahModel ayah}) async {
    if (!enablePlayInBackground) {
      playerHandler.mediaItem.close();

      return;
    }
    playerHandler.mediaItem.add(
      MediaItem(
          id: '',
          title:
              '${ayah.surah ?? ayatPlayList[ayatPlayList.indexOf(ayah) + 1].surah}',
          artist: "${currentReciter!.nameArabic}",
          artUri: await getImageFileFromAssets(AppAssets.appIcon)),
    );
  }

  void listenAccordingToType(
      {SectionRepeatType repeatType = SectionRepeatType.custom,
      int? sectionValue,
      List<int?> ayatForCustomRange = const [],
      int sectionRepeatCount = 1,
      int ayahRepeatCount = 1}) {}

  Future<void> listenToCurrentPage({
    SectionRepeatType repeatType = SectionRepeatType.custom,
    int? sectionValue,
    List<int?> ayatForCustomRange = const [null, null],
    int? sectionRepeatCount = 1,
    int? ayahRepeatCount = 1,
  }) async {
    int currentPageNumber =
        AyahRenderBlocHelper.getCurrentPageUsingAyahAndSurahId(
      surahId: BottomWidgetService.surahId,
      ayahId: BottomWidgetService.ayahId,
    );
    List<AyahModel> ayatRange = [];
    List<int> indeciesList = [];
    allowContinuousListening = false;

    if (repeatType == SectionRepeatType.custom) {
      int start =
          allAyat.indexWhere((ayah) => ayah.number == ayatForCustomRange.first);
      int end =
          allAyat.indexWhere((ayah) => ayah.number == ayatForCustomRange.last) +
              1;
      ayatRange = allAyat.getRange(start, end).toList();
    } else if (repeatType == SectionRepeatType.page) {
      ayatRange =
          allAyat.where((element) => element.page == sectionValue).toList();
    } else if (repeatType == SectionRepeatType.surah) {
      ayatRange = allAyat
          .where((element) => element.surahNumber == sectionValue)
          .toList();
    } else if (repeatType == SectionRepeatType.hizb) {
      List<int> qurtersInHizb = findQurtersInHizb(sectionValue!);
      ayatRange = allAyat
          .where((element) => qurtersInHizb.contains(element.hizbQuarter))
          .toList();
    } else if (repeatType == SectionRepeatType.juz) {
      ayatRange =
          allAyat.where((element) => element.juz == sectionValue).toList();
    } else if (repeatType == SectionRepeatType.continuous) {
      allowContinuousListening = true;
      ayahRepeatCount = null;
      sectionRepeatCount = null;

      if (ayatForCustomRange.first != null) {
        ayatRange = allAyat
            .where((element) =>
                element.page == currentPageNumber &&
                element.number! >= ayatForCustomRange.first!)
            .toList();
      } else {
        ayatRange = allAyat
            .where((element) => element.page == currentPageNumber)
            .toList();
      }
    }

    log("ListeningCubit=> we have ${ayatRange.length} ayahs in current page");

    if (ayatRange.any((ayah1) =>
        ayah1.numberInSurah == 1 && ![1, 9].contains(ayah1.surahNumber))) {
      for (int i = 0; i < ayatRange.length; i++) {
        if (ayatRange[i].numberInSurah == 1 &&
            ![1, 9].contains(ayatRange[i]..surahNumber)) {
          indeciesList.add(i);
        }
      }

      for (int occIndex in indeciesList) {
        ayatRange.insert(
            occIndex + indeciesList.indexOf(occIndex),
            AyahModel(
              number: 1,
              numberInSurah: 1,
              surahNumber: 1,
            ));
      }
    }
    await _navigateToCurrentAyahPage(currentPageNumber
        // ayatRange.first.page ?? ayatRange[1].page!,
        );

    ///todos:
    ///1-first check if the file exists already if YES add to the playList, else download it and then add it to the playList
    ///2- after you made sure that all files are existing then play the playList

    log("⌚ListeningCubit=> still not all the files found");
    bool isFilesDownloaded = isAllFilesDownloaded(ayatRange);

    if (!isFilesDownloaded) {
      if (!await internetConnectionChecker.hasConnection) {
        isDownloading = false;
        forceStopPlayer();
        emit(CheckYourNetworkConnectionState());
        return;
      }
      await Future.forEach(ayatRange, (ayah) async {
        await downloadAyahFile(
            ayahModel: ayah,
            remoteFilePath: encodeRemoteMp3FilePath(ayah),
            shiekhFolderPath: currentReciterFolderPath);
      });
    }

    isFilesDownloaded = isAllFilesDownloaded(ayatRange);

    late ConcatenatingAudioSource playList;

    if (isFilesDownloaded) {
      isDownloading = false;
      //* repeat  ayat
      if (ayahRepeatCount != null) {
        List<AyahModel> repeatedAyatList = [];
        for (final ayah in ayatRange) {
          if (ayah.page == null) {
            repeatedAyatList.add(ayah);
            continue;
          }
          for (int i = 0; i < ayahRepeatCount; i++) {
            repeatedAyatList.add(ayah);
          }
        }
        ayatRange = repeatedAyatList;
      }

      //* repeat  section
      if (sectionRepeatCount != null) {
        List<AyahModel> repeatedSectionsList = [];
        for (int i = 0; i < sectionRepeatCount; i++) {
          repeatedSectionsList.addAll(ayatRange);
        }

        ayatRange = repeatedSectionsList;
      }

      ayatPlayList = ayatRange;
      playList = ConcatenatingAudioSource(
        useLazyPreparation: false,
        children: [
          for (AyahModel ayah in ayatRange)
            AudioSource.uri(
              File("$currentReciterFolderPath${encodeCorrectAyahFileNameToStoreLocally(ayah)}")
                  .uri,
            ),
        ],
      );
      AyahModel? ayahToPlay;
      int index = 0;
      int playingIndex = 0;
      for (final AyahModel ayah in ayatRange) {
        if (ayah.numberInSurah == BottomWidgetService.ayahId) {
          ayahToPlay = ayah;
          playingIndex = index;
        }
        index = index + 1;
      }
      if (ayahToPlay != null) {
        AyahRenderBlocHelper.colorAyaAndUpdateBloc(
          surahNumber: ayahToPlay.surahNumber!,
          ayahNumber: ayahToPlay.numberInSurah!,
        );
        emit(ChangeHighlightedAyah(ayahToPlay));
        addAyahToMediaItem(ayah: ayahToPlay);
        await player.setAudioSource(
          playList,
          preload: true,
          initialIndex: playingIndex,
        );
        if (ayahToPlay.page != currentPageNumber) {
          await _navigateToCurrentAyahPage(
              ayahToPlay.page ?? ayatRange[1].page!);
        }
      } else {
        if (ayatRange[0].surahNumber != null &&
            ayatRange[0].numberInSurah != null) {
          AyahRenderBlocHelper.colorAyaAndUpdateBloc(
            surahNumber: ayatRange[0].surahNumber!,
            ayahNumber: ayatRange[0].numberInSurah!,
          );
        }
        emit(ChangeHighlightedAyah(ayatRange[0]));
        addAyahToMediaItem(ayah: ayatPlayList[0]);

        await player.setAudioSource(playList, preload: true);
        if (ayatRange.first.page != currentPageNumber) {
          await _navigateToCurrentAyahPage(
              ayatRange.first.page ?? ayatRange[1].page!);
        }
      }
      await player.play();
    } else {
      log("😭Not all files downloaded yet");
    }
  }

  List<int> findQurtersInHizb(int hizb) {
    int firstQuarterInHizb = hizb * 4 - 4 + 1;
    List<int> qurters =
        List<int>.generate(4, (index) => index + firstQuarterInHizb);
    return qurters;
  }

  _navigateToCurrentAyahPage(int ayahPage) async {
    int pageToNavigate = ayahPage;
    if (ResponsiveFrameworkHelper().isTwoPaged()) {
      pageToNavigate = (ayahPage / 2).ceil();
    }
    emit(NavigateToCurrentAyahPageState(page: pageToNavigate));
    await Future.delayed(const Duration(seconds: 1));
  }

  void _startCachingNextPage(int pageToCache) async {
    if (pageToCache > 604) {
      return;
    } else {
      List<AyahModel> ayatInPageToCache =
          allAyat.where((element) => element.page == pageToCache).toList();
      log("caching started on page=$pageToCache");

      await Future.forEach(ayatInPageToCache, (ayah) async {
        if (!await internetConnectionChecker.hasConnection) {
          isDownloading = false;

          return;
        }
        await downloadAyahFile(
          ayahModel: ayah,
          remoteFilePath: encodeRemoteMp3FilePath(ayah),
          shiekhFolderPath: currentReciterFolderPath,
          isPreCacheMode: true,
        );
      });
    }
  }

  Future<Uri> getImageFileFromAssets(String assetArt) async {
    final byteData = await rootBundle.load(assetArt);
    final buffer = byteData.buffer;
    Directory tempDir = Platform.isAndroid
        ? (await getExternalStorageDirectory())!
        : await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath +
        '/audio-icon.png'; // file_01.tmp is dump file, can be anything
    if (File(filePath).existsSync()) {
      return File(filePath).uri;
    } else {
      return (await File(filePath).writeAsBytes(buffer.asUint8List(
              byteData.offsetInBytes, byteData.lengthInBytes)))
          .uri;
    }
  }

  Future<bool?>? downloadAyahbyAyah(
      ReciterModel reciterModel, String reciterFolderPath) async {
    if (downloadingZipFilesListForSheikh.isNotEmpty) {
      emit(WaitUntilDownloadFininsh());
      emit(ListeningInitial());
      return false;
    }
    if (!await internetConnectionChecker.hasConnection) {
      isDownloading = false;
      forceStopPlayer();
      downloadingZipFilesListForSheikh.clear();
      zipFilesDownloadProgress.clear();
      emit(CheckYourNetworkConnectionState());
      return false;
    } else {
      downloadingZipFilesListForSheikh.add(reciterModel.id!);
      zipFilesDownloadProgress.add("0");
      List<int> pages = List<int>.generate(604, (index) => index + 1);

      for (int pageCounter in pages) {
        if (!await internetConnectionChecker.hasConnection) {
          isDownloading = false;

          downloadingZipFilesListForSheikh.clear;
          zipFilesDownloadProgress.clear();
          emit(CheckYourNetworkConnectionState());
          pages = [];
          await Future.delayed(const Duration(seconds: 1));
          break;
        }
        if (downloadingZipFilesListForSheikh.isNotEmpty &&
            zipFilesDownloadProgress.isNotEmpty) {
          zipFilesDownloadProgress[downloadingZipFilesListForSheikh
              .indexOf(reciterModel.id!)] = "$pageCounter";
        }

        emit(ShiekhMp3PageDownloadCounterChanged(pageCounter));
        var ayatForPage =
            allAyat.where((element) => element.page == pageCounter).toList();
        await Future.wait([
          for (var ayah in ayatForPage)
            downloadAyahFile(
                ayahModel: ayah,
                remoteFilePath:
                    encodeRemoteMp3FilePath(ayah, reciter: reciterModel),
                shiekhFolderPath: reciterFolderPath,
                isToEmitDownloading: false,
                isToEmitNoInternet: false,
                isPreCacheMode: true),
        ]);
        await Future.delayed(const Duration(seconds: 1));
      }

      log("completed name ${reciterModel.nameEnglish}");
      zipFilesDownloadProgress.clear();
      downloadingZipFilesListForSheikh.clear();

      emit(const ShiekhMp3PageDownloadCounterChanged(605));
    }
    return null;
  }

  void pausePlayer() async {
    if (player.playing) {
      player.pause();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}
