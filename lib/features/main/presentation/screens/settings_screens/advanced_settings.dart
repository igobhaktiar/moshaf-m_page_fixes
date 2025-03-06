import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/lock_screen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/display_on_startup_cubit/display_on_start_up_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_switch_list_tile.dart';

class AdvancedSettingScreen extends StatelessWidget {
  const AdvancedSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.advanced_settings),
          leading: AppConstants.customBackButton(context),
          actions: [
            AppConstants.customHomeButton(context, doublePop: true),
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          AdvancedSettingWidgetList(
                            groupTitle: context.translate.advanced_settings,
                          ),
                          const SizedBox(),
                          ShowAtStartWidgetList(
                            groupTitle: context.translate.display_on_startup,
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ]));
  }
}

class AdvancedSettingWidgetList extends StatefulWidget {
  const AdvancedSettingWidgetList({
    required this.groupTitle,
    Key? key,
  }) : super(key: key);

  final String groupTitle;

  @override
  State<AdvancedSettingWidgetList> createState() =>
      _AdvancedSettingWidgetListState();
}

class _AdvancedSettingWidgetListState extends State<AdvancedSettingWidgetList> {
  bool isLockScreenSwitched = false;
  // bool isBookmarkSwitched = false;

  @override
  void initState() {
    isLockScreenSwitched = context.read<LockScreenCubit>().lockScreenEnabled;
    // isBookmarkSwitched =
    //     context.read<BookmarksCubit>().showBookmarksOnStartEnabled;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            widget.groupTitle,
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
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              BlocBuilder<ListeningCubit, ListeningState>(
                buildWhen: (_, cur) => cur is ChangeEnablePlayInBackgroundState,
                builder: (context, state) {
                  return CustomSwitchListTile(
                      title: context.translate.listen_in_background,
                      value:
                          context.read<ListeningCubit>().enablePlayInBackground,
                      onChanged: (value) {
                        context
                            .read<ListeningCubit>()
                            .setEnablePlayInBackground(value);
                      });
                },
              ),
              // BlocBuilder<BookmarksCubit, BookmarksState>(
              //   builder: (context, state) {
              //     var cubit = context.read<BookmarksCubit>();
              //     return CustomSwitchListTile(
              //         title: context.translate.show_bookmarks_at_start,
              //         subTitle: cubit.bookmarksBox.isEmpty
              //             ? context.translate.start_the_app_show_bookmarks
              //             : null,
              // enabled: cubit.bookmarksBox.isNotEmpty,
              // value: isBookmarkSwitched,
              // onChanged: (value) {

              // setState(() {
              //   isBookmarkSwitched = value;
              //   print("isBookmarkSwitched=$isBookmarkSwitched");
              // });
              // context
              //     .read<BookmarksCubit>()
              //     .setShowBookmarksOnStart(value);
              // });
              //   },
              // ),
              AppConstants.appDivider(context, endIndent: 20, indent: 20),
              BlocBuilder<LockScreenCubit, LockScreenState>(
                builder: (context, state) {
                  var cubit = context.read<LockScreenCubit>();
                  return CustomSwitchListTile(
                      title: context.translate.lock_screen,
                      value: isLockScreenSwitched,
                      onChanged: (value) {
                        setState(() {
                          isLockScreenSwitched = value;
                          print("isLockScreenSwitched=$isLockScreenSwitched");
                        });
                        cubit.setLockScreenEnabled(value);
                      });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShowAtStartWidgetList extends StatefulWidget {
  const ShowAtStartWidgetList({
    required this.groupTitle,
    Key? key,
  }) : super(key: key);

  final String groupTitle;

  @override
  State<ShowAtStartWidgetList> createState() => _ShowAtStartWidgetListState();
}

class _ShowAtStartWidgetListState extends State<ShowAtStartWidgetList> {
  void _switch(
    int index,
    bool value,
  ) {
    if (index == 1) {
      DisplayOnStartUpCubit.get(context).setSwitches(
        isPageOneSwitched: value,
        isLastPositionSwitched: false,
        isIndexSwitched: false,
        isBookmarkSwitched: false,
      );
    } else if (index == 2) {
      DisplayOnStartUpCubit.get(context).setSwitches(
        isPageOneSwitched: false,
        isLastPositionSwitched: value,
        isIndexSwitched: false,
        isBookmarkSwitched: false,
      );
    } else if (index == 3) {
      DisplayOnStartUpCubit.get(context).setSwitches(
        isPageOneSwitched: false,
        isLastPositionSwitched: false,
        isIndexSwitched: value,
        isBookmarkSwitched: false,
      );
    } else if (index == 4) {
      DisplayOnStartUpCubit.get(context).setSwitches(
        isPageOneSwitched: false,
        isLastPositionSwitched: false,
        isIndexSwitched: false,
        isBookmarkSwitched: value,
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            widget.groupTitle,
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
          child: BlocBuilder<DisplayOnStartUpCubit, DisplayOnStartUpState>(
            builder: (context, displayOnStartUpState) {
              if (displayOnStartUpState is DisplayOnStartUpStateUpdated) {
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    CustomSwitchListTile(
                        title: context.translate.show_alfatiha,
                        subTitle: context.translate.start_the_app_show_page_one,
                        // enabled: cubit.bookmarksBox.isNotEmpty,
                        value: displayOnStartUpState.isPageOneSwitched,
                        onChanged: (value) {
                          _switch(1, value);
                          // setState(() {
                          //   isBookmarkSwitched = value;
                          //   print("isBookmarkSwitched=$isBookmarkSwitched");
                          // });
                          // context
                          //     .read<BookmarksCubit>()
                          //     .setShowBookmarksOnStart(value);
                        }),
                    AppConstants.appDivider(context, endIndent: 20, indent: 20),
                    CustomSwitchListTile(
                        title: context.translate.show_last_position,
                        subTitle: context
                            .translate.start_the_app_show_from_last_position,
                        // enabled: cubit.bookmarksBox.isNotEmpty,
                        value: displayOnStartUpState.isLastPositionSwitched,
                        onChanged: (value) {
                          _switch(2, value);
                        }),
                    AppConstants.appDivider(context, endIndent: 20, indent: 20),
                    CustomSwitchListTile(
                        title: context.translate.show_the_index,
                        subTitle:
                            context.translate.start_the_app_show_the_index,
                        // enabled: cubit.bookmarksBox.isNotEmpty,
                        value: displayOnStartUpState.isIndexSwitched,
                        onChanged: (value) {
                          _switch(3, value);
                        }),
                    AppConstants.appDivider(context, endIndent: 20, indent: 20),
                    CustomSwitchListTile(
                        title: context.translate.show_bookmarks_at_start,
                        subTitle:
                            context.translate.start_the_app_show_bookmarks,
                        // enabled: cubit.bookmarksBox.isNotEmpty,
                        value: displayOnStartUpState.isBookmarkSwitched,
                        onChanged: (value) {
                          _switch(4, value);
                        }),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }
}
