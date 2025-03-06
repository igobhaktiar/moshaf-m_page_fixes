import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';

import '../../../../../core/utils/assets_manager.dart';
import '../../../../bookmarks/data/models/bookmark_model.dart';
import '../../../../bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import '../../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc.dart';

class BookmarkButtonDisplay extends StatelessWidget {
  const BookmarkButtonDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksCubit, BookmarksState>(
      builder: (BuildContext context, BookmarksState state) {
        var cubit = BookmarksCubit.get(context);
        return BlocBuilder<AyahRenderBloc, AyahRenderState>(
          builder: (context, ayahRenderState) {
            if (ayahRenderState is AyahRendered &&
                ayahRenderState.pageIndex != null) {
              return ValueListenableBuilder(
                valueListenable: cubit.bookmarksBoxListenable,
                builder: (BuildContext context, Box box, Widget? widget) {
                  String bookMarkIcon = AppAssets.bookmarkOutlined;
                  if (box.isNotEmpty) {
                    int pageNumber = ayahRenderState.pageIndex! + 1;
                    for (int i = 0; i < box.length; i++) {
                      int bookMarkPageNumber =
                          (box.getAt(i) as BookmarkModel).page;
                      if (pageNumber == bookMarkPageNumber) {
                        bookMarkIcon = AppAssets.bookmarkActive;
                      }
                    }
                  }
                  return InkWell(
                    onTap: () {
                      //Bookmark Navigation

                      context.read<BottomWidgetCubit>().setBottomWidgetState(
                            true,
                            customIndex: 4,
                          );
                      // context
                      //     .read<EssentialMoshafCubit>()
                      //     .showBottomSheetSections();
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: SvgPicture.asset(
                        bookMarkIcon,
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : null,
                      ),
                    ),
                  );
                },
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: SvgPicture.asset(
                  AppAssets.bookmarkOutlined,
                  color: context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : null,
                ),
              );
            }
          },
        );
      },
    );
  }
}
