import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/language_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';

import '../../../../core/utils/constants.dart';

class DrawerConstants {
  DrawerConstants._();

  //Drawer Generic Height && Width
  static const double hh = 14.0;
  static const double vv = 5.0;

  static void closeDrawer() {
    if (LanguageService.isLanguageRtl(AppContext.getAppContext()!)) {
      AppConstants.moshafScaffoldKey.currentState?.closeDrawer();
    } else {
      AppConstants.moshafScaffoldKey.currentState?.closeEndDrawer();
    }
  }

  static void openDrawer() {
    if (LanguageService.isLanguageRtl(AppContext.getAppContext()!)) {
      AppConstants.moshafScaffoldKey.currentState?.openDrawer();
    } else {
      AppConstants.moshafScaffoldKey.currentState?.openEndDrawer();
    }
    BottomWidgetCubit.get(AppContext.getAppContext()!)
        .setBottomWidgetState(false);
  }

  //Drawer Font
  static TextStyle drawerTextStyle() {
    return const TextStyle(
      fontFamily: 'cairo',
      fontSize: 16,
    );
  }

  static final Map<dynamic, dynamic> navigateFromDrawerArguments = {
    'navigateFrom': 'MoshafDrawer'
  };

  static bool activeDefaultBackButton(BuildContext context) {
    bool onPressedActive = true;
    final Map<dynamic, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
    if (args != null &&
        args['navigateFrom'] != null &&
        args['navigateFrom'] == 'MoshafDrawer') {
      onPressedActive = false;
    }
    return onPressedActive;
  }

  //Drawer Assets

  static const String drawerFolderPath = 'assets/drawer_icons/';
  static const String drawerHeaderBackground = "${drawerFolderPath}menuybg.jpg";
  static const String drawerLogo = "${drawerFolderPath}logo.png";
  static const String drawerQuranIcon = '${drawerFolderPath}mushafinfo.png';
  static const String drawerIndexIcon =
      '${drawerFolderPath}ic_format_list_bulleted_black_48dp.png';
  static const String drawerSearchIcon =
      '${drawerFolderPath}ic_search_black_48dp.png';
  static const String drawerFavouriteIcon =
      '${drawerFolderPath}ic_favourite_star_black.png';
  static const String drawerCommasIcon =
      '${drawerFolderPath}ic_bookmark_black_48dp.png';
  static const String drawerRecitationIcon =
      '${drawerFolderPath}ic_volume_down_black_48dp.png';
  static const String drawerLibraryIcon = '${drawerFolderPath}tafisr.png';
  static const String drawerTafseerIcon = '${drawerFolderPath}tafseer.png';
  static const String drawerTranslateIcon =
      '${drawerFolderPath}ic_translate_black_48dp.png';
  static const String drawerKhatmaIcon = '${drawerFolderPath}khatma.png';
  static const String drawerQuranRecitationIcon =
      '${drawerFolderPath}63206-200.png';
  static const String drawerSuppllicationOfCompletionIcon =
      '${drawerFolderPath}84660.png';
  static const String drawerIntroductionToHolyQuranIcon =
      '${drawerFolderPath}certified.png';
  static const String drawerSettingsIcon =
      '${drawerFolderPath}ic_build_black_48dp.png';
  static const String drawerInstructionsIcon =
      '${drawerFolderPath}ic_help_48pt_3x.png';
  static const String drawerAboutIcon =
      '${drawerFolderPath}ic_info_48pt_3x.png';
  static const String playlistIcon = '${drawerFolderPath}playlist.png';
  static const String namesIcon = '${drawerFolderPath}names.png';
  static const String qAIcon = '${drawerFolderPath}q-and-a.png';
}
