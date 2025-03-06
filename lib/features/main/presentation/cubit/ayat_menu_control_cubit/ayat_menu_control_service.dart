// If another ayatmenu is added in the future it must be added in this enum
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ayat_menu_control_cubit.dart';

enum AyatMenu {
  compact,
  expanded,
}

abstract class AyatMenuControlService {
  AyatMenuControlService._();

  //You can change Default Ayatmenu from here
  static AyatMenu defaultAyatMenu = AyatMenu.expanded;

  // If another ayatmenu is added in the future it must be added in this
  // dictionary corresponding to the enum above
  static Map<dynamic, AyatMenu> getAyatMenu = {
    'default': defaultAyatMenu,
    'expanded': AyatMenu.expanded,
    'compact': AyatMenu.compact,
  };

  static AyatMenu getAyatMenuByIndex({
    required String key,
  }) {
    return getAyatMenu[key] ?? defaultAyatMenu;
  }

  static void setAyatMenu(
    BuildContext context, {
    required AyatMenu menu,
  }) {
    context.read<AyatMenuControlCubit>().setCurrentMenu(
          menu.name,
        );
  }

  static bool isAyatMenuSelected(
    BuildContext context, {
    required String key,
  }) {
    if (context.read<AyatMenuControlCubit>().selectedMenu ==
        getAyatMenuByIndex(key: key)) {
      return true;
    }
    return false;
  }
}
