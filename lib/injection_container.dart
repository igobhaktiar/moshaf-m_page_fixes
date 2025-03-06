import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/tafseer_font_size_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zooming_bloc/zooming_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_two_page_render_bloc/ayah_two_page_render_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/display_on_startup_cubit/display_on_start_up_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/show_juz_popup/show_juz_popup_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_cubit/qanda_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qeerat/cubit/qeera_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/app_interceptors.dart';
import 'core/api/dio_consumer.dart';
import 'core/api/end_points.dart';
import 'core/utils/app_colors.dart';
import 'core/utils/app_strings.dart';
import 'core/utils/audio_handler.dart';
import 'features/about_app/about_app_injection_container.dart';
import 'features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'features/bookmarks/data/models/bookmark_model.dart';
import 'features/bookmarks/presentation/cubit/ayah_mini_dialog_cubit/ayah_mini_dialog_cubit.dart';
import 'features/bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import 'features/bookmarks/presentation/cubit/share_cubit/share_cubit.dart';
import 'features/bookmarks/presentation/screens/theme_cubit.dart';
import 'features/downloader/presentation/cubit/downloader_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/lock_screen_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/search_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_cubit.dart';
import 'features/externalLibraries/presentation/cubit/external_libraries_cubit.dart';
import 'features/khatmat/data/models/khatmah_model.dart';
import 'features/khatmat/presentation/cubit/khatmat_cubit.dart';
import 'features/listening/presentation/cubit/listening_cubit.dart';
import 'features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc.dart';
import 'features/main/presentation/cubit/ayat_menu_control_cubit/ayat_menu_control_cubit.dart';
import 'features/main/presentation/cubit/moshaf_background_color_cubit/moshaf_background_color_cubit.dart';
import 'features/main/presentation/cubit/quran_details_cubit/quran_details_cubit.dart';
import 'features/main/presentation/cubit/reciter_image_cubit/reciter_image_cubit.dart';
import 'features/notes/data/model/notes_model.dart';
import 'features/notes/presentation/cubit/notes_cubit.dart';
import 'features/playlist/presentation/cubit/playlist_cubit.dart';
import 'features/privacy_policy/privacy_policy_injection_container.dart';
import 'features/qanda/presentation/cubit/fetched_questions_cubit/fetched_questions_cubit.dart';
import 'features/quran_translation/presentation/cubit/translation_page/translation_page_cubit.dart';
import 'features/surah/presentation/cubit/reciters_cubit.dart';
import 'features/surah/presentation/cubit/surah_cubit.dart';
import 'features/surah/presentation/cubit/surah_listen_cubit.dart';
import 'features/tafseer/presentation/cubit/tafseer_cubit.dart';
import 'features/tafseer/presentation/cubit/tafseer_page/tafseer_page_cubit.dart';
import 'features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'features/terms_and_conditions/terms_and_conditions_injection_container.dart';
import 'navigation_service.dart';

final getItInstance = GetIt.instance;
// final GetIt i = GetIt.I;
// final GetIt i = GetIt.I;

