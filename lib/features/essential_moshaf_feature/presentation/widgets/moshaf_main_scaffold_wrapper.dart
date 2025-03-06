import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/language_service.dart';
import 'package:qeraat_moshaf_kwait/features/drawer/data/data_sources/drawer_constants.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zooming_bloc/zooming_bloc.dart';
import 'package:zoom_widget/zoom_widget.dart' as zw;
import 'package:zoom_widget/zoom_widget.dart';

import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/debouncer.dart';
import '../../../bookmarks/presentation/cubit/share_cubit/share_cubit.dart';
import '../../../bookmarks/presentation/screens/theme_cubit.dart';
import '../../../drawer/presentation/widgets/moshaf_drawer.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import '../../../main/presentation/cubit/moshaf_background_color_cubit/moshaf_background_color_cubit.dart';
import '../cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import '../cubit/essential_moshaf_cubit.dart';
import '../cubit/zoom_cubit/zoom_enum.dart';
import 'multi_share_floating_action.dart';

class MoshafMainScaffoldWrapper extends StatelessWidget {
  const MoshafMainScaffoldWrapper({
    super.key,
    required this.body,
  });
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (context, essentialMoshafCubitState) {
        bool isShownToggleValue = false;
        isShownToggleValue = EssentialMoshafCubit.get(context).isToShowAppBar;
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (BuildContext context, ThemeState state) {
            return BlocBuilder<MoshafBackgroundColorCubit,
                MoshafBackgroundColorState>(
              builder: (context, moshafBackgroundColorState) {
                return BlocBuilder<ShareCubit, ShareState>(
                  builder: (context, shareState) {
                    bool isShare = false;
                    if (shareState is ShareLoaded) {
                      isShare = true;
                    }

                    bool isRightAligned =
                        LanguageService.isLanguageRtl(context);

                    return Scaffold(
                      key: AppConstants.moshafScaffoldKey,
                      onDrawerChanged: (bool isDrawerOpened) {
                        if (isDrawerOpened) {
                          BottomWidgetCubit.get(AppContext.getAppContext()!)
                              .setBottomWidgetState(false);
                        }
                      },
                      onEndDrawerChanged: (bool isDrawerOpened) {
                        if (isDrawerOpened) {
                          BottomWidgetCubit.get(AppContext.getAppContext()!)
                              .setBottomWidgetState(false);
                        }
                      },
                      endDrawer: !isRightAligned
                          ? MoshafDrawer(
                              closeDrawer: () => DrawerConstants.closeDrawer(),
                            )
                          : null,
                      drawer: isRightAligned
                          ? MoshafDrawer(
                              closeDrawer: () => DrawerConstants.closeDrawer(),
                            )
                          : null,
                      floatingActionButton: isShare
                          ? MultiShareFloatingAction(
                              shareState: shareState,
                            )
                          : isShownToggleValue
                              ? const SizedBox()
                              : _HamburgerMenu(
                                  scaffoldKey: AppConstants.moshafScaffoldKey,
                                ),
                      floatingActionButtonLocation: isShare
                          ? FloatingActionButtonLocation.startFloat
                          : FloatingActionButtonLocation.startTop,
                      resizeToAvoidBottomInset: false,
                      backgroundColor: state.brightness == Brightness.light
                          ? moshafBackgroundColorState.currentColor
                          // state.pageBgcolor
                          : null,
                      body: body,

                      // ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class ZoomWrapper extends StatefulWidget {
  const ZoomWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ZoomWrapper> createState() => _ZoomWrapperState();
}

class _ZoomWrapperState extends State<ZoomWrapper> {
  bool isZoomingOut = false;

  bool _maxZooming =
      false; // To prevent multiple zoom level changes in one gesture
  bool _zoomChanged =
      false; // To prevent multiple zoom level changes in one gesture

  final debouncer = Debouncer(milliseconds: 900);
  final debouncerForZoomout = Debouncer(milliseconds: 100);

  final zw.TransformationController _transformationController =
      zw.TransformationController();
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoomMaxState() {
    debouncerForZoomout.run(() {
      setState(() {
        _transformationController.value = Matrix4.identity(); // Reset zoom
      });
    });
  }

  void _handleZoom(int pageIndex, double scale) {
    if (_zoomChanged) {
      return; // Prevent multiple changes during a single gesture
    }

    setState(() {
      // Zoom in: Scale crosses 1.2 threshold and the current zoom level is less than 3

      if (scale > 1.1) {
        print("Updating isZooming to ${scale != 1.0}");
        BlocProvider.of<ZoomingBloc>(context).add(
          const UpdateZoomingStatus(isZooming: true),
        );
        _zoomChanged = true; // Mark zoom change for this gesture
        // widget.zoomChangeFunction(_zoomChanged);
        if (ZoomService().getCurrentZoomEnum(context) == ZoomEnum.extralarge) {
          _maxZooming = true;
          isZoomingOut = false;
        }
        print("ZOOMING");

        ZoomService().setZoomInOut(context);
      }
      // Zoom out: Scale crosses 0.8 threshold and the current zoom level is greater than 1
      else if (scale < 0.9) {
        print("Updating isZooming to ${scale != 1.0}");
        BlocProvider.of<ZoomingBloc>(context).add(
          const UpdateZoomingStatus(isZooming: true),
        );
        _zoomChanged = true; // Mark zoom change for this gesture
        // widget.zoomChangeFunction(_zoomChanged);
        print("ZOOMING O");
        ZoomService().setZoomInOut(
          context,
          isZoomIn: false,
        );
      }
    });
  }

  void _resetZoomState() {
    _zoomChanged = false; // Allow zoom changes for the next gesture
    debouncer.run(() {
      print("Resetting isZooming to false");
      BlocProvider.of<ZoomingBloc>(context).add(
        const UpdateZoomingStatus(isZooming: false),
      );
    });

    // widget.zoomChangeFunction(_zoomChanged);
  }

  Widget _gestureDisplay() {
    if (_maxZooming) {
      return Zoom(
        enableScroll: false,
        doubleTapZoom: false,
        scrollWeight: 5,
        opacityScrollBars: 0,
        transformationController: _transformationController,
        onPanUpPosition: (offset) {
          _resetZoomMaxState();
        },
        onScaleUpdate: (scale, zoom) {
          if (zoom < 1) {
            setState(() {
              if (!isZoomingOut) {
                _maxZooming = false;
                isZoomingOut = true;
              }
            });
          }
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.97,
          child: widget.child,
        ),
      );
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.97,
        child: GestureDetector(
          onScaleUpdate: (details) {
            // Detect zoom gestures and handle zoom levels
            _handleZoom(
                AyahRenderBlocHelper.getPageIndex(context), details.scale);
          },
          onScaleEnd: (details) {
            _resetZoomState();
          },
          child: widget.child,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _gestureDisplay();
  }
}

class SlideWrapper extends StatefulWidget {
  const SlideWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SlideWrapper> createState() => _SlideWrapperState();
}

class _SlideWrapperState extends State<SlideWrapper> {
  double totalDistance = 0.0;

  bool _zoomChanged =
      false; // To prevent multiple zoom level changes in one gesture

  void _handleZoom(int pageIndex, double scale) {
    if (_zoomChanged) {
      return; // Prevent multiple changes during a single gesture
    }

    setState(() {
      // Zoom in: Scale crosses 1.2 threshold and the current zoom level is less than 3

      if (scale > 1.02) {
        _zoomChanged = true; // Mark zoom change for this gesture
        // widget.zoomChangeFunction(_zoomChanged);
        // if (ZoomService().getCurrentZoomEnum(context) == ZoomEnum.extralarge) {
        //   _maxZooming = true;
        //   isZoomingOut = false;
        // }
        print("ZOOMING");

        ZoomService().setZoomInOut(context);
        print("Updating isZooming to ${scale != 1.0}");
        BlocProvider.of<ZoomingBloc>(context).add(
          const UpdateZoomingStatus(isZooming: true),
        );
      }
      // Zoom out: Scale crosses 0.8 threshold and the current zoom level is greater than 1
      else if (scale < 0.98) {
        _zoomChanged = true; // Mark zoom change for this gesture
        // widget.zoomChangeFunction(_zoomChanged);
        print("ZOOMING O");
        ZoomService().setZoomInOut(
          context,
          isZoomIn: false,
        );
        print("Updating isZooming to ${scale != 1.0}");
        BlocProvider.of<ZoomingBloc>(context).add(
          const UpdateZoomingStatus(isZooming: true),
        );
      }
    });
  }

  int _distanceToMove({
    bool isNegative = false,
  }) {
    int totalDistance = 100;

    if (isNegative) {
      totalDistance = -1 * totalDistance;
    }
    return totalDistance;
  }

  void _handleSlide(DragEndDetails details) {
    if (totalDistance == 0.0) return;

    int pageIndex = AyahRenderBlocHelper.getPageIndex(context);

    if (totalDistance < _distanceToMove(isNegative: true) && pageIndex < 604) {
      // Left Swipe
      setState(() {
        EssentialMoshafCubit.get(AppContext.getAppContext()!)
            .moshafPageController
            .animateToPage(
              pageIndex - 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
      });
    } else if (totalDistance > _distanceToMove() && pageIndex >= 0) {
      // Right Swipe
      setState(() {
        EssentialMoshafCubit.get(AppContext.getAppContext()!)
            .moshafPageController
            .animateToPage(
              pageIndex + 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
      });
    }

    setState(() {
      totalDistance = 0.0; // Reset
    });
  }

  Widget _gestureDisplay() {
    return BlocBuilder<ZoomingBloc, ZoomingState>(
      builder: (context, zoomingState) {
        if (zoomingState is ZoomingStatus) {
          print(zoomingState.isZooming);
          if (!zoomingState.isZooming) {
            print("SLIDING ENABLED");
            return GestureDetector(
              onScaleStart: (details) {
                if (details.pointerCount == 2) {
                  print("Two fingers ssss");
                  BlocProvider.of<ZoomingBloc>(context).add(
                    const UpdateZoomingStatus(isZooming: true),
                  );
                }
              },
              onScaleUpdate: (details) {
                if (details.pointerCount == 2) {
                  print("Two fingers ssss ${details.scale}");
                  _handleZoom(AyahRenderBlocHelper.getPageIndex(context),
                      details.scale);
                }
              },
              onScaleEnd: (details) {
                setState(() {
                  _zoomChanged = false;
                });
              },
              onHorizontalDragUpdate: (details) {
                totalDistance += details.delta.dx;
              },
              onHorizontalDragEnd: _handleSlide,
              child: widget.child,
            );
          } else {
            print("SLIDING DISABLED");
            return widget.child;
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.97,
      child: _gestureDisplay(),
    );
  }
}

class _HamburgerMenu extends StatelessWidget {
  const _HamburgerMenu({
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  Color? _getFloatingActionBackgroundColor(BuildContext context) {
    if (context.theme.brightness == Brightness.dark) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Color? _getFloatingActionIconColor(BuildContext context) {
    if (context.theme.brightness == Brightness.dark) {
      return AppColors.white;
    } else {
      return AppColors.appBarBgDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: _getFloatingActionBackgroundColor(context),
        onPressed: () {
          bool isDrawerOpen = scaffoldKey.currentState?.isDrawerOpen ?? false;
          if (isDrawerOpen) {
            scaffoldKey.currentState?.closeDrawer();
          } else {
            scaffoldKey.currentState?.openDrawer();
          }
        },
        child:
            //  SvgPicture.asset(
            //   AppAssets.menuIcon,
            //   width: 18,
            //   color: context.theme.primaryIconTheme.color,
            //   fit: BoxFit.contain,
            // ),
            Icon(
          Icons.menu,
          color: _getFloatingActionIconColor(context),
        ), // Hamburger icon
      ),
    );
  }
}
