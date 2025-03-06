import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayat_menu_control_cubit/ayat_menu_control_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'ayat_menu_control_state.dart';

class AyatMenuControlCubit extends Cubit<AyatMenuControlState> {
  AyatMenuControlCubit({required this.sharedPreferences})
      : super(const AppAyatMenuControlState(selectedMenu: AyatMenu.expanded));
  static AyatMenuControlCubit get(context) => BlocProvider.of(context);

  final SharedPreferences sharedPreferences;
  AyatMenu selectedMenu = AyatMenu.expanded;
  init() {
    String savedMenu =
        sharedPreferences.getString(AppStrings.savedAyatInteractiveMenu) ??
            selectedMenu.name;

    setCurrentMenu(savedMenu, logAnalyticsEvent: false);
  }

  getCurrentMenu() {
    String savedMenu =
        sharedPreferences.getString(AppStrings.savedAyatInteractiveMenu) ??
            selectedMenu.name;
    setCurrentMenu(savedMenu, logAnalyticsEvent: false);
    AyatMenu retrievedMenu =
        AyatMenuControlService.getAyatMenu[savedMenu] ?? selectedMenu;
    return retrievedMenu;
  }

  setCurrentMenu(String menuKey, {bool logAnalyticsEvent = true}) {
    emit(
      AppAyatMenuControlState(
        selectedMenu: AyatMenuControlService.getAyatMenu[menuKey] ??
            AyatMenuControlService.defaultAyatMenu,
      ),
    );

    sharedPreferences.setString(
      AppStrings.savedAyatInteractiveMenu,
      menuKey,
    );
  }
}
