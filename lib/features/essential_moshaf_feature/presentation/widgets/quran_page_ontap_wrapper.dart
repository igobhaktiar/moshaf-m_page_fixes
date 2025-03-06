import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/ayah_mini_dialog_cubit/ayah_mini_dialog_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/settings_screens/page_navigator_dialog.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../../../core/data_sources/all_ayat_with_tashkeel.dart';
import '../../../../core/responsiveness/responsive_framework_helper.dart';
import '../../../../core/widgets/debouncer.dart';
import '../../../bookmarks/presentation/cubit/share_cubit/share_cubit_helper_service.dart';
import '../../../bookmarks/presentation/widgets/add_bookmark_or_fav_dialog.dart';
import '../../../bookmarks/presentation/widgets/ayah_options_mini_dialog.dart';
import '../../../listening/presentation/cubit/listening_cubit.dart';
import '../../../main/presentation/cubit/ayat_menu_control_cubit/ayat_menu_control_cubit.dart';
import '../../../main/presentation/cubit/ayat_menu_control_cubit/ayat_menu_control_service.dart';
import '../../data/models/ayat_swar_models.dart';
import '../cubit/bottom_sheet_cubit.dart';
import '../cubit/bottom_widget_cubit/bottom_widget_service.dart';
import '../cubit/essential_moshaf_cubit.dart';

class QuranPageOnTapWrapper extends StatefulWidget {
  const QuranPageOnTapWrapper({
    super.key,
    required this.child,
    required this.isBottomOpened,
    required this.height,
  });
  final Widget child;
  final double height;
  final bool isBottomOpened;

  @override
  State<QuranPageOnTapWrapper> createState() => _QuranPageOnTapWrapperState();
}

class _QuranPageOnTapWrapperState extends State<QuranPageOnTapWrapper> {
  Offset? _longPressStartPosition;

