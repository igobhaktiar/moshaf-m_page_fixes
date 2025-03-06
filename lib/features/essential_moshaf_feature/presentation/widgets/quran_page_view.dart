import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/moshaf_main_scaffold_wrapper.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/quran_page_widget.dart'
    show QuranPageWidget;
import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';

import '../../../../core/utils/app_context.dart';
import '../cubit/bottom_sheet_cubit.dart';
import '../cubit/bottom_widget_cubit/bottom_widget_cubit.dart';

class QuranPageView extends StatefulWidget {
  const QuranPageView({
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
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
      listener: (context, state) {},
      builder: (context, state) {
        return SlideWrapper(
          child: PageView.builder(
            physics: widget.isZooming
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            key: widget.pageViewKey,
            controller: EssentialMoshafCubit.get(context).moshafPageController,
            itemCount: 604,
            onPageChanged: (index) {
              print("QuranPageView onPageChanged: $index");
              _handlePageChange(index, context);
            },
            itemBuilder: (context, index) => QuranPageWidget(
                isZooming: widget.isZooming,
                isOpened: widget.isBottomOpened,
                actualHeight: widget.actualHeight,
                actualWidth: widget.actualWidth,
                leftPadding: widget.leftPadding,
                rightPadding: widget.rightPadding,
                index: index),
          ),
        );
      },
    );
  }

  void _handlePageChange(int index, BuildContext context) async {
    final isOpened = BottomWidgetCubit.get(AppContext.getAppContext()!)
        .getBottomWidgetState(AppContext.getAppContext()!);
    int currentViewIndex = 0;

    if (isOpened) {
      currentViewIndex =
          AppContext.getAppContext()!.read<BottomSheetCubit>().getViewIndex();

      print("currentViewIndex: $currentViewIndex");
      AppContext.getAppContext()!
          .read<BottomWidgetCubit>()
          .setBottomWidgetState(
        scrollDownTopPage: !context.isLandscape,
        false,
        afterExecutionFunction: () {
          Future.delayed(const Duration(milliseconds: 600), () {
            AppContext.getAppContext()!
                .read<BottomWidgetCubit>()
                .setBottomWidgetState(
                  true,
                  scrollDownTopPage: false,
                  customIndex: currentViewIndex,
                );
          });
        },
      );
    } else {
      BuildContext? appContext = AppContext.getAppContext();
      if (appContext != null) {
        if (ZoomService().isOnTapEnable(appContext)) {
          appContext
              .read<EssentialMoshafCubit>()
              .showBottomNavigateByPageLayer(true);
        }
      }
    }

    // Change navigation to use jumpToPage: true for faster page transitions
    context
        .read<EssentialMoshafCubit>()
        .navigateToPage(index + 1, jumpToPage: true);

    // Update listening state
    context.read<ListeningCubit>().changeCurrentPage(index + 1);
    print("QuranPageView - Page changed to: $index");

    // Initialize AyahRenderBlocHelper with the correct page index
    AyahRenderBlocHelper.pageChangeInitialize(
      context,
      index,
      defaultTransition: false,
    );
  }
}