Future<void> init() async {
  // Inititate Hive boxes
  await Hive.initFlutter();
  Hive.registerAdapter(BookmarkModelAdapter());
  Hive.registerAdapter(KhatmahModelAdapter());
  Hive.registerAdapter(WerdModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox(AppStrings.bookmarksBox);
  await Hive.openBox(AppStrings.notesBox);
  await Hive.openBox(AppStrings.favouritesBox);
  await Hive.openBox<KhatmahModel>(AppStrings.khatmatBox);

  //* CUBITS
  getItInstance
      .registerFactory<EssentialMoshafCubit>(() => EssentialMoshafCubit(
            sharedPreferences: getItInstance(),
          )..init());
  getItInstance.registerFactory<FontSizeCubit>(
    () => FontSizeCubit(sharedPreferences: getItInstance())..init(),
  );

  getItInstance.registerFactory<LangCubit>(
      () => LangCubit(sharedPreferences: getItInstance())..init());
  getItInstance
      .registerFactory<QeraatCubit>(() => QeraatCubit()..initializeQeraaList());
// Register QeraatCubit
  getItInstance.registerFactory<SearchCubit>(
      () => SearchCubit(sharedPreferences: getItInstance())..getLastSearch());
  getItInstance.registerFactory<BookmarksCubit>(
      () => BookmarksCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<LockScreenCubit>(
      () => LockScreenCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<JuzPopupCubit>(
      () => JuzPopupCubit(sharedPreferences: getItInstance())..init());
  getItInstance
      .registerFactory<AyatHighlightCubit>(() => AyatHighlightCubit()..init());
  getItInstance.registerFactory<ZoomCubit>(
      () => ZoomCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<ThemeCubit>(
      () => ThemeCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<DownloaderCubit>(() => DownloaderCubit(
        dioConsumer: getItInstance(),
        sharedPreferences: getItInstance(),
      ));
  getItInstance.registerFactory<NotesCubit>(() => NotesCubit(
        sharedPreferences: getItInstance(),
      )..init()); // Register NotesCubit
  getItInstance.registerFactory<ShareCubit>(() => ShareCubit()..init());

  getItInstance.registerFactory<ExternalLibrariesCubit>(() =>
      ExternalLibrariesCubit(
          dioConsumer: getItInstance(),
          internetConnectionChecker: getItInstance())
        ..initExternalLibrariesCubit());

  getItInstance.registerFactory<KhatmatCubit>(
      () => KhatmatCubit(sharedPreferences: getItInstance())..init());

  getItInstance.registerFactory<ListeningCubit>(() => ListeningCubit(
      dioConsumer: getItInstance(),
      playerHandler: getItInstance(),
      player: getItInstance(instanceName: "quranPlayer"),
      sharedPreferences: getItInstance(),
      internetConnectionChecker: getItInstance())
    ..init());

  getItInstance.registerFactory<RecitersCubit>(() => RecitersCubit(
        sharedPreferences: getItInstance(),
      ));

  getItInstance.registerFactory<SurahCubit>(() => SurahCubit());

  getItInstance.registerFactory<SurahListenCubit>(() => SurahListenCubit(
        playerHandler: getItInstance(),
        player: getItInstance(instanceName: "quranPlayer"),
      ));

  getItInstance.registerFactory<PlaylistCubit>(() => PlaylistCubit());
  getItInstance.registerFactory<PlaylistSurahCubit>(() => PlaylistSurahCubit());

  getItInstance
      .registerFactory<PlaylistSurahListenCubit>(() => PlaylistSurahListenCubit(
            player: getItInstance(instanceName: "quranPlayer"),
          ));

  getItInstance.registerFactory<TenReadingsCubit>(() => TenReadingsCubit(
      dioConsumer: getItInstance(),
      player: getItInstance(instanceName: "tenReadingsPlayer"),
      internetConnectionChecker: getItInstance())
    ..init());

  getItInstance.registerFactory<TafseerCubit>(() => TafseerCubit()..init());

  getItInstance.registerFactory<AyatMenuControlCubit>(
      () => AyatMenuControlCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<MoshafBackgroundColorCubit>(() =>
      MoshafBackgroundColorCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<DisplayOnStartUpCubit>(
      () => DisplayOnStartUpCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<ReciterImageCubit>(
      () => ReciterImageCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<QuranDetailsCubit>(
      () => QuranDetailsCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<AyahRenderBloc>(
      () => AyahRenderBloc()..add(FetchInitialPage()));
  getItInstance.registerFactory<AyahTwoPageRenderBloc>(
      () => AyahTwoPageRenderBloc()..add(FetchInitialTwoPages()));
  getItInstance.registerFactory<TafseerPageCubit>(
      () => TafseerPageCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<TranslationPageCubit>(
      () => TranslationPageCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<BottomWidgetCubit>(() => BottomWidgetCubit());
  getItInstance
      .registerFactory<AyahMiniDialogCubit>(() => AyahMiniDialogCubit());
  //* Q and A
  getItInstance
      .registerFactory<FetchedQuestionsCubit>(() => FetchedQuestionsCubit());
  getItInstance.registerFactory<ZoomingBloc>(() => ZoomingBloc());
  getItInstance.registerFactory<QandaCubit>(
      () => QandaCubit(sharedPreferences: getItInstance())..init());

  //* features
  initPrivacyPolicyFeature();
  initTermsAndConditionsFeature();
  initAboutAppFeature();

  //* Core
  getItInstance.registerLazySingleton<DioConsumer>(
      () => DioConsumer(client: getItInstance()));
  getItInstance.registerLazySingleton(() => NavigationService());

  //* EXTERNAL
  const BuildTarget buildTarget = BuildTarget.PRODUCTION;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final sharedPreferences = await SharedPreferences.getInstance();
  final player = AudioPlayer();

  final tenReadingsPlayer = AudioPlayer();

  player.playbackEventStream.listen((event) {});

  final InternetConnectionChecker internetConnectionCheckerInstance =
      InternetConnectionChecker.createInstance(addresses: [
    AddressCheckOptions(address: InternetAddress("8.8.8.8"))
  ]);

  getItInstance.registerLazySingleton(() => buildTarget);
  final appIntercepters = AppIntercepters();
  getItInstance.registerLazySingleton(() => sharedPreferences);
  getItInstance.registerLazySingleton(() => player,
      instanceName: "quranPlayer");
  final playerHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(
          player: getItInstance(instanceName: "quranPlayer")),
      config: const AudioServiceConfig(
        androidNotificationIcon: "drawable/app_icon",
        // androidShowNotificationBadge: fals,
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        notificationColor: AppColors.primary,
        androidNotificationOngoing: true,
      ));
  getItInstance.registerLazySingleton(() => playerHandler);
  getItInstance.registerLazySingleton(() => internetConnectionCheckerInstance);
  getItInstance.registerLazySingleton(() => flutterLocalNotificationsPlugin);

  getItInstance.registerLazySingleton(() => tenReadingsPlayer,
      instanceName: "tenReadingsPlayer");

  getItInstance.registerLazySingleton(() => appIntercepters);
  getItInstance.registerLazySingleton(() => LogInterceptor(
      request: true,
      requestBody: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: true,
      error: true));

  getItInstance.registerLazySingleton(() => Dio());
}