  void _onTapEvent(TapUpDetails details) {
    int soraId = -1;
    int ayahId = -1;
    bool isTwoPaged = ResponsiveFrameworkHelper().isTwoPaged();

    if (ZoomService().isOnTapEnable(context) && !isTwoPaged) {
      try {
        final BuildContext layoutContext;
        bool isFirstPage = true;

        layoutContext = AyahRenderBlocHelper.layoutContext!;

        //Check if valid render Box;
        late final RenderBox renderBox;
        try {
          renderBox = layoutContext.findRenderObject() as RenderBox;
        } catch (e) {
          AyahRenderBlocHelper.pageChangeInitialize(
            context,
            AyahRenderBlocHelper.getPageIndex(context),
          );
          Future.delayed(const Duration(seconds: 3), () {
            renderBox = layoutContext.findRenderObject() as RenderBox;
          });
        }

        final Offset localPosition =
            renderBox.globalToLocal(details.globalPosition);

        List<int> ids = AyahRenderBlocHelper.checkAyahHotspots(
          localPosition,
          layoutContext,
          isFirstPage: isFirstPage,
        );
        if (ids.length > 2 && ids[2] == 1) {
          showPageNavigatorDialog(
              context, AyahRenderBlocHelper.getPageIndex(context));
          return;
        }
        print("IDSSSS: $ids");
        soraId = ids[0];
        ayahId = ids[1];
        setState(() {});
        if (ayahId != -1 && soraId != -1) {
          ShareCubitHelperService shareCubitHelperService =
              ShareCubitHelperService();
          final bool isMultiShareTurnedOn =
              shareCubitHelperService.isMultishareTurnedOn(context);
          if (isMultiShareTurnedOn) {
            AyahModel tappedAyah = EssentialMoshafCubit.get(context)
                .allAyatWithTashkeelList
                .where(
                  (ayah) =>
                      ayahId == ayah.numberInSurah &&
                      soraId ==
                          EssentialMoshafCubit.get(context)
                              .swarListForFihris
                              .where(
                                  (surah) => surah.number == ayah.surahNumber)
                              .toList()
                              .single
                              .number,
                )
                .toList()
                .single;

            shareCubitHelperService.addAyahToShareList(
              context,
              ayah: tappedAyah,
              allAyatWithTashkeel: allAyatWithTashkeel,
            );
          } else {
            context.read<EssentialMoshafCubit>().hideFlyingLayers();
            context.read<EssentialMoshafCubit>().hidePagesPopUp();
            // context.read<EssentialMoshafCubit>().hideBottomSheetSections();
            context.read<EssentialMoshafCubit>().togglePageNavigationOrFlying();
            int currentViewIndex = AppContext.getAppContext()!
                .read<BottomSheetCubit>()
                .getViewIndex();
            // AppContext.getAppContext()!
            //     .read<BottomWidgetCubit>()
            //     .setBottomWidgetState(
            //       true,
            //       scrollDownTopPage: true,
            //       customIndex: currentViewIndex,
            //       scrollOffset: localPosition,
            //     );
            AppContext.getAppContext()!
                .read<BottomWidgetCubit>()
                .reloadBottomWidgetState(
                  AppContext.getAppContext()!,
                  scrollDownTopPage: true,
                  customIndex: currentViewIndex,
                  scrollOffset: localPosition,
                  surahId: soraId,
                  ayahId: ayahId,
                );
          }
        } else {
          debugPrint('Couldnt fetch ayah or sura ID');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void _onLongPressStartEvent(LongPressStartDetails details) {
    _longPressStartPosition = details.globalPosition;
    setState(() {});
  }

  void _onLongPressEvent() {
    if (ZoomService().isOnTapEnable(context) &&
        _longPressStartPosition != null) {
      int soraId = -1;
      int ayahId = -1;
      final BuildContext layoutContext;
      bool isTwoPaged = ResponsiveFrameworkHelper().isTwoPaged();
      bool isFirstPage = true;
      if (isTwoPaged) {
        // Get screen width
        double screenWidth = MediaQuery.of(context).size.width;

        // Get x position of the tap
        double tapX = _longPressStartPosition!.dx;

        if (tapX < screenWidth / 2) {
          //'Tapped on the left side of the screen hence page 2
          layoutContext = AyahRenderBlocHelper.secondPageLayoutContext!;
          isFirstPage = false;
        } else {
          //'Tapped on the right side of the screen hence page 1
          layoutContext = AyahRenderBlocHelper.firstPageLayoutContext!;
          isFirstPage = true;
        }
      } else {
        layoutContext = AyahRenderBlocHelper.layoutContext!;
      }

      final RenderBox renderBox = layoutContext.findRenderObject() as RenderBox;
      final Offset localPosition =
          renderBox.globalToLocal(_longPressStartPosition!);
      // final Offset localPosition = _longPressStartPosition!;
      List<int> ids = AyahRenderBlocHelper.checkAyahHotspots(
        localPosition,
        layoutContext,
        isFirstPage: isFirstPage,
      );
      soraId = ids[0];
      ayahId = ids[1];
      setState(() {});
      if (ayahId != -1 && soraId != -1) {
        // if (context.read<EssentialMoshafCubit>().isInTenReadingsMode()) {
        //   context.read<EssentialMoshafCubit>().showBottomSheetSections();
        // } else {
        AyatMenu ayatMenu =
            context.read<AyatMenuControlCubit>().getCurrentMenu();

        //Open Small Dialog
        if (ayatMenu == AyatMenu.compact) {
          showAyahOptionsMiniDialog(
            context,
            EssentialMoshafCubit.get(context)
                .allAyatWithTashkeelList
                .where((ayah) =>
                    ayahId == ayah.numberInSurah &&
                    soraId ==
                        EssentialMoshafCubit.get(context)
                            .swarListForFihris
                            .where((surah) => surah.number == ayah.surahNumber)
                            .toList()
                            .single
                            .number)
                .toList()
                .single,
            scrollOffset: localPosition,
          );
        }
        //Open Long Dialog for default case
        else {
          showAyahOptionsDialog(
            context,
            EssentialMoshafCubit.get(context)
                .allAyatWithTashkeelList
                .where(
                  (ayah) =>
                      ayahId == ayah.numberInSurah &&
                      soraId ==
                          EssentialMoshafCubit.get(context)
                              .swarListForFihris
                              .where(
                                  (surah) => surah.number == ayah.surahNumber)
                              .toList()
                              .single
                              .number,
                )
                .toList()
                .single,
            scrollOffset: localPosition,
          );
        }
        // }
      } else {
        debugPrint('Couldnt fetch ayah or sura ID');
      }
    } else {
      debugPrint('Long Press Position is null or zoom is not enabling ontap');
    }
  }

  void _onScreenTapFunctions() {
    AyahMiniDialogCubit.get(context).closeMiniDialog();
    // AyahRenderBlocHelper.removeHisbAndUpdateBloc();
  }

  void _changePage(int index) {
    AyahRenderBlocHelper.pageChangeInitialize(
      context,
      index,
      defaultTransition: false,
    );

    final isOpened = BottomWidgetCubit.get(AppContext.getAppContext()!)
        .getBottomWidgetState(AppContext.getAppContext()!);

    if (isOpened) {
      int currentViewIndex =
          AppContext.getAppContext()!.read<BottomSheetCubit>().getViewIndex();
      AppContext.getAppContext()!
          .read<BottomWidgetCubit>()
          .setBottomWidgetState(false, afterExecutionFunction: () {
        Future.delayed(
            const Duration(
              milliseconds: 600,
            ), () {
          AppContext.getAppContext()!
              .read<BottomWidgetCubit>()
              .setBottomWidgetState(
                true,
                scrollDownTopPage: false,
                customIndex: currentViewIndex,
              );
        });
      });
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

    debugPrint("PAGE NUMBER: ${index + 1}");
    context
        .read<EssentialMoshafCubit>()
        .navigateToPage(index + 1, jumpToPage: false);
    context.read<ListeningCubit>().changeCurrentPage(index + 1);
  }

  void _handleSlide(DragEndDetails details) {
    double velocity = details.velocity.pixelsPerSecond.dx;
    print(velocity);
    if (totalDistance == 0.0) return;
    int pageIndex = AyahRenderBlocHelper.getPageIndex(context);

    if (totalDistance < -100 && pageIndex < 604) {
      // Left Swipe
      setState(() {
        EssentialMoshafCubit.get(AppContext.getAppContext()!)
            .moshafPageController
            .animateToPage(
              pageIndex - 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );

        // _changePage(pageIndex - 1);
      });
    } else if (totalDistance > 100 && pageIndex >= 0) {
      // Right Swipe
      setState(() {
        // _changePage(pageIndex + 1);

        EssentialMoshafCubit.get(AppContext.getAppContext()!)
            .moshafPageController
            .animateToPage(
              pageIndex + 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
        // (
        //   pageIndex + 1,
        //   // slidingNavigation: true,
        // );
      });
    }
    print("Final total distance: $totalDistance");
    print("Horizontal velocity: ${details.velocity.pixelsPerSecond.dx}");
    totalDistance = 0.0; // Reset
  }

  final debouncer = Debouncer(milliseconds: 3000);

  bool _zoomChanged =
      false; // To prevent multiple zoom level changes in one gesture

  bool _maxZooming =
      false; // To prevent multiple zoom level changes in one gesture

  void _handleZoom(int pageIndex, double scale) {
    if (_zoomChanged) {
      return; // Prevent multiple changes during a single gesture
    }

    setState(() {
      // Zoom in: Scale crosses 1.2 threshold and the current zoom level is less than 3
      if (scale > 1.1) {
        _zoomChanged = true; // Mark zoom change for this gesture
        // widget.zoomChangeFunction(_zoomChanged);
        if (ZoomService().getCurrentZoomEnum(context) == ZoomEnum.extralarge) {
          _maxZooming = true;
          isZoomingOut = false;
        }
        ZoomService().setZoomInOut(context);
      }
      // Zoom out: Scale crosses 0.8 threshold and the current zoom level is greater than 1
      else if (scale < 0.9) {
        _zoomChanged = true; // Mark zoom change for this gesture
        // widget.zoomChangeFunction(_zoomChanged);
        ZoomService().setZoomInOut(
          context,
          isZoomIn: false,
        );
      }
    });
  }

  void _resetZoomState() {
    _zoomChanged = false; // Allow zoom changes for the next gesture

    // widget.zoomChangeFunction(_zoomChanged);
  }

  double totalDistance = 0.0;

  Widget _stackToRender({
    bool isMaxZoomCondition = false,
  }) {
    if (isMaxZoomCondition) {
      return Stack(
        children: [
          Center(
            child: Container(
              // padding: const EdgeInsets.only(
              //   top: 40,
              // ),
              height: widget.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: widget.child,
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(5),
          //   width: MediaQuery.of(context).size.width,
          //   color: AppColors.backgroundColor,
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Expanded(
          //         child: Padding(
          //           padding: const EdgeInsets.only(
          //             left: 12.0,
          //             right: 12.0,
          //             top: 5.0,
          //           ),
          //           child: Text(
          //             context.translate.zoom_to_read_text_and_close,
          //             style: context.textTheme.bodyMedium!.copyWith(
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ),
          //       InkWell(
          //         onTap: () {
          //           setState(() {
          //             _maxZooming = false;
          //           });
          //         },
          //         child: Container(
          //           padding: const EdgeInsets.only(top: 5),
          //           height: 45,
          //           width: 50,
          //           child: const Icon(
          //             Icons.close,
          //             size: 30,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      );
    } else {
      return Stack(
        children: [
          Center(
            child: widget.child,
          ),
          GestureDetector(
            // onHorizontalDragUpdate: (details) {
            //   totalDistance += details.delta.dx;
            //   print("Current drag delta: ${details.delta.dx}");
            //   print("Total horizontal distance: $totalDistance");
            // },
            // onHorizontalDragEnd: _handleSlide,
            behavior: HitTestBehavior.translucent,
            onTapUp: (TapUpDetails details) {
              _onScreenTapFunctions();
              _onTapEvent(details);
            },
            onLongPressStart: (LongPressStartDetails details) {
              _onScreenTapFunctions();
              _onLongPressStartEvent(details);
            },
            onLongPress: () {
              if (!context.isLandscape) {
                _onScreenTapFunctions();
                _onLongPressEvent();
              }
            },
            // onScaleUpdate: (details) {
            //   // Detect zoom gestures and handle zoom levels
            //   _handleZoom(
            //       AyahRenderBlocHelper.getPageIndex(context), details.scale);
            // },

            // onScaleEnd: (details) {
            //   _resetZoomState();
            // },
            child: Container(
              height: widget.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
            ),
          ),
        ],
      );
    }
  }

  bool isZoomingOut = false;

  @override
  Widget build(BuildContext context) {
    // Condition where bottom slider is opened
    if (widget.isBottomOpened ||
        MediaQuery.of(context).orientation == Orientation.landscape) {
      return SingleChildScrollView(
        physics: _zoomChanged
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        controller: BottomWidgetService.topWidgetScrollController,
        child: SizedBox(
          height: widget.height * 0.97,
          child: _stackToRender(),
        ),
      );
    }
    // Condition where we have to zoom beyond the largest zoom
    if (_maxZooming) {
      return GestureDetector(
        onTapUp: (TapUpDetails details) {
          _onScreenTapFunctions();
          _onTapEvent(details);
        },
        onLongPressStart: (LongPressStartDetails details) {
          _onScreenTapFunctions();
          _onLongPressStartEvent(details);
        },
        onLongPress: () {
          _onScreenTapFunctions();
          _onLongPressEvent();
        },
        child: Zoom(
          enableScroll: false,
          doubleTapZoom: false,
          scrollWeight: 5,
          maxScale: 1,
          opacityScrollBars: 0,
          onScaleUpdate: (scale, zoom) {
            if (zoom < 1) {
              setState(() {
                if (!isZoomingOut) {
                  ZoomService().setZoomInOut(
                    context,
                    isZoomIn: false,
                  );
                  _maxZooming = false;
                  isZoomingOut = true;
                }
              });
            }
          },
          child: SizedBox(
            height: widget.height * 0.97,
            child: _stackToRender(
              isMaxZoomCondition: true,
            ),
          ),
        ),
      );
      // return PinchZoomReleaseUnzoomWidget(
      //   useOverlay: false,
      //   log: true,
      //   maxOverlayOpacity: 1,
      //   minScale: 1,
      //   overlayColor: Colors.white,
      //   twoFingersOn: () {},
      //   twoFingersOff: () {
      //     // setState(() {
      //     //   _maxZooming = false;
      //     // });
      //   },
      //   child: SizedBox(
      //     height: widget.height * 0.97,
      //     child: _stackToRender(
      //       isMaxZoomCondition: true,
      //     ),
      //   ),
      // );
    } else {
      // Every Default Case
      return _stackToRender();
    }
  }
}
