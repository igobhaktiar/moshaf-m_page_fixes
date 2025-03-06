import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/default_dialog.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart' show AppColors;
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart'
    show AppAssets;
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/widgets/add_bookmark_dialog.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/widgets/share_dialogs.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/notes/presentation/widgets/add_note_dialog.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../config/app_config/app_config.dart';
import '../../../../core/utils/app_context.dart';
import '../../../ayatHighlight/data/models/ahyah_segs_model.dart';
import '../../../drawer/data/data_sources/drawer_constants.dart';
import '../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import '../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import '../../../playlist/presentation/cubit/playlist_surah_listen_cubit.dart';
import '../../../quran_translation/data/models/translation_page_list_model.dart';
import '../../../surah/presentation/cubit/surah_listen_cubit.dart';
import '../../../tafseer/data/models/tafseer_reading_model.dart';
import '../cubit/share_service/share_database_service.dart';
import 'ayah_options_mini_dialog.dart';

showAyahOptionsDialog(
  BuildContext context,
  AyahModel ayah, {
  AyahSegsModel? highlight,
  int? ayahId,
  int? soraId,
  Offset? scrollOffset,
}) async {
  if (highlight != null) {
    context
        .read<AyatHighlightCubit>()
        .highlightAyah(ayah, releaseAfterPeriod: false);
    await Future.delayed(const Duration(milliseconds: 500));
  }
  // ignore: use_build_context_synchronously
  showDefaultDialog(context,
      withSaveButton: false,
      title:
          "${context.translate.localeName == AppStrings.arabicCode ? ayah.surah : ayah.surahEnglish} - ${context.translate.the_ayah} ${ayah.numberInSurah}"
              .replaceAll(RegExp(r"سورة"), ''),
      leadingTitleIcon: AppAssets.switchMenuIcon,
      leadingTitleFunction: () {
        Navigator.pop(context);
        showAyahOptionsMiniDialog(
          context,
          ayah,
          highlight: highlight,
        );
      },
      content: Column(
        children: [
          if (!context.isLandscape) ...[
            DialogTile(
                title: context.translate.listen_to_ayah,
                svgIcon: AppAssets.play,
                onTap: () {
                  context.read<ListeningCubit>().listenToAyah(ayah: ayah);
                  //Listen Navigation
                  // context.read<EssentialMoshafCubit>().showBottomSheetSections();
                  context.read<BottomWidgetCubit>().setBottomWidgetState(
                        true,
                        customIndex: 2,
                      );
                  Navigator.pop(context);
                }),
            DialogTile(
                title: context.translate.listen_from_this_ayah,
                svgIcon: AppAssets.play,
                onTap: () {
                  context
                      .read<ListeningCubit>()
                      .startListenFromAyah(ayah: ayah);
                  //Listen Navigation
                  context.read<BottomWidgetCubit>().setBottomWidgetState(
                        true,
                        customIndex: 2,
                      );
                  Navigator.pop(context);
                }),
          ],

          if (!AppConfig.isQeeratView() && !context.isLandscape) ...[
            DialogTile(
                title: context.translate.tafseer,
                svgIcon: AppAssets.tafseerActive,
                onTap: () {
                  // context.read<EssentialMoshafCubit>().showBottomSheetSections();
                  //Tafseer Navigation
                  // context.read<BottomWidgetCubit>().setBottomWidgetState(true);
                  AppContext.getAppContext()!
                      .read<BottomWidgetCubit>()
                      .reloadBottomWidgetState(
                        AppContext.getAppContext()!,
                        scrollDownTopPage: true,
                        scrollOffset: scrollOffset,
                        customIndex: 0,
                        surahId: BottomWidgetService.surahId,
                        ayahId: BottomWidgetService.ayahId,
                      );
                  context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                  Navigator.pop(context);
                }),
            DialogTile(
                title: context.translate.translation,
                svgIcon: '',
                imageIcon: DrawerConstants.drawerTranslateIcon,
                onTap: () {
                  // context.read<EssentialMoshafCubit>().showBottomSheetSections();
                  //Tafseer Navigation
                  context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                  AppContext.getAppContext()!
                      .read<BottomWidgetCubit>()
                      .reloadBottomWidgetState(
                        AppContext.getAppContext()!,
                        scrollOffset: scrollOffset,
                        scrollDownTopPage: true,
                        customIndex: 1,
                        surahId: BottomWidgetService.surahId,
                        ayahId: BottomWidgetService.ayahId,
                      );
                  // context.read<BottomWidgetCubit>().setBottomWidgetState(
                  //       true,
                  //       customIndex: 1,
                  //     );
                  Navigator.pop(context);
                }),
          ],

          DialogTile(
              title: context.translate.add_to_favs,
              svgIcon: AppAssets.starFilled,
              onTap: () {
                context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                BookmarksCubit.get(context).addFavourite(ayah: ayah);
                Navigator.pop(context);
              }),
          DialogTile(
              title: context.translate.add_to_bookmarks,
              svgIcon: AppAssets.bookmarkFilled,
              onTap: () {
                Navigator.pop(context);
                showAddBookmarkDialog(context, ayah);
              }),
          DialogTile(
            title: context.translate.create_a_note,
            svgIcon: AppAssets.notesIcon,
            onTap: () {
              context.read<ListeningCubit>().forceStopPlayer();
              context.read<SurahListenCubit>().forceStopPlayer();
              context.read<PlaylistSurahListenCubit>().forceStopPlayer();
              Navigator.pop(context);
              showAddNoteDialog(context, ayah);
            },
          ),
          DialogTile(
              title: context.translate.show_khatmat_list,
              svgIcon: AppAssets.khatmahActive,
              onTap: () {
                Navigator.pop(context);
                // context.read<EssentialMoshafCubit>().toggleRootView();
                // context.read<EssentialMoshafCubit>().changeBottomNavBar(1);
                context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                context.read<BottomWidgetCubit>().setBottomWidgetState(true);
              }),
          // DialogTile(
          //     title: context.translate.share_ayah_as_image,
          //     disable: true,
          //     svgIcon: AppAssets.shareIcon,
          //     iconData: Icons.image,
          //     onTap: () {
          //       context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
          //       Navigator.pop(context);
          //       shareAyahAsImage(context, ayah: ayah);
          //     }),
          DialogTile(
            title: context.translate.share_ayah,
            svgIcon: AppAssets.shareIcon,
            onTap: () async {
              Navigator.of(context).pop();
              AyahWithTranslation? ayahWithTranslation;
              String currentLanguageCode;
              (ayahWithTranslation, currentLanguageCode) =
                  await ShareDatabaseService()
                      .getSurahWithTranslation(ayah: ayah);
              if (ayahWithTranslation != null) {
                ShareDialogs.showShareDialogGeneric(
                  context: context,
                  ayah: ayahWithTranslation,
                  isTranslation: true,
                  showOnlyQuran: true,
                  currentLanguageCode: currentLanguageCode,
                );
              } else {
                // MoshafSnackbar.triggerSnackbar(context,
                //     text: 'No Quran Found');
              }
              // ShareDialogs.showAyahDialog(context: context, initialSurah: ayah);
            },
          ),
          if (!AppConfig.isQeeratView()) ...[
            DialogTile(
              title: context.translate.shareTafseer,
              svgIcon: AppAssets.shareIcon,
              onTap: () async {
                Navigator.of(context).pop();
                // ShareDialogs.showTafseerDialog(
                //     context: context, initialSurah: ayah);
                AyahWithTafseer? ayahWithTafseer;
                String currentTafseerCode;
                (ayahWithTafseer, currentTafseerCode) =
                    await ShareDatabaseService()
                        .getSurahWithTafseer(ayah: ayah);
                if (ayahWithTafseer != null) {
                  ShareDialogs.showShareDialogGeneric(
                    context: context,
                    ayah: ayahWithTafseer,
                    isTafseer: true,
                    currentBookCode: currentTafseerCode,
                  );
                } else {
                  // MoshafSnackbar.triggerSnackbar(context,
                  //     text: 'No Tafseer Found');
                }
              },
            ),
            DialogTile(
              title: context.translate.shareTranslation,
              svgIcon: AppAssets.shareIcon,
              onTap: () async {
                Navigator.of(context).pop();
                // ShareDialogs.showTranslationDialog(
                //     context: context, initialSurah: ayah);
                AyahWithTranslation? ayahWithTranslation;
                String currentLanguageCode;
                (ayahWithTranslation, currentLanguageCode) =
                    await ShareDatabaseService()
                        .getSurahWithTranslation(ayah: ayah);
                if (ayahWithTranslation != null) {
                  ShareDialogs.showShareDialogGeneric(
                    context: context,
                    ayah: ayahWithTranslation,
                    isTranslation: true,
                    currentLanguageCode: currentLanguageCode,
                  );
                } else {
                  // MoshafSnackbar.triggerSnackbar(context,
                  //     text: 'No Translaton Found');
                }
              },
            ),
          ],
        ],
      ),
      onDialogDismissed: () async {
        context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
        log("dialog dissmissed");
        return true;
      });
}

