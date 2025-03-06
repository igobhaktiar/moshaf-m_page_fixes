import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qeraat_moshaf_kwait/config/dark_theme.dart';
import 'package:qeraat_moshaf_kwait/config/themes/light_theme.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/screens/theme_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/downloader/presentation/cubit/downloader_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/lock_screen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/search_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/tafseer_font_size_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zooming_bloc/zooming_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/cubit/external_libraries_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/khatmat/presentation/cubit/khatmat_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_two_page_render_bloc/ayah_two_page_render_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/display_on_startup_cubit/display_on_start_up_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/moshaf_background_color_cubit/moshaf_background_color_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/quran_details_cubit/quran_details_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/reciter_image_cubit/reciter_image_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/show_juz_popup/show_juz_popup_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_cubit/qanda_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qeerat/cubit/qeera_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/presentation/cubit/translation_page/translation_page_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/splash/presentation/screens/cover_screen.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/reciters_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/surah_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/tafseer/presentation/cubit/tafseer_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart' as di;

import 'config/app_config/app_config.dart';
import 'core/responsiveness/responsive_framework_helper.dart';
import 'core/responsiveness/route_animation.dart';
import 'features/about_app/presentation/cubit/about_app_cubit.dart';
import 'features/bookmarks/presentation/cubit/ayah_mini_dialog_cubit/ayah_mini_dialog_cubit.dart';
import 'features/bookmarks/presentation/cubit/share_cubit/share_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'features/main/presentation/cubit/ayat_menu_control_cubit/ayat_menu_control_cubit.dart';
import 'features/privacy_policy/presentation/cubit/privacy_policy_cubit.dart';
import 'features/qanda/presentation/cubit/fetched_questions_cubit/fetched_questions_cubit.dart';
import 'features/tafseer/presentation/cubit/tafseer_page/tafseer_page_cubit.dart';
import 'features/terms_and_conditions/presentation/cubit/terms_and_conditions_cubit.dart';
import 'injection_container.dart';
import 'navigation_service.dart';

class MoshafAlqeraatApp extends StatefulWidget {
  const MoshafAlqeraatApp({Key? key}) : super(key: key);

  @override
  State<MoshafAlqeraatApp> createState() => _MoshafAlqeraatAppState();
}

