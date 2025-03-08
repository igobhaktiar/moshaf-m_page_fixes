// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qeraat_moshaf_kwait/app.dart';
import 'package:qeraat_moshaf_kwait/core/models/content_value.dart';

import 'config/app_config/app_config.dart';
import 'config/app_config/environment_flavors.dart';
import 'core/data_sources/database_service.dart';
import 'core/models/content.dart';
import 'core/utils/app_strings.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  FlutterNativeSplash.remove();

  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    AppConfig.init(
      environment: EnvironmentFlavours.development,
      appVersionToShow: '3.0.37+63',
      debuggingEnabled: false,
      isQeerat: false,
    );

    await DatabaseService.initializeShamelDb();
    await DatabaseService.cleanupOldCache();
    //DownloadService.init();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    await Hive.initFlutter();
    await di.init();
    Hive.registerAdapter<ContentValue>(ContentValueAdapter());
    Hive.registerAdapter<Content>(ContentAdapter());
    await Hive.openBox(AppStrings.aboutApp);
    await Hive.openBox(AppStrings.termsAndConditions);
    await Hive.openBox(AppStrings.privacyPolicy);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

    BlocOverrides.runZoned(
      () {
        runApp(const MoshafAlqeraatApp());
      },
      blocObserver: null,
    );
  }, (error, stack) => {});
}
