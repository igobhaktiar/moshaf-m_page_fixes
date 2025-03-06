import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/data/models/bookmark_model.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/screens/bookmarks_list.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/constants.dart';

class BookmarksView extends StatefulWidget {
  final bool withDash;
  final bool dense;
  final bool forSavedView;
  final bool popWhenCicked;
  final bool removeNavigation;
  const BookmarksView({
    this.withDash = true,
    this.dense = false,
    this.forSavedView = false,
    Key? key,
    this.popWhenCicked = false,
    this.removeNavigation = false,
  }) : super(key: key);

  @override
  State<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends State<BookmarksView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!widget.removeNavigation)
          ? AppBar(
              title: Text(context.translate.bookmarks),
              leading: AppConstants.customBackButton(context),
            )
          : null,
      body: BlocBuilder<BookmarksCubit, BookmarksState>(
          builder: (context, state) {
        var cubit = BookmarksCubit.get(context);
        return ValueListenableBuilder(
          valueListenable: cubit.bookmarksBoxListenable,
          builder: (context, Box box, boxWidget) {
            if (box.isEmpty) {
              return CenteredEmptyListMsgWidget(
                msg: context.translate.bookmarks_list_is_empty,
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < box.length; i++)
                          SlidableBookmarkListTile(
                              isInBottomSheet: widget.removeNavigation,
                              dense: widget.dense,
                              popWhenCicked: widget.popWhenCicked,
                              forSavedView: widget.forSavedView,
                              key: Key((box.getAt(i) as BookmarkModel)
                                  .date
                                  .toIso8601String()),
                              context,
                              box.getAt(i) as BookmarkModel,
                              index: i),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class CenteredEmptyListMsgWidget extends StatelessWidget {
  const CenteredEmptyListMsgWidget({
    Key? key,
    required this.msg,
  }) : super(key: key);
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg,
        textDirection: context.translate.localeName == AppStrings.arabicCode
            ? TextDirection.rtl
            : TextDirection.ltr,
        style: context.textTheme.bodyMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ViewDashIndicator extends StatelessWidget {
  const ViewDashIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<EssentialMoshafCubit>().hideFlyingLayers(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 31,
        decoration: BoxDecoration(
          border: Border.all(width: 2.5, color: AppColors.lightBrown),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
