import 'dart:io';

import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/show_juz_popup/show_juz_popup_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application_platforms.dart';
import 'environment_flavors.dart';

class AppConfig {
  static late final EnvironmentFlavours _environment;
  static late final String _serverUrl;
  static late final String _serverApiUrl;
  static late final String _serverImageUrl;
  static late final String _serverSocketUrl;
  static const String _baseUrlProduction = 'https://production_url/';
  static const String _baseUrlStaging = 'https://staging_url/';
  static const String _baseUrlDevelopment = 'https://development_url/';
  static const String _baseUrlNotFound = 'none';

  static const String _apiUrlExtension = 'api/';
  static const String _imageUrlExtension = 'https://url/images/';
  static const String _socketUrlExtension = 'socket';

  static late final String _appVersionToShow;
  static const String _appNameBeta = 'V: BetaDev-';
  static const String _appNameStaging = 'V: Beta-';
  static const String _appNameProduction = 'V: ';

  static late final bool _debuggingEnabled;
  static late final bool _isQeerat;

  static late final ApplicationPlatforms _appOperatingSystem;

  static void init({
    required EnvironmentFlavours environment,
    required String appVersionToShow,
    bool debuggingEnabled = false,
    bool isQeerat = false,
  }) {
    _environment = environment;
    if (_environment == EnvironmentFlavours.development) {
      _appVersionToShow = _appNameBeta + appVersionToShow;
      _serverUrl = _baseUrlDevelopment;
    } else if (_environment == EnvironmentFlavours.staging) {
      _appVersionToShow = _appNameStaging + appVersionToShow;
      _serverUrl = _baseUrlStaging;
    } else if (_environment == EnvironmentFlavours.production) {
      _appVersionToShow = _appNameProduction + appVersionToShow;
      _serverUrl = _baseUrlProduction;
    } else {
      _appVersionToShow = appVersionToShow;
      _serverUrl = _baseUrlNotFound;
    }

    _serverApiUrl = _serverUrl + _apiUrlExtension;
    _serverImageUrl = _imageUrlExtension;
    // _serverImageUrl = _serverUrl + _imageUrlExtension;
    _serverSocketUrl = _serverUrl + _socketUrlExtension;

    if (Platform.isAndroid) {
      _appOperatingSystem = ApplicationPlatforms.ANDROID;
    } else if (Platform.isIOS) {
      _appOperatingSystem = ApplicationPlatforms.IOS;
    } else if (Platform.isFuchsia ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isWindows) {
      _appOperatingSystem = ApplicationPlatforms.WEB;
    } else {
      _appOperatingSystem = ApplicationPlatforms.OTHER;
    }

    _debuggingEnabled = debuggingEnabled;
    _isQeerat = isQeerat;
  }

  static EnvironmentFlavours getEnvironment() {
    return _environment;
  }

  static ApplicationPlatforms getAppPlatform() {
    return _appOperatingSystem;
  }

  static String getAppVersionToShow() {
    return _appVersionToShow;
  }

  static String getImageUrl() {
    return _serverImageUrl;
  }

  static String getApiUrl() {
    return _serverApiUrl;
  }

  static String getSocketUrl() {
    return _serverSocketUrl;
  }

  static bool getDebuggingStatus() {
    return _debuggingEnabled;
  }

  static bool isQeeratView() {
    return _isQeerat;
  }

  static Future<void> executeByEnvironment({
    Future<void> Function()? developmentFunction,
    Future<void> Function()? stagingFunction,
    Future<void> Function()? productionFunction,
  }) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    // Initialize the global instance
    await JuzPopupCubit.initializeJuzPopupCubit(sharedPreferences);
    if (_environment == EnvironmentFlavours.development &&
        developmentFunction != null) {
      await developmentFunction();
    }
    if (_environment == EnvironmentFlavours.staging &&
        stagingFunction != null) {
      await stagingFunction();
    }
    if (_environment == EnvironmentFlavours.production &&
        productionFunction != null) {
      await productionFunction();
    }
  }
}
