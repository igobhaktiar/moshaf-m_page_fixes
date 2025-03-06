import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/two_pages_widget.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';

class QuranTwoPageView extends StatefulWidget {
  const QuranTwoPageView({
    super.key,
    required this.pageViewKey,
    required this.actualWidth,
    required this.actualHeight,
    required this.leftPadding,
    required this.rightPadding,
    required this.isBottomOpened,
    this.isZooming = false,
  });
  final GlobalKey pageViewKey;
  final double actualWidth;
  final double actualHeight;
  final double leftPadding;
  final double rightPadding;
  final bool isZooming, isBottomOpened;

  @override
  State<QuranTwoPageView> createState() => _QuranTwoPageViewState();
}

class _QuranTwoPageViewState extends State<QuranTwoPageView> {
  @override
  void initState() {
    super.initState();
    // Set the initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentPage = EssentialMoshafCubit.get(context).currentPage;
      log("Initial page in cubit: $currentPage");

      // Initialize AyahRenderBlocHelper with the current page
      AyahRenderBlocHelper.pageChangeInitialize(
        context,
        currentPage + 1, // Add 1 because navigateToPage expects 1-indexed
        defaultTransition: false,
      );

      // Make sure PageView controller is at the right index
      if (EssentialMoshafCubit.get(context).moshafPageController.hasClients) {
        final pageViewIndex = currentPage ~/ 2;
        if (EssentialMoshafCubit.get(context).moshafPageController.page !=
            pageViewIndex) {
          EssentialMoshafCubit.get(context)
              .moshafPageController
              .jumpToPage(pageViewIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        physics: widget.isZooming
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        key: widget.pageViewKey,
        controller: EssentialMoshafCubit.get(context).moshafPageController,
        itemCount: 302,
        onPageChanged: (index) async {
          // The PageView index represents pairs of pages (0 = pages 0,1; 1 = pages 2,3; etc.)
          int firstPageIndex = index * 2;

          // Log current state for debugging
          log("PageView index changed to: $index");
          log("Calculated firstPageIndex: $firstPageIndex");
          log("Current page in cubit: ${EssentialMoshafCubit.get(context).currentPage}");

          // navigateToPage expects a 1-indexed page, but we work with 0-indexed internally
          // so we need to add 1 before calling it
          context
              .read<EssentialMoshafCubit>()
              .navigateToPage(firstPageIndex + 1, jumpToPage: false);

          // AyahRenderBlocHelper.pageChangeInitialize also expects a 1-indexed page
          AyahRenderBlocHelper.pageChangeInitialize(
            context,
            firstPageIndex + 1,
            defaultTransition: false,
          );
        },
        itemBuilder: (context, index) {
          // index is 0-based, so we multiply by 2 to get the actual page number
          final firstPageIndex = index * 2;
          final secondPageIndex = firstPageIndex + 1;

          // Make sure these indexes correctly map to your page data
          return TwoPagesWidget(
              firstPageIndex: firstPageIndex, secondPageIndex: secondPageIndex);
        });
  }
}
