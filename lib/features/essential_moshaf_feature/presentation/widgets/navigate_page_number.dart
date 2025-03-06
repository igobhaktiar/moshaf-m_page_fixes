import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/lr_page_number_navigation.dart';

import '../cubit/zoom_cubit/zoom_enum.dart';

class NavigateByPageNumberListView extends StatefulWidget {
  const NavigateByPageNumberListView({
    Key? key,
    this.isBottomOpened = false,
  }) : super(key: key);

  final bool isBottomOpened;

  @override
  State<NavigateByPageNumberListView> createState() =>
      _NavigateByPageNumberListViewState();
}

class _NavigateByPageNumberListViewState
    extends State<NavigateByPageNumberListView> {
  Timer? _autoHideTimer;
  bool _isScrolling = false;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    // We'll set up the scroll controller in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the controller from the cubit
    _scrollController =
        EssentialMoshafCubit.get(context).navigateByPageNumberController;

    // Add listeners to detect scrolling
    _scrollController?.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController == null) return;

    // If the user is scrolling
    if (_scrollController!.position.isScrollingNotifier.value) {
      // Cancel any pending auto-hide
      _autoHideTimer?.cancel();

      // Mark as scrolling
      setState(() {
        _isScrolling = true;
      });
    } else if (_isScrolling) {
      // Scrolling just stopped, start the timer
      setState(() {
        _isScrolling = false;
      });
      _startAutoHideTimer(context);
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _scrollController?.removeListener(_scrollListener);
    super.dispose();
  }

  void _startAutoHideTimer(BuildContext context) {
    // Cancel any existing timer first
    _autoHideTimer?.cancel();

    // Start a new timer for 3 seconds
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      final cubit = EssentialMoshafCubit.get(context);
      if (cubit.isShowNavigateByPage && !_isScrolling) {
        cubit.showBottomNavigateByPageLayer(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBottomOpened) {
      return Positioned(
        bottom: 0,
        child: BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
          builder: (BuildContext context, EssentialMoshafState state) {
            final cubit = EssentialMoshafCubit.get(context);

            // Start auto-hide timer when the navigation bar becomes visible
            // but only if we're not currently scrolling
            if (cubit.isShowNavigateByPage && !_isScrolling) {
              _startAutoHideTimer(context);
            }

            return BlocBuilder<ZoomCubit, ZoomState>(
              builder: (context, zoomCubitState) {
                if (ZoomService().getZoomEnumFromPercentage(
                        zoomCubitState.zoomPercentage) ==
                    ZoomEnum.medium) {
                  return const SizedBox();
                } else {
                  return GestureDetector(
                    // Cancel auto-hide on tap
                    onTap: () {
                      _autoHideTimer?.cancel();
                      if (!_isScrolling) {
                        _startAutoHideTimer(context);
                      }
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.enteringAnimationDuration,
                      curve: Curves.easeOut,
                      height: cubit.isShowNavigateByPage ? 80.0 : 0,
                      width: context.width,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      color: context.isDarkMode
                          ? AppColors.cardBgDark
                          : AppColors.lightGrey,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo is ScrollStartNotification) {
                            _autoHideTimer?.cancel();
                            setState(() {
                              _isScrolling = true;
                            });
                          } else if (scrollInfo is ScrollEndNotification) {
                            setState(() {
                              _isScrolling = false;
                            });
                            _startAutoHideTimer(context);
                          }
                          return true;
                        },
                        child: ListView.builder(
                          itemCount: 302,
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          itemBuilder: (BuildContext context, int index) {
                            final rightPage = index * 2 + 1;
                            return RightAndLeftPageIndicator(
                                rightPage: rightPage);
                          },
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
