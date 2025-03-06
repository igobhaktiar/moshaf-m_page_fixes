import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart' show AppColors;
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart'
    show AppAssets;
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/drawer/data/data_sources/drawer_constants.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart'
    show
        BottomSheetCubit,
        BottomSheetOrdinaryState,
        BottomSheetState,
        BottomSheetTenQeraatState;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show ChangeMoshafType, EssentialMoshafCubit, EssentialMoshafState;
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../config/app_config/app_config.dart';
import '../../../../core/utils/language_service.dart';
import '../cubit/bottom_widget_cubit/bottom_widget_cubit.dart';

class MoshafHorizontalBottomSheet extends StatefulWidget {
  const MoshafHorizontalBottomSheet({Key? key}) : super(key: key);

  @override
  State<MoshafHorizontalBottomSheet> createState() =>
      _MoshafHorizontalBottomSheetState();
}

class _MoshafHorizontalBottomSheetState
    extends State<MoshafHorizontalBottomSheet>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<BottomSheetCubit>();
    if (tabController == null) {
      tabController = TabController(
        initialIndex: cubit.getViewIndex(),
        length: AppConfig.isQeeratView() ? 4 : 5,
        vsync: this,
      );

      tabController!.addListener(() {
        if (tabController!.indexIsChanging) {
          cubit.changeViewIndex(tabController!.index);
        }
      });
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.translate.localeName == AppStrings.arabicCode
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
        listener: (BuildContext context, EssentialMoshafState state) {
          if (state is ChangeMoshafType) {
            BottomSheetCubit.get(context).changeViewsType(state.moshafType);
            tabController?.animateTo(0);
          }
        },
        builder: (BuildContext context, EssentialMoshafState state) {
          return BlocBuilder<BottomWidgetCubit, BottomWidgetState>(
            builder: (context, bottomWidgetCubitState) {
              bool isOpened = false;
              if (bottomWidgetCubitState is BottomWidgetOpenState) {
                isOpened = bottomWidgetCubitState.isOpened;
              }
              if (isOpened) {
                return GestureDetector(
                  onPanEnd: (DragEndDetails dragEndDetails) {
                    if (dragEndDetails.velocity.pixelsPerSecond.distance >=
                        150) {
                      BottomWidgetCubit.get(context)
                          .setBottomWidgetState(false);
                      context.read<EssentialMoshafCubit>().hideFlyingLayers();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.transparent,
                    child: BlocConsumer<BottomSheetCubit, BottomSheetState>(
                      listener: (BuildContext context, BottomSheetState state) {
                        if (state is BottomSheetTenQeraatState ||
                            state is BottomSheetOrdinaryState) {
                          tabController?.animateTo(
                              context.read<BottomSheetCubit>().getViewIndex());
                        }
                      },
                      builder: (BuildContext context, BottomSheetState state) {
                        return Column(
                          children: [
                            ConvexAppBar.builder(
                                curveSize: 60,
                                top: -20,
                                height:
                                    LanguageService.isLanguageArabic(context)
                                        ? AppConfig.isQeeratView()
                                            ? 70
                                            : 90
                                        : 70,
                                elevation: 1,
                                controller: tabController,
                                backgroundColor: context.isDarkMode
                                    ? AppColors.tabBackgroundDark
                                    : AppColors.tabBackground,
                                count: _hollyQuranHeaders(context).length,
                                itemBuilder: Builder(
                                  items: _hollyQuranHeaders(context),
                                ),
                                onTap: (final i) {
                                  BottomSheetCubit.get(context)
                                      .changeViewIndex(i);
                                }),
                            Expanded(
                              child: Container(
                                width: context.width,
                                decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? AppColors.cardBgDark
                                        : AppColors.white,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(9)),
                                    border: Border.all(
                                        color: context.isDarkMode
                                            ? AppColors.bottomSheetBorderDark
                                            : AppColors.border,
                                        width: 1)),
                                //*current view is shown here
                                child: BottomSheetCubit.get(context)
                                    .currentBottomSheetView,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // ),
                );
              } else {
                return const SizedBox();
              }
            },
          );
        },
      ),
    );
  }

  List<TabItem> _hollyQuranHeaders(BuildContext context) {
    List<TabItem> itemsToReturn = [];
    if (AppConfig.isQeeratView()) {
      itemsToReturn.addAll(
        [
          TabItem(
              icon: SvgPicture.asset(
                context.theme.brightness == Brightness.dark
                    ? AppAssets.listenBorderDark
                    : AppAssets.listenBorder,
                width: 20,
                height: 20,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.listen,
                width: 20, height: 20,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
                // color: Colors.white,
              ),
              title: context.translate.readings),
          TabItem(
              icon: SvgPicture.asset(
                AppAssets.tafseerInactive,
                width: 20,
                height: 20,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.tafseerActive,
                width: 20,
                height: 20,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
              ),
              title: context.translate.osoul),
          TabItem(
              icon: SvgPicture.asset(
                AppAssets.fihris,
                width: 20,
                height: 20,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.fihris,
                width: 20,
                height: 20,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
              ),
              title: context.translate.shwahid),
          TabItem(
              icon: SvgPicture.asset(
                AppAssets.marginsIcon,
                width: 20,
                height: 20,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.marginsIcon,
                width: 20,
                height: 20,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
              ),
              title: context.translate.hwamish),
        ],
      );
    } else {
      itemsToReturn.addAll(
        [
          TabItem(
              icon: SvgPicture.asset(
                AppAssets.tafseerInactive,
                width: 20,
                height: 20,
                color: context.isDarkMode ? Colors.white : null,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.tafseerActive,
                width: 20,
                height: 20,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
              ),
              title: context.translate.tafseer),
          TabItem(
              icon: Image.asset(
                DrawerConstants.drawerTranslateIcon,
                width: 20,
                height: 20,
                color: context.isDarkMode
                    ? AppColors.white
                    : AppColors.inActiveIconColorDark,
              ),
              activeIcon: Image.asset(
                DrawerConstants.drawerTranslateIcon,
                width: 20,
                height: 20,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
              ),
              title: context.translate.translation),

          TabItem(
              icon: SvgPicture.asset(
                context.theme.brightness == Brightness.dark
                    ? AppAssets.listenBorderDark
                    : AppAssets.listenBorder,
                width: 15,
                height: 16,
                color: context.isDarkMode ? AppColors.white : null,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.listen,
                width: 20, height: 20,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
                // color: Colors.white,
              ),
              title: context.translate.listen),
          TabItem(
              activeIcon: SvgPicture.asset(
                AppAssets.notesIcon,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
                width: 20, height: 20,

                // color: Colors.white,
              ),
              icon: SvgPicture.asset(
                AppAssets.notesIcon,
                width: 20, height: 20,
                color: context.isDarkMode
                    ? AppColors.white
                    : AppColors.inActiveIconColorDark,
                // color: Colors.white,
              ),
              title: context.translate.notes),
          TabItem(
              activeIcon: SvgPicture.asset(
                AppAssets.bookmarkFilled,
                color: context.isDarkMode
                    ? AppColors.tabBackgroundDark
                    : Colors.white,
                width: 20, height: 20,

                // color: Colors.white,
              ),
              icon: SvgPicture.asset(
                AppAssets.bookmarkOutlined,
                width: 20, height: 20,
                color: context.isDarkMode ? AppColors.white : null,
                // color: Colors.white,
              ),
              title: context.translate.bookmarks),
          // TabItem(
          //     activeIcon: SvgPicture.asset(
          //       AppAssets.notesIcon,
          //       color:
          //           context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          //       width: 20, height: 20,

          //       // color: Colors.white,
          //     ),
          //     icon: SvgPicture.asset(
          //       AppAssets.notesIcon,
          //       width: 20, height: 20,
          //       color: context.isDarkMode
          //           ? AppColors.white
          //           : AppColors.inActiveIconColorDark,
          //       // color: Colors.white,
          //     ),
          //     title: context.translate.notes),
        ],
      );
    }
    return itemsToReturn;
  }

  List<TabItem> tenQeraatHeaders(BuildContext context) {
    return [
      TabItem(
          icon: SvgPicture.asset(
            context.theme.brightness == Brightness.dark
                ? AppAssets.listenBorderDark
                : AppAssets.listenBorder,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.listen,
            width: 20, height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
            // color: Colors.white,
          ),
          title: context.translate.readings),
      TabItem(
          icon: SvgPicture.asset(
            AppAssets.tafseerInactive,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.tafseerActive,
            width: 20,
            height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          ),
          title: context.translate.osoul),
      TabItem(
          icon: SvgPicture.asset(
            AppAssets.fihris,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.fihris,
            width: 20,
            height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          ),
          title: context.translate.shwahid),
      TabItem(
          icon: SvgPicture.asset(
            AppAssets.marginsIcon,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.marginsIcon,
            width: 20,
            height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          ),
          title: context.translate.hwamish),
    ];
  }
}

class Builder extends DelegateBuilder {
  final List<TabItem> items;
  Builder({required this.items});

  @override
  Widget build(BuildContext context, int index, bool active) {
    dynamic currentIcon = (items[index].activeIcon != null && active)
        ? items[index].activeIcon
        : items[index].icon;
    return Material(
      color: Colors.transparent,
      child: buildIconAndTitle(active, currentIcon, index, context: context),
    );
  }

  Column buildIconAndTitle(bool active, currentIcon, int index,
      {required BuildContext context}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: active ? 0 : 10),
        Container(
            width: 50,
            alignment: Alignment.center,
            height: active ? 50 : 30, //-10
            decoration: BoxDecoration(
                color: active
                    ? (context.isDarkMode
                        ? AppColors.white
                        : AppColors.activeButtonColor)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(50)),
            child: (currentIcon is IconData)
                ? Icon(
                    currentIcon,
                    color: active ? Colors.white : const Color(0xFF968A7A),
                  )
                : FittedBox(
                    child: currentIcon,
                    fit: BoxFit.scaleDown,
                  )),
        SizedBox(height: active ? 12 : 0),
        Expanded(
          child: Text(
            items[index].title.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active || context.isDarkMode
                  ? (context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.activeButtonColor)
                  : const Color(0xFF968A7A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}
