import 'package:floating_dialog/floating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/app_config/app_config.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/ayah_mini_dialog_cubit/ayah_mini_dialog_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:share/share.dart';

import '../../../../core/data_sources/all_ayat_with_tashkeel.dart';
import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/constants.dart';
import '../../../ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import '../../../drawer/data/data_sources/drawer_constants.dart';
import '../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import '../../../listening/presentation/screens/listen_view.dart';
import '../cubit/bookmarks_cubit/bookmarks_cubit.dart';
import '../cubit/share_cubit/share_cubit_helper_service.dart';
import 'add_bookmark_dialog.dart';
import 'add_bookmark_or_fav_dialog.dart';
import 'ayah_options_mini_dialog.dart';

class AyahOptionMoveableMiniDialog extends StatelessWidget {
  const AyahOptionMoveableMiniDialog({super.key});

  void dialogPop(BuildContext context) {
    AyahMiniDialogCubit.get(context).closeMiniDialog();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AyahMiniDialogCubit, AyahMiniDialogState>(
      builder: (context, ayahMiniDialogCubitState) {
        if (ayahMiniDialogCubitState is AyahMiniDialogOpened) {
          return FloatingDialog(
            onDrag: (x, y) {
              // print('x: $x, y: $y');
            },
            onClose: () {
              dialogPop(context);
            },
            child: Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 0,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: context.theme.brightness == Brightness.dark
                    ? AppColors.scaffoldBgDark
                    : AppColors.tabBackground,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.black, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Position of the shadow
                  ),
                ],
              ),
              child: SizedBox(
                // height: 200,
                width: 280,
                child: Column(
                  children: [
                    Center(
                      child: Icon(
                        Icons.drag_handle,
                        color: context.isDarkMode
                            ? Colors.white
                            : AppColors.cardBgDark,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "${context.translate.localeName == AppStrings.arabicCode ? ayahMiniDialogCubitState.ayah.surah : ayahMiniDialogCubitState.ayah.surahEnglish} - ${context.translate.the_ayah} ${ayahMiniDialogCubitState.ayah.numberInSurah}"
                            .replaceAll(RegExp(r"سورة"), ''),
                      ),
                    ),
                    ListenView(
                      useCustomBackgroundInDarkModeAlso: true,
                      customBackgroundColor: context.isDarkMode
                          ? AppColors.scaffoldBgDark
                          : AppColors.tabBackground,
                      removeRepeatButton: true,
                      ayah: ayahMiniDialogCubitState.ayah,
                      smallPadding: true,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DialogVerticalTile(
                          removeFlex: true,
                          svgIcon: AppAssets.switchMenuIcon,
                          iconSize: 25,
                          onTap: () {
                            dialogPop(context);
                            showAyahOptionsDialog(
                              context,
                              ayahMiniDialogCubitState.ayah,
                              highlight: ayahMiniDialogCubitState.highlight,
                            );
                          },
                        ),
                        DialogVerticalTile(
                          svgIcon: AppAssets.starFilled,
                          onTap: () {
                            context
                                .read<AyatHighlightCubit>()
                                .loadCurrentPageAyatSeg();
                            BookmarksCubit.get(context).addFavourite(
                                ayah: ayahMiniDialogCubitState.ayah);
                            dialogPop(context);
                          },
                        ),
                        DialogVerticalTile(
                          svgIcon: AppAssets.shareIcon,
                          onTap: () {
                            AppConstants.showConfirmationDialog(
                              context,
                              confirmMsg: context.translate
                                  .do_you_want_to_share_multiple_ayahs,
                              okCallback: () {
                                context
                                    .read<AyatHighlightCubit>()
                                    .loadCurrentPageAyatSeg();
                                ShareCubitHelperService
                                    shareCubitHelperService =
                                    ShareCubitHelperService();
                                shareCubitHelperService
                                    .printShareCubitState(context);
                                shareCubitHelperService
                                    .startSelectionForMultiSharing(
                                  context,
                                  ayah: ayahMiniDialogCubitState.ayah,
                                  allAyatWithTashkeel: allAyatWithTashkeel,
                                );

                                Navigator.pop(context);
                                dialogPop(context);
                                shareCubitHelperService
                                    .printShareCubitState(context);
                              },
                              cancelCallback: () {
                                context
                                    .read<AyatHighlightCubit>()
                                    .loadCurrentPageAyatSeg();
                                Navigator.pop(context);
                                final shareAyahString =
                                    '${allAyatWithTashkeel[ayahMiniDialogCubitState.ayah.number! - 1]['text']} \n آية رقم ${ayahMiniDialogCubitState.ayah.numberInSurah} \n ${ayahMiniDialogCubitState.ayah.surah} \n  مصحف دولة الكويت للقراءات العشر \n ${AppStrings.appUrl}';
                                Share.share(shareAyahString);
                              },
                            );
                          },
                        ),
                        DialogVerticalTile(
                          svgIcon: AppAssets.bookmarkFilled,
                          onTap: () {
                            dialogPop(context);
                            showAddBookmarkDialog(
                                context, ayahMiniDialogCubitState.ayah);
                          },
                        ),
                        if (!AppConfig.isQeeratView())
                          DialogVerticalTile(
                            svgIcon: DrawerConstants.drawerLibraryIcon,
                            isIconSvg: false,
                            iconSize: 35,
                            onTap: () {
                              dialogPop(context);
                              AppContext.getAppContext()!
                                  .read<BottomWidgetCubit>()
                                  .reloadBottomWidgetState(
                                    AppContext.getAppContext()!,
                                    scrollDownTopPage: true,
                                    scrollOffset:
                                        ayahMiniDialogCubitState.scrollOffset,
                                    customIndex: 0,
                                    surahId: BottomWidgetService.surahId,
                                    ayahId: BottomWidgetService.ayahId,
                                  );
                              // AppContext.getAppContext()!
                              //     .read<BottomWidgetCubit>()
                              //     .setBottomWidgetState(true);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