class _MoshafAlqeraatAppState extends State<MoshafAlqeraatApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ResponsiveFrameworkHelper responsiveFrameworkHelper =
        ResponsiveFrameworkHelper();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => di.getItInstance<EssentialMoshafCubit>()),
        BlocProvider(create: (context) => di.getItInstance<FontSizeCubit>()),
        BlocProvider(create: (context) => di.getItInstance<LangCubit>()),
        BlocProvider(create: (context) => di.getItInstance<SearchCubit>()),
        BlocProvider(create: (context) => di.getItInstance<NotesCubit>()),
        BlocProvider(create: (context) => di.getItInstance<QeraatCubit>()),
        BlocProvider(create: (context) => di.getItInstance<LockScreenCubit>()),
        BlocProvider(create: (context) => di.getItInstance<JuzPopupCubit>()),
        BlocProvider(create: (context) => BottomSheetCubit()),
        BlocProvider(create: (context) => di.getItInstance<BookmarksCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<AyatHighlightCubit>()),
        BlocProvider(create: (context) => di.getItInstance<ThemeCubit>()),
        BlocProvider(create: (context) => di.getItInstance<ZoomCubit>()),
        BlocProvider(create: (context) => di.getItInstance<DownloaderCubit>()),
        BlocProvider(create: (context) => di.getItInstance<KhatmatCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<ExternalLibrariesCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<ListeningCubit>()..init()),
        BlocProvider(create: (context) => di.getItInstance<RecitersCubit>()),
        BlocProvider(create: (context) => di.getItInstance<SurahCubit>()),
        BlocProvider(create: (context) => di.getItInstance<SurahListenCubit>()),
        BlocProvider(create: (context) => di.getItInstance<PlaylistCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<PlaylistSurahCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<PlaylistSurahListenCubit>()),
        BlocProvider(create: (context) => di.getItInstance<TenReadingsCubit>()),
        BlocProvider(create: (context) => di.getItInstance<TafseerCubit>()),
        BlocProvider(
            create: (context) =>
                di.getItInstance<AboutAppCubit>()..getContentOfAboutApp()),
        BlocProvider(
            create: (context) => di.getItInstance<TermsAndConditionsCubit>()
              ..getTermsAndConditions()),
        BlocProvider(
            create: (context) =>
                di.getItInstance<PrivacyPolicyCubit>()..getPrivacyPolicy()),
        BlocProvider(
            create: (context) => di.getItInstance<AyatMenuControlCubit>()),
        BlocProvider(create: (context) => di.getItInstance<ShareCubit>()),
        BlocProvider(
            create: (context) =>
                di.getItInstance<MoshafBackgroundColorCubit>()),
        BlocProvider(
            create: (context) =>
                di.getItInstance<DisplayOnStartUpCubit>()..init()),
        BlocProvider(
            create: (context) => di.getItInstance<ReciterImageCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<QuranDetailsCubit>()),
        BlocProvider(create: (context) => di.getItInstance<AyahRenderBloc>()),
        BlocProvider(
            create: (context) => di.getItInstance<AyahTwoPageRenderBloc>()),
        BlocProvider(create: (context) => di.getItInstance<ZoomingBloc>()),
        BlocProvider(create: (context) => di.getItInstance<TafseerPageCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<TranslationPageCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<AyahMiniDialogCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<BottomWidgetCubit>()
              ..setBottomWidgetState(
                false,
                scrollDownTopPage: false,
              )),
        BlocProvider(
          create: (context) =>
              di.getItInstance<FetchedQuestionsCubit>()..init(),
        ),
        BlocProvider(
          create: (context) => di.getItInstance<QandaCubit>()..init(),
        ),
      ],
      child: BlocBuilder<LangCubit, LangState>(
        builder: (context, state) {
          return BlocConsumer<ThemeCubit, ThemeState>(
            listener: (BuildContext context, ThemeState state) {
              if (state.brightness == Brightness.light) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: AppColors.primary,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarContrastEnforced: true,
                  statusBarBrightness: Brightness.light,
                ));
              } else {
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.light,
                      systemNavigationBarIconBrightness: Brightness.dark,
                      systemNavigationBarColor: Colors.white
                      // systemNavigationBarContrastEnforced: true,
                      ),
                );
              }
            },
            builder: (BuildContext context, ThemeState themeState) {
              // Control device preview options visiblity, put [!kReleaseMode] to ensure it wonn't render when releaasse mode
              return DevicePreview(
                enabled: AppConfig.getDebuggingStatus(),
                builder: (BuildContext context) => MaterialApp(
                  title: AppStrings.appName,
                  debugShowCheckedModeBanner: false,
                  color: AppColors.primary,
                  builder: (context, child) =>
                      responsiveFrameworkHelper.responsiveBreakpointsBuilder(
                    DevicePreview.appBuilder(
                      context,
                      child,
                    ),
                  ),
                  onGenerateRoute: (RouteSettings settings) {
                    return Routes.fadeThrough(
                      settings,
                      (context) {
                        return responsiveFrameworkHelper
                            .responsiveFrameworkMaxWidthBox(
                          context,
                          const CoverScreen(),
                        );
                      },
                    );
                  },
                  // ignore: deprecated_member_use
                  navigatorKey:
                      getItInstance<NavigationService>().navigationKey,
                  useInheritedMediaQuery: true,
                  locale: state.locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localeResolutionCallback:
                      (Locale? locale, Iterable<Locale> supportedLocales) {
                    // Check if the current device locale is supported
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode ==
                              locale?.languageCode ||
                          supportedLocale.countryCode == locale?.countryCode) {
                        return supportedLocale;
                      }
                    }
                    // If the locale of the device is not supported, use the first one
                    // from the list (English, in this case).
                    return supportedLocales.first;
                  },
                  theme: appLightTheme(),
                  darkTheme: appDarkTheme(),
                  themeMode: themeState.brightness == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: const CoverScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
