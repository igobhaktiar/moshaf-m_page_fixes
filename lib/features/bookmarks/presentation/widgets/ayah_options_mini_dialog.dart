import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/data_sources/all_ayat_with_tashkeel.dart';
import 'package:qeraat_moshaf_kwait/core/default_dialog.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart' show AppColors;
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart'
    show AppAssets;
import 'package:qeraat_moshaf_kwait/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/ayah_mini_dialog_cubit/ayah_mini_dialog_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:share/share.dart';

import '../../../../core/utils/constants.dart';
import '../../../ayatHighlight/data/models/ahyah_segs_model.dart';
import '../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import '../../../listening/presentation/screens/listen_view.dart';
import '../cubit/share_cubit/share_cubit_helper_service.dart';
import 'add_bookmark_dialog.dart';
import 'add_bookmark_or_fav_dialog.dart';

showAyahOptionsMiniDialog(
  BuildContext context,
  AyahModel ayah, {
  Offset? scrollOffset,
  AyahSegsModel? highlight,
}) async {
  if (highlight != null) {
    context
        .read<AyatHighlightCubit>()
        .highlightAyah(ayah, releaseAfterPeriod: false);
  }
  // context.read<ListeningCubit>().startListenFromAyah(ayah: ayah);
  // await Future.delayed(const Duration(milliseconds: 500));
  // ignore: use_build_context_synchronously
  AyahMiniDialogCubit.get(context).openMiniDialog(
    ayah,
    highlight,
    scrollOffset,
  );
  // showMiniDialog(
  //   context,
  //   ayah,
  //   highlight: highlight,
  // );
}

void showMiniDialog(
  BuildContext context,
  AyahModel ayah, {
  AyahSegsModel? highlight,
}) {
  showDefaultDialog(context,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: Colors.black, width: 2.0),
      ),
      withSaveButton: false,
      title:
          "${context.translate.localeName == AppStrings.arabicCode ? ayah.surah : ayah.surahEnglish} - ${context.translate.the_ayah} ${ayah.numberInSurah}"
              .replaceAll(RegExp(r"سورة"), ''),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogVerticalTile(
                title: context.translate.tafseer,
                svgIcon: AppAssets.tafseerActive,
                onTap: () {
                  // context
                  //     .read<EssentialMoshafCubit>()
                  //     .showBottomSheetSections();

                  context.read<BottomWidgetCubit>().setBottomWidgetState(true);
                  context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                  Navigator.pop(context);
                },
              ),
              DialogVerticalTile(
                title: context.translate.al_tarjuma,
                svgIcon: AppAssets.alTarjumaMiniMenuIcon,
                onTap: () {},
              ),
              DialogVerticalTile(
                title: context.translate.asbab_al_nuzool,
                svgIcon: AppAssets.asbabAlNuzoolMiniMenuIcon,
                onTap: () {},
              ),
              DialogVerticalTile(
                title: context.translate.your_notes,
                svgIcon: AppAssets.yourNotesMiniMenuIcon,
                onTap: () {
                  //Notes Navigation
                  context.read<BottomWidgetCubit>().setBottomWidgetState(
                        true,
                        customIndex: 3,
                      );
                  // context
                  //     .read<EssentialMoshafCubit>()
                  //     .showBottomSheetSections();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const ListenView(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DialogVerticalTile(
                removeFlex: true,
                svgIcon: AppAssets.switchMenuIcon,
                iconSize: 25,
                onTap: () {
                  Navigator.pop(context);
                  showAyahOptionsDialog(
                    context,
                    ayah,
                    highlight: highlight,
                  );
                },
              ),
              DialogVerticalTile(
                svgIcon: AppAssets.starFilled,
                onTap: () {
                  context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                  BookmarksCubit.get(context).addFavourite(ayah: ayah);
                  Navigator.pop(context);
                },
              ),
              DialogVerticalTile(
                svgIcon: AppAssets.shareIcon,
                onTap: () {
                  AppConstants.showConfirmationDialog(
                    context,
                    confirmMsg:
                        context.translate.do_you_want_to_share_multiple_ayahs,
                    okCallback: () {
                      context
                          .read<AyatHighlightCubit>()
                          .loadCurrentPageAyatSeg();
                      ShareCubitHelperService shareCubitHelperService =
                          ShareCubitHelperService();
                      shareCubitHelperService.printShareCubitState(context);
                      shareCubitHelperService.startSelectionForMultiSharing(
                        context,
                        ayah: ayah,
                        allAyatWithTashkeel: allAyatWithTashkeel,
                      );

                      Navigator.pop(context);
                      Navigator.pop(context);
                      shareCubitHelperService.printShareCubitState(context);
                    },
                    cancelCallback: () {
                      context
                          .read<AyatHighlightCubit>()
                          .loadCurrentPageAyatSeg();
                      Navigator.pop(context);
                      final shareAyahString =
                          '${allAyatWithTashkeel[ayah.number! - 1]['text']} \n آية رقم ${ayah.numberInSurah} \n ${ayah.surah} \n  مصحف دولة الكويت للقراءات العشر \n ${AppStrings.appUrl}';
                      Share.share(shareAyahString);
                    },
                  );
                },
              ),
              DialogVerticalTile(
                svgIcon: AppAssets.bookmarkFilled,
                onTap: () {
                  Navigator.pop(context);
                  showAddBookmarkDialog(context, ayah);
                },
              ),
            ],
          ),
        ],
      ), onDialogDismissed: () async {
    context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
    log("dialog dissmissed");
    return true;
  });
}

class DialogVerticalTile extends StatelessWidget {
  const DialogVerticalTile({
    Key? key,
    required this.onTap,
    required this.svgIcon,
    this.isIconSvg = true,
    this.title,
    this.iconSize = 25,
    this.iconData,
    this.removeFlex,
  }) : super(key: key);
  final String svgIcon;
  final VoidCallback onTap;
  final String? title;
  final double? iconSize;
  final IconData? iconData;
  final bool? removeFlex;
  final bool isIconSvg;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (removeFlex != null && removeFlex == true) ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        child: Column(children: [
          if (iconData == null)
            (isIconSvg)
                ? SvgPicture.asset(
                    svgIcon,
                    height: iconSize,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.inactiveColor,
                  )
                : Image.asset(
                    svgIcon,
                    height: iconSize,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.inactiveColor,
                  ),
          if (iconData != null)
            Icon(
              iconData!,
              size: iconSize,
              color: context.theme.brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.inactiveColor,
            ),
          if (title != null) ...[
            const SizedBox(height: 4),
            Text(
              title!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ]
        ]),
      ),
    );
  }
}
