import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/about_app/presentation/screens/about_app_screen.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/screens/favourites_screen.dart';
import 'package:qeraat_moshaf_kwait/features/drawer/presentation/screens/dua_khatam_quran.dart';
import 'package:qeraat_moshaf_kwait/features/drawer/presentation/screens/introduction_to_quran_screen.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/screens/external_libraries_screen.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/screens/new_external_liberary_screen.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/notes_view.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/quran_fihris_screen.dart';
import 'package:qeraat_moshaf_kwait/features/ninety_nine_names/presentation/screens/ninety_nine_names.dart';
import 'package:qeraat_moshaf_kwait/features/qeerat/screen/qeerat_menu.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/presentation/screens/translation_list_screen.dart';
import 'package:qeraat_moshaf_kwait/features/surah/data/datasources/soorah_reciters.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/reciters_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/screens/surah_player_screen.dart';
import 'package:qeraat_moshaf_kwait/features/tafseer/presentation/screens/tafseer_book_list_screen.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../config/app_config/app_config.dart';
import '../../../essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import '../../../khatmat/presentation/screens/khatmat/khatmat_screen.dart';
import '../../../listening/presentation/cubit/listening_cubit.dart';
import '../../../main/presentation/screens/quran_search_screen.dart';
import '../../../main/presentation/screens/settings_screens/settings_screen.dart';
import '../../../qanda/presentation/screens/q_and_a_screen.dart';
import '../../../surah/presentation/screens/soorah_reciter_list_screen.dart';
import '../../data/data_sources/drawer_constants.dart';

part 'drawer_header.dart';
part 'drawer_tile.dart';

class MoshafDrawer extends StatelessWidget {
  const MoshafDrawer({
    super.key,
    required this.closeDrawer,
  });
  final VoidCallback closeDrawer;

  void _navigateToOtherScreen(
    BuildContext context, {
    required VoidCallback navigationFunction,
  }) {
    closeDrawer();
    navigationFunction();
  }

