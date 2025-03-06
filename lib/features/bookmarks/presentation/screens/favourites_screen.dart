import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart' show AppColors;
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart'
    show AppStrings;
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart'
    show AppAssets;
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart'
    show AppConstants;
import 'package:qeraat_moshaf_kwait/features/bookmarks/data/models/bookmark_model.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart'
    show BookmarksCubit, BookmarksState;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit;
import 'package:qeraat_moshaf_kwait/features/quran_translation/data/datasources/quran_translation_database_service.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/app_context.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.favourites),
        leading: AppConstants.customBackButton(context),
      ),
      body: const SafeArea(
        child: StarListBody(),
      ),
    );
  }
}

class StarListBody extends StatefulWidget {
  const StarListBody({Key? key}) : super(key: key);

  @override
  State<StarListBody> createState() => _StarListBodyState();
}

class _StarListBodyState extends State<StarListBody> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksCubit, BookmarksState>(
      builder: (BuildContext context, BookmarksState state) {
        final cubit = BookmarksCubit.get(context);
        return ValueListenableBuilder(
          valueListenable: cubit.favouritesBoxListenable,
          builder: (BuildContext context, Box box, widget) {
            return box.isEmpty
                ? Center(
                    child: Text(
                      context.translate.favourites_list_is_empty,
                      textDirection:
                          context.translate.localeName == AppStrings.arabicCode
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                      style: context.textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < box.length; i++)
                          SlidableFavListTile(
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
      },
    );
  }
}

class SlidableFavListTile extends StatelessWidget {
  const SlidableFavListTile(
    this.mainContext,
    this.favModel, {
    Key? key,
    required this.index,
  }) : super(key: key);
  final BuildContext mainContext;
  final BookmarkModel favModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      closeOnScroll: true,
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Container(
            color: context.theme.brightness == Brightness.dark
                ? context.theme.scaffoldBackgroundColor
                : const Color(0xFFFEF2F2),
            width: MediaQuery.of(context).size.width / 2,
            child: Align(
              child: InkWell(
                onTap: () => _onDeletePressed(mainContext),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      AppAssets.delete,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.translate.delete,
                      style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: AppColors.red,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onFavouriteTapped(context),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: SvgPicture.asset(
                  AppAssets.starFilled,
                  color: context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //right to left text

                    FutureBuilder<String?>(
                      future: QuranTranslationDatabaseService.fetchAyahText(
                        favModel.surahNumber,
                        favModel.ayah,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                            'Error loading ayah: ${snapshot.error}',
                            style: TextStyle(
                              color: context.theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          );
                        }

                        final ayahText =
                            snapshot.data ?? favModel.ayahText.toString();

                        return RichText(
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            text: ayahText,
                            style: TextStyle(
                              color: context.theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 22,
                              height: 1.8,
                              fontFamily: AppStrings.qeeratKuwaitFontFamily,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      '${context.translate.localeName == AppStrings.arabicCode ? favModel.surahNameArabic : favModel.surahNameEnglish} - ${context.translate.the_ayah} ${favModel.ayah} - ${context.translate.the_page} ${favModel.page}',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDeletePressed(BuildContext context) {
    AppConstants.showConfirmationDialog(context,
        confirmMsg: context.translate
            .do_you_want_to_delete_this_item(context.translate.this_item),
        okCallback: () async {
      await BookmarksCubit.get(context)
          .deleteFavouriteAt(index)
          .whenComplete(() => Navigator.pop(context));
    });
  }

  void _onFavouriteTapped(BuildContext context) {
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      // appContext.read<EssentialMoshafCubit>().navigateToPage(favModel.page);
      AyahRenderBlocHelper.pageChangeInitialize(
        appContext,
        favModel.page - 1,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        var surahNumber = appContext
            .read<EssentialMoshafCubit>()
            .getSurahNumberFromItsName(favModel.surahNameEnglish);
        if (surahNumber != null) {
          AyahRenderBlocHelper.colorAyaAndUpdateBloc(
            surahNumber: surahNumber,
            ayahNumber: favModel.ayah,
          );
        }
        appContext
            .read<EssentialMoshafCubit>()
            .showBottomNavigateByPageLayer(false);
        Navigator.pop(appContext);
      });
    }
  }
}
