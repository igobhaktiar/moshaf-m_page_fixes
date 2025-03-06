import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/data/models/bookmark_model.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../config/app_config/app_config.dart';
import '../../../../core/utils/app_context.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../main/presentation/screens/bottom_sheet_views/widgets/slider_delete_button.dart';

class BookmarkListBody extends StatefulWidget {
  const BookmarkListBody({Key? key}) : super(key: key);

  @override
  State<BookmarkListBody> createState() => _BookmarkListBodyState();
}

class _BookmarkListBodyState extends State<BookmarkListBody> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksCubit, BookmarksState>(
        builder: (BuildContext context, BookmarksState state) {
      var cubit = BookmarksCubit.get(context);
      return ValueListenableBuilder(
        valueListenable: cubit.bookmarksBoxListenable,
        builder: (BuildContext context, Box box, Widget? widget) {
          return box.isEmpty
              ? Center(
                  child: Text(
                    context.translate.bookmarks_list_is_empty,
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int i = 0; i < box.length; i++)
                        SlidableBookmarkListTile(
                          key: Key((box.getAt(i) as BookmarkModel)
                              .date
                              .toIso8601String()),
                          context,
                          box.getAt(i) as BookmarkModel,
                          index: i,
                        ),
                    ],
                  ),
                );
        },
      );
    });
  }
}

class SlidableBookmarkListTile extends StatelessWidget {
  const SlidableBookmarkListTile(
    this.parentContext,
    this.bookmark, {
    Key? key,
    required this.index,
    this.dense = false,
    this.forSavedView = false,
    this.popWhenCicked = false,
    this.isInBottomSheet = false,
  }) : super(key: key);
  final BookmarkModel bookmark;
  final int index;
  final bool dense;
  final bool popWhenCicked;
  final bool forSavedView;
  final bool isInBottomSheet;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderDeleteButton(
          enabled: !forSavedView,
          onDeletePressed: () => _onDeletePressed(parentContext),
          child: ListTile(
            dense: dense,
            contentPadding:
                EdgeInsets.symmetric(vertical: dense ? 0 : 10, horizontal: 25),
            minVerticalPadding: dense ? 0 : 10,
            minLeadingWidth: 0,
            title: Text(
              bookmark.bookmarkTitle.toString(),
              style: context.textTheme.bodyMedium!.copyWith(
                  color: context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w700),
            ),
            leading: SvgPicture.asset(
              AppAssets.bookmarkFilled,
              color: context.theme.brightness == Brightness.dark
                  ? Colors.white
                  : null,
            ),
            trailing: Text(
              '${context.translate.localeName == AppStrings.arabicCode ? bookmark.surahNameArabic : bookmark.surahNameEnglish} - ${context.translate.the_ayah} ${bookmark.ayah}',
              style: context.textTheme.bodySmall!
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () => _onBookmarkTapped(context, isInBottomSheet),
          ),
        ),
        if (forSavedView)
          AppConstants.appDivider(context,
              endIndent: 40,
              color: context.theme.brightness == Brightness.dark
                  ? AppColors.bottomSheetBorderDark
                  : AppColors.border)
      ],
    );
  }

  _onDeletePressed(BuildContext context) {
    AppConstants.showConfirmationDialog(context,
        confirmMsg: context.translate
            .do_you_want_to_delete_this_item(context.translate.this_item),
        okCallback: () {
      BookmarksCubit.get(context)
          .deleteBookmarkAt(index)
          .whenComplete(() => Navigator.pop(context));
    });
  }

  _onBookmarkTapped(BuildContext context, bool isInBottomSheet) {
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      // appContext.read<EssentialMoshafCubit>().navigateToPage(bookmark.page);
      AyahRenderBlocHelper.pageChangeInitialize(
        appContext,
        bookmark.page - 1,
      );
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          var surahNumber = appContext
              .read<EssentialMoshafCubit>()
              .getSurahNumberFromItsName(bookmark.surahNameEnglish);
          if (surahNumber != null) {
            AyahRenderBlocHelper.colorAyaAndUpdateBloc(
              surahNumber: surahNumber,
              ayahNumber: bookmark.ayah,
            );
          }
          if (!isInBottomSheet) {
            Navigator.of(appContext).pop();
          }
          appContext
              .read<EssentialMoshafCubit>()
              .showBottomNavigateByPageLayer(false);
          //Bookmark navigation
          if (!AppConfig.isQeeratView()) {
            BottomWidgetCubit.get(appContext)
                .setBottomWidgetState(true, customIndex: 4);
          }
        },
      );
    }
  }
}