  @override
  Widget build(BuildContext context) {
    final surahCubit = context.watch<SurahListenCubit>();

    return Drawer(
      child: BlocBuilder<LangCubit, LangState>(
        builder: (context, state) {
          return Directionality(
            textDirection: LangCubit.get(context).currentLocale.languageCode == AppStrings.englishCode ? TextDirection.rtl : TextDirection.ltr,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _MoshafDrawerHeader(),
                const _DrawerVerticalSpacer(),
                _DrawerTile(
                  text: context.translate.quran,
                  iconAsset: DrawerConstants.drawerQuranIcon,
                  removeDarkModeFromIcon: true,
                  onTap: () {
                    closeDrawer();
                  },
                ),
                if (AppConfig.isQeeratView())
                  _DrawerTile(
                    text: "القراءات العشر",
                    iconAsset: DrawerConstants.drawerQuranIcon,
                    removeDarkModeFromIcon: true,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () {
                        pushSlide(
                          context,
                          pushWithOverlayValues: true,
                          screen: QeraatMenuScreen(),
                        );
                      },
                    ),
                  ),
                _DrawerTile(
                  text: context.translate.index,
                  iconAsset: DrawerConstants.drawerIndexIcon,
                  onTap: () => _navigateToOtherScreen(
                    context,
                    navigationFunction: () {
                      pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const FihrisScreen(),
                      );
                    },
                  ),
                ),
                _DrawerTile(
                  text: context.translate.search,
                  iconAsset: DrawerConstants.drawerSearchIcon,
                  onTap: () => _navigateToOtherScreen(
                    context,
                    navigationFunction: () {
                      pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const QuranSearch(),
                      );
                    },
                  ),
                ),
                _DrawerTile(
                  text: context.translate.bookmarks,
                  iconAsset: DrawerConstants.drawerCommasIcon,
                  onTap: () => _navigateToOtherScreen(
                    context,
                    navigationFunction: () {
                      pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const BookmarksView(),
                      );
                    },
                  ),
                ),
                _DrawerTile(
                  text: context.translate.favourites,
                  iconAsset: DrawerConstants.drawerFavouriteIcon,
                  onTap: () => _navigateToOtherScreen(
                    context,
                    navigationFunction: () {
                      pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const FavouritesScreen(),
                      );
                    },
                  ),
                ),
                _DrawerTile(
                  text: context.translate.notes,
                  iconAsset: AppAssets.notesIcon,
                  svgIconLink: true,
                  onTap: () => _navigateToOtherScreen(
                    context,
                    navigationFunction: () => pushSlide(
                      context,
                      pushWithOverlayValues: true,
                      screen: const NotesView(
                        showAppbar: true,
                        withDash: false,
                      ),
                    ),
                  ),
                ),
                if (!AppConfig.isQeeratView()) ...[
                  _DrawerTile(
                      text: context.translate.recitation,
                      iconAsset: DrawerConstants.drawerRecitationIcon,
                      onTap: () {
                        if (surahCubit.currentSurahPlaying == null) {
                          _navigateToOtherScreen(
                            context,
                            navigationFunction: () {
                              context.read<ListeningCubit>().forceStopPlayer();
                              pushSlide(
                                context,
                                pushWithOverlayValues: true,
                                screen: const SoorahRecitersListScreen(),
                              );
                            },
                          );
                        } else {
                          _navigateToOtherScreen(
                            context,
                            navigationFunction: () {
                              context.read<ListeningCubit>().forceStopPlayer();
                              pushSlide(
                                context,
                                pushWithOverlayValues: true,
                                screen: SurahPlayerScreen(selectedSurahId: surahCubit.currentSurahPlaying!, currentReciter: surahCubit.currentReciterPlaying!, reciterName: getReciterName(surahCubit.currentReciterPlaying!, context.translate.localeName == AppStrings.arabicCode)),
                              );
                            },
                          );
                        }
                      }),
                  _DrawerTile(
                    text: context.translate.tafseer,
                    iconAsset: DrawerConstants.drawerTafseerIcon,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () => pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const TafseerBookListScreen(),
                      ),
                    ),
                  ),
                  _DrawerTile(
                    text: context.translate.translation,
                    iconAsset: DrawerConstants.drawerTranslateIcon,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () => pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const TranslationListScreen(),
                      ),
                    ),
                  ),
                  _DrawerTile(
                    text: context.translate.library,
                    iconAsset: DrawerConstants.drawerLibraryIcon,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () => pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const NewExternalLibrariesScreen(),
                      ),
                    ),
                  ),

                  // _DrawerTile(
                  //   text: context.translate.playlist,
                  //   iconAsset: DrawerConstants.playlistIcon,
                  //   onTap: () => _navigateToOtherScreen(
                  //     context,
                  //     navigationFunction: () => pushSlide(
                  //       context,
                  //       pushWithOverlayValues: true,
                  //       screen: const Playlist(),
                  //     ),
                  //   ),
                  // ),

                  _DrawerTile(
                    text: context.translate.khatma,
                    iconAsset: DrawerConstants.drawerKhatmaIcon,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () {
                        pushSlide(
                          context,
                          pushWithOverlayValues: true,
                          screen: const KhatmatScreen(),
                          args: DrawerConstants.navigateFromDrawerArguments,
                        );
                      },
                    ),
                  ),
                  _DrawerTile(
                    text: context.translate.supplication_to_complete_quran,
                    iconAsset: DrawerConstants.drawerSuppllicationOfCompletionIcon,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () => pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const DuaKhatmQuranPage(),
                      ),
                    ),
                  ),
                  _DrawerTile(
                    text: context.translate.namesOfAllah,
                    iconAsset: DrawerConstants.namesIcon,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () => pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: NinetyNineNames(),
                      ),
                    ),
                  ),

                  _DrawerTile(
                      text: context.translate.quranQA,
                      iconAsset: DrawerConstants.qAIcon,
                      onTap: () {
                        _navigateToOtherScreen(
                          context,
                          navigationFunction: () => pushSlide(
                            context,
                            pushWithOverlayValues: true,
                            screen: const QandAScreen(),
                          ),
                        );
                      }),
                  _DrawerTile(
                    text: context.translate.introduction_to_holy_quran,
                    iconAsset: DrawerConstants.drawerIntroductionToHolyQuranIcon,
                    onTap: () => _navigateToOtherScreen(
                      context,
                      navigationFunction: () => pushSlide(
                        context,
                        pushWithOverlayValues: true,
                        screen: const IntroductionToQuranScreen(),
                      ),
                    ),
                  ),
                ],
                _DrawerTile(
                  text: context.translate.settings,
                  iconAsset: DrawerConstants.drawerSettingsIcon,
                  onTap: () => _navigateToOtherScreen(
                    context,
                    navigationFunction: () => pushSlide(
                      context,
                      pushWithOverlayValues: true,
                      screen: const SettingScreen(),
                      args: DrawerConstants.navigateFromDrawerArguments,
                    ),
                  ),
                ),
                if (!AppConfig.isQeeratView())
                  _DrawerTile(
                    text: context.translate.instructions,
                    iconAsset: DrawerConstants.drawerInstructionsIcon,
                  ),
                _DrawerTile(
                  text: context.translate.about_the_app,
                  iconAsset: DrawerConstants.drawerAboutIcon,
                  onTap: () => _navigateToOtherScreen(
                    context,
                    navigationFunction: () => pushSlide(
                      context,
                      pushWithOverlayValues: true,
                      screen: const AboutAppScreen(),
                    ),
                  ),
                ),
                const _DrawerVerticalSpacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}
