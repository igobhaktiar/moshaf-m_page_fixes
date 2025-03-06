import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart'
    show AppConstants, ListItemData;
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/drawer/data/data_sources/drawer_constants.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/advanced_settings.dart'
    show AdvancedSettingScreen;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/appearance_control_screen.dart'
    show AppearanceControlScreen;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/language_control_screen.dart'
    show LanguageControlScreen;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/moshaf_background_control_screen.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/notifications_control_screen.dart'
    show NotificationsControlScreen;
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/quran_text_color_change_screen.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/reciter_controls_screen.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/show_juz_popup_screen.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/storage_screen.dart'
    show StorageScreen;
import 'package:qeraat_moshaf_kwait/features/terms_and_conditions/presentation/screens/terms_and_conditions_screen.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:share/share.dart';

import '../../../../../config/app_config/app_config.dart';
import '../../../../privacy_policy/presentation/screens/privacy_policy_screen.dart';
import 'ayat_menu_control_screen.dart';
import 'narration_differences_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool onPressedActive = true;
    onPressedActive = DrawerConstants.activeDefaultBackButton(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.settings),
          leading: (!onPressedActive)
              ? const SizedBox()
              : AppConstants.customBackButton(
                  context,
                  onPressed: (onPressedActive == true)
                      ? () {
                          EssentialMoshafCubit.get(context).toggleRootView();
                        }
                      : null,
                ),
          actions: [
            AppConstants.customHomeButton(context),
          ],
        ),
        body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0.0, 16, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SettingWidgetList(
                            groupTitle: context.translate.general_settings,
                            settingListData: _settinglistTiles1(context),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          SettingWidgetList(
                            groupTitle: context.translate.moshaf_options,
                            settingListData: _settinglistTiles2(context),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          SettingWidgetList(
                            groupTitle:
                                context.translate.security_and_usage_policy,
                            settingListData: _settinglistTiles3(context),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                )
              ]),
        ));
  }

  List<ListItemData> _settinglistTiles1(BuildContext context) {
    //* LANGUAGES
    final settingList = [
      ListItemData.image(
        image: AppAssets.set_1,
        onPressed: () {
          pushSlide(context, screen: const LanguageControlScreen());
        },
        name: context.translate.ui_language,
      ),

      if (!AppConfig.isQeeratView())
        ListItemData.image(
          name: context.translate.notifications_and_reminders,
          image: AppAssets.set_2,
          onPressed: () {
            pushSlide(context, screen: const NotificationsControlScreen());
          },
        ),
      //* THEME
      ListItemData.image(
        image: AppAssets.set_3,
        name: context.translate.appearance,
        onPressed: () {
          pushSlide(context, screen: const AppearanceControlScreen());
        },
      ),

      if (!AppConfig.isQeeratView())
        //* ADVANCED SETTINGS
        ListItemData.image(
          name: context.translate.advanced_settings,
          image: AppAssets.set_5,
          onPressed: () {
            pushSlide(context, screen: const AdvancedSettingScreen());
          },
        ),

      //* ALL RECITERS
      // ListItemData.image(
      //     name: context.translate.the_surah,
      //     image: AppAssets.document,
      //     onPressed: () {
      //       pushSlide(context, screen: const Reciters());
      //     }),
    ];
    return settingList;
  }

  List<ListItemData> _settinglistTiles2(BuildContext context) {
    final settingList = [
      ListItemData.image(
        image: AppAssets.set_3,
        onPressed: () {
          pushSlide(context, screen: const QuranTextColorChangeScreen());
        },
        name: context.translate.quran_text_color,
      ),
      //* NOTIFICATIONS
      ListItemData.image(
        name: context.translate.moshaf_background_color,
        image: AppAssets.set_3,
        onPressed: () {
          pushSlide(context, screen: const MoshafBackgroundControlScreen());
        },
      ),
      //* STORAGE
      if (!AppConfig.isQeeratView())
        ListItemData.image(
          name: context.translate.audio,
          image: AppAssets.set_4,
          onPressed: () {
            pushSlide(context, screen: const StorageScreen());
          },
        ),
      //* AYAT LONG PRESS POPUP SELECTION
      ListItemData.image(
          name: context.translate.ayat_interactive_menu,
          image: AppAssets.ayatInteractiveMenu,
          onPressed: () {
            pushSlide(context, screen: const AyatMenuControlScreen());
          }),
      ListItemData.image(
          name: context.translate.showJuzPopup,
          image: AppAssets.ayatInteractiveMenu,
          onPressed: () {
            pushSlide(context, screen: const ShowJuzPopupScreen());
          }),

      //* ADVANCED SETTINGS

      // //* THEME
      // ListItemData.image(
      //   image: AppAssets.ayatInteractiveMenu,
      //   name: context.translate.tafseer_book,
      //   onPressed: () {
      //     pushSlide(
      //       context,
      //       pushWithOverlayValues: true,
      //       screen: const TafseerBookListScreen(),
      //     );
      //   },
      // ),

      // //* STORAGE
      // ListItemData.image(
      //   name: context.translate.translation,
      //   isSvg: false,
      //   image: DrawerConstants.drawerTranslateIcon,
      //   onPressed: () {
      //     pushSlide(
      //       context,
      //       pushWithOverlayValues: true,
      //       screen: const TranslationListScreen(),
      //     );
      //   },
      // ),

      //* ADVANCED SETTINGS
      if (!AppConfig.isQeeratView())
        ListItemData.image(
          name: context.translate.reciters,
          image: AppAssets.ayatInteractiveMenu,
          onPressed: () {
            pushSlide(context, screen: const ReciterControlsScreen());
          },
        ),
    ];
    return settingList;
  }

  List<ListItemData> _settinglistTiles3(BuildContext context) {
    final settingList = [
      //* PRIVACY POLICY
      ListItemData.image(
        name: context.translate.privacy_policy,
        image: AppAssets.set_6,
        onPressed: () {
          pushSlide(context, screen: const PrivacyPolicyScreen());
        },
      ),
      //* TERMS OF USE
      ListItemData.image(
        name: context.translate.terms_of_use,
        image: AppAssets.set_7,
        onPressed: () {
          pushSlide(context, screen: const TermsAndConditionsScreen());
        },
      ),
      //* ABOUT THE APP
      // ListItemData.image(
      //   name: context.translate.about_app,
      //   image: AppAssets.set_8,
      //   onPressed: () {
      //     pushSlide(context, screen: const AboutAppScreen());
      //   },
      // ),
      ListItemData.image(
        name: context.translate.share_app,
        image: AppAssets.shareIcon,
        onPressed: () {
          Share.share('مصحف دولة الكويت للقراءات العشر\n ${AppStrings.appUrl}');
        },
      ),
    ];
    return settingList;
  }
}

@immutable
class SettingWidgetList extends StatelessWidget {
  const SettingWidgetList({
    required this.settingListData,
    required this.groupTitle,
    Key? key,
  }) : super(key: key);
  final List<dynamic> settingListData;
  final String groupTitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            groupTitle,
            style: context.textTheme.displayMedium,
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          color: context.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
                color: AppColors.border,
                width: context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            separatorBuilder: (_, index) {
              return Divider(
                color: context.theme.brightness == Brightness.dark
                    ? const Color(0xff565657)
                    : context.theme.dividerColor,
                thickness: 2,
                indent: 40,
              );
            },
            itemCount: settingListData.length,
            itemBuilder: (_, index) {
              return InkWell(
                onTap: settingListData[index].onPressed,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      (settingListData[index].isSvg)
                          ? SvgPicture.asset(
                              settingListData[index].image!,
                              color: context.theme.primaryIconTheme.color,
                            )
                          : Image.asset(
                              settingListData[index].image!,
                              color: context.theme.primaryIconTheme.color,
                              height: 20,
                              width: 20,
                            ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Text(
                          settingListData[index].name!,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: context.theme.primaryIconTheme.color,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