class DialogTile extends StatelessWidget {
  const DialogTile({
    Key? key,
    required this.onTap,
    required this.title,
    required this.svgIcon,
    this.disable = false,
    this.imageIcon,
    this.iconSize,
    this.iconData,
  }) : super(key: key);
  final String svgIcon;
  final String? imageIcon;
  final VoidCallback onTap;
  final String title;
  final bool disable;
  final double? iconSize;
  final IconData? iconData;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: context.theme.brightness == Brightness.dark
          ? AppColors.cardBgDark
          : disable
              ? AppColors.backgroundColor.withOpacity(0.5)
              : AppColors.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: InkWell(
        onTap: disable ? () {} : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(children: [
            if (iconData == null && imageIcon == null)
              SvgPicture.asset(
                svgIcon,
                height: iconSize ?? 17,
                color: context.isDarkMode
                    ? disable
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white
                    : disable
                        ? AppColors.inactiveColor.withOpacity(0.5)
                        : AppColors.inactiveColor,
              ),
            if (iconData != null)
              Icon(
                iconData!,
                size: iconSize ?? 20,
                color: context.isDarkMode
                    ? disable
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white
                    : disable
                        ? AppColors.inactiveColor.withOpacity(0.5)
                        : AppColors.inactiveColor,
              ),
            if (imageIcon != null)
              Image.asset(
                imageIcon!,
                height: iconSize ?? 17,
                color: context.isDarkMode
                    ? disable
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white
                    : disable
                        ? AppColors.inactiveColor.withOpacity(0.5)
                        : AppColors.inactiveColor,
              ),
            const SizedBox(width: 12),
            Text(
              title,
              style: context.textTheme.bodyMedium!.copyWith(
                fontSize: 16, fontWeight: FontWeight.w400,
                color: context.isDarkMode
                    ? disable
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white
                    : disable
                        ? AppColors.activeButtonColor.withOpacity(0.5)
                        : AppColors.activeButtonColor,
                // disable? :null,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
