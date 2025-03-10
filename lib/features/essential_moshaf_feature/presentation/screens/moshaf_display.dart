import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/core/widgets/responsive_wrapper_display.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/hizb_animation_dialog.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/quran_two_page_view.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/widgets/media_player_control.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/show_juz_popup/show_juz_popup_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

import '../../../../core/utils/language_service.dart';
import '../../../bookmarks/presentation/widgets/ayah_option_moveable_mini_dialog.dart';
import '../cubit/zoom_cubit/zoom_enum.dart';
import '../widgets/moshaf_main_scaffold_wrapper.dart';
import '../widgets/navigate_hizb.dart';
import '../widgets/navigate_page_number.dart';
import '../widgets/navigate_surah.dart';
import '../widgets/quran_page_view.dart';
import '../widgets/top_navigation_bar/tapable_header.dart';
import '../widgets/top_navigation_bar/top_navigation_bar.dart';

class MoshafDisplay extends StatelessWidget {
  const MoshafDisplay({
    super.key,
    required this.pageViewKey,
    required this.size,
    required this.padding,
    required this.actualHeightBeforeSafeArea,
    required this.actualWidthBeforeSafeArea,
    required this.isBottomOpened,
    this.isZooming = false,
  });
  final GlobalKey pageViewKey;
  final Size size;
  final EdgeInsets padding;
  final bool isZooming, isBottomOpened;
  final double actualHeightBeforeSafeArea;
  final double actualWidthBeforeSafeArea;

  @override
  Widget build(BuildContext context) {
    bool isPlaying = context.watch<ListeningCubit>().player.playing;
    int zoomPercent = context.watch<ZoomCubit>().state.zoomPercentage;
    bool isBottomSheetOpened = context.watch<BottomWidgetCubit>().getBottomWidgetState(context);

    // Get current page from cubit for synchronization
    final essentialMoshafCubit = context.watch<EssentialMoshafCubit>();
    final currentPage = essentialMoshafCubit.currentPage;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MoshafMainScaffoldWrapper(
        body: Stack(
          children: [
            ZoomWrapper(
              child: Column(
                children: [
                  const SoorahListForFirstZoomLevel(),
                  Expanded(
                    child: ResponsiveWrapperDisplay(
                      childForMobile: Builder(builder: (context) {
                        // Synchronize the single-page view
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (essentialMoshafCubit.moshafPageController.hasClients && essentialMoshafCubit.moshafPageController.page?.round() != currentPage) {
                            print("Syncing single page view to page: $currentPage");
                            essentialMoshafCubit.moshafPageController.jumpToPage(currentPage);
                          }
                        });

                        return QuranPageView(
                          isBottomOpened: isBottomOpened,
                          isZooming: isZooming,
                          actualHeight: actualHeightBeforeSafeArea,
                          actualWidth: actualWidthBeforeSafeArea,
                          rightPadding: MediaQuery.of(context).padding.right,
                          leftPadding: MediaQuery.of(context).padding.left,
                          pageViewKey: pageViewKey,
                        );
                      }),
                      childForTablet: Builder(builder: (context) {
                        // Synchronize the two-page view
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final expectedPageViewIndex = currentPage ~/ 2;
                          if (essentialMoshafCubit.moshafPageController.hasClients && essentialMoshafCubit.moshafPageController.page?.round() != expectedPageViewIndex) {
                            print("Syncing two-page view to index: $expectedPageViewIndex (page: $currentPage)");
                            essentialMoshafCubit.moshafPageController.jumpToPage(expectedPageViewIndex);
                          }
                        });

                        return QuranTwoPageView(
                          isBottomOpened: isBottomOpened,
                          isZooming: isZooming,
                          actualHeight: actualHeightBeforeSafeArea,
                          actualWidth: actualWidthBeforeSafeArea,
                          rightPadding: MediaQuery.of(context).padding.right,
                          leftPadding: MediaQuery.of(context).padding.left,
                          pageViewKey: pageViewKey,
                        );
                      }),
                    ),
                  ),
                  const NavigateByJuzHizbQuarter(),
                ],
              ),
            ),
            Directionality(
              textDirection: LanguageService.isLanguageRtl(context) ? TextDirection.rtl : TextDirection.ltr,
              child: TopFlyingAppBar(
                withNavitateSourah: false,
                isLeftAligned: !LanguageService.isLanguageRtl(context),
              ),
            ),
            if (!isPlaying)
              NavigateByPageNumberListView(
                isBottomOpened: isBottomOpened,
              ),
            if (isPlaying && ZoomService().getZoomEnumFromPercentage(zoomPercent) != ZoomEnum.medium && !isBottomSheetOpened)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MediaPlayerControl(),
              ),
            if (!isBottomOpened) const TapableHeader(),
            const AyahOptionMoveableMiniDialog(),
            if (!ZoomService().isBorderEnable(zoomPercent))
              BlocBuilder<JuzPopupCubit, JuzPopupState>(
                builder: (context, state) {
                  if (state is JuzPopupEnabled) {
                    return state.showPopup ? HizbAnimatedDialog(zoomPercentage: zoomPercent) : const SizedBox();
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}
