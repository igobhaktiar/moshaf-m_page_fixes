import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/display_on_startup_cubit/display_on_start_up_cubit.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart' as di;
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/slide_pagee_transition.dart';
import '../../../../notification_service.dart';
import '../../../bookmarks/presentation/cubit/bookmarks_cubit/bookmarks_cubit.dart';
import '../../../bookmarks/presentation/widgets/saved_bookmarks_dialog.dart';
import '../../../khatmat/presentation/screens/khatmat/khatmat_screen.dart';
import '../../../listening/presentation/cubit/listening_cubit.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_rect_service.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import '../../../main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import '../../../main/presentation/screens/quran_fihris_screen.dart';
import '../cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import '../cubit/essential_moshaf_cubit.dart';
import '../widgets/custom_convex_bottom_sheet.dart';
import 'moshaf_display.dart';
import 'slideable_display.dart';

class OrdinaryMoshafMainScreen extends StatefulWidget {
  const OrdinaryMoshafMainScreen({super.key});

  @override
  State<OrdinaryMoshafMainScreen> createState() =>
      _OrdinaryMoshafMainScreenState();
}

class _OrdinaryMoshafMainScreenState extends State<OrdinaryMoshafMainScreen> {
  final GlobalKey pageViewKey = GlobalKey();
  final double _previousScale = 1.0;
  final double _currentScale = 1.0;
  final double _baseScale = 1.0;
  bool isZoomIn = true;
  bool isZooming = false; // Flag to track zoom state

  bool _isZoomInGesture(double currentScale, double previousScale) {
    return currentScale > previousScale;
  }

  bool _isZoomOutGesture(double currentScale, double previousScale) {
    return currentScale < previousScale;
  }

  @override
  void initState() {
    super.initState();

    AyahRectService.init();

    // if (widget.page != null && mounted) {
    //   context.read<EssentialMoshafCubit>().navigateToPage(widget.page!);
    // }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WakelockPlus.enabled.then((enabled) {
      if (!enabled) {
        WakelockPlus.enable();
      }
    });

    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    Future.delayed(const Duration(seconds: 5), () {
      if (context.read<BookmarksCubit>().checkToShowBookmarksOnStart()) {
        showSavedBookmarks(context);
      }
    });
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.read<DisplayOnStartUpCubit>().state.isBookmarkSwitched) {
          pushSlide(
            context,
            pushWithOverlayValues: true,
            screen: const BookmarksView(),
          );
        } else if (context
            .read<DisplayOnStartUpCubit>()
            .state
            .isIndexSwitched) {
          pushSlide(
            context,
            pushWithOverlayValues: true,
            screen: const FihrisScreen(),
          );
        } else if (context
            .read<DisplayOnStartUpCubit>()
            .state
            .isPageOneSwitched) {
          context.read<ListeningCubit>().changeCurrentPage(0);

          AyahRenderBlocHelper.pageChangeInitialize(
            context,
            0,
            defaultTransition: false,
          );
          Future.delayed(const Duration(seconds: 3), () {
            context
                .read<EssentialMoshafCubit>()
                .showBottomNavigateByPageLayer(false);
          });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //* Notifications Methods started

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      log("receivedNotification payload=${receivedNotification.payload}");
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const KhatmatScreen(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      log("selectedNotification payload=$payload");
      if (payload != null) {
        bool isRootViewshown = EssentialMoshafCubit.get(context).isShowFihris;
        if (!isRootViewshown) {
          EssentialMoshafCubit.get(context).toggleRootView();
        }
        EssentialMoshafCubit.get(context)
            .changeBottomNavBarToKhatmatWithPayload(payload);
      }
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    WakelockPlus.disable();
    super.dispose();
  }

  //* Notifications Methods ended
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final actualHeightBeforeSafeArea =
        size.height - padding.top - padding.bottom;
    final actualWidthBeforeSafeArea = size.width - padding.left - padding.right;
    // log("look== actual height:$actualHeightBeforeSafeArea, actual width:$actualWidthBeforeSafeArea, topPadding:${padding.top}, bottomPadding: ${padding.bottom}, rightPadding: ${padding.right}, leftPadding: ${padding.left}");
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.theme.appBarTheme.systemOverlayStyle!,
      child: WillPopScope(
        onWillPop: () {
          if (EssentialMoshafCubit.get(context).isToShowAppBar ||
              EssentialMoshafCubit.get(context).isToShowBottomSheet ||
              BottomWidgetCubit.get(context).getBottomWidgetState(context)) {
            EssentialMoshafCubit.get(context).hideFlyingLayers();
            // EssentialMoshafCubit.get(context).hideBottomSheetSections();
            BottomWidgetCubit.get(context).setBottomWidgetState(
              false,
              withoutAffectingSafeArea: true,
            );
            return Future.value(false);
          } else if (!EssentialMoshafCubit.get(context).isShowFihris) {
            EssentialMoshafCubit.get(context).toggleRootView();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: BlocProvider(
          create: (BuildContext context) =>
              di.getItInstance<ListeningCubit>()..init(),
          child: BlocListener<ListeningCubit, ListeningState>(
            listener: (context, state) {
              if (state is NavigateToCurrentAyahPageState) {
                context.read<EssentialMoshafCubit>().navigateToPage(state.page);
              }
              if (state is CheckYourNetworkConnectionState) {
                AppConstants.showToast(context,
                    msg: context.translate.check_your_internet_connection);
              }
            },
            child: Container(
              color: context.theme.brightness == Brightness.dark
                  ? AppColors.appBarBgDark
                  : AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: BlocBuilder<BottomWidgetCubit, BottomWidgetState>(
                  builder: (context, bottomWidgetState) {
                    if (bottomWidgetState is BottomWidgetOpenState) {
                      return context.isLandscape
                          ? MoshafDisplay(
                              isBottomOpened: bottomWidgetState.isOpened,
                              isZooming: isZooming,
                              pageViewKey: pageViewKey,
                              size: size,
                              padding: padding,
                              actualHeightBeforeSafeArea:
                                  actualHeightBeforeSafeArea,
                              actualWidthBeforeSafeArea:
                                  actualWidthBeforeSafeArea,
                            )
                          : SlideableDisplay(
                              isOpenOnlyTop: !bottomWidgetState.isOpened,
                              topWidget: MoshafDisplay(
                                isBottomOpened: bottomWidgetState.isOpened,
                                isZooming: isZooming,
                                pageViewKey: pageViewKey,
                                size: size,
                                padding: padding,
                                actualHeightBeforeSafeArea:
                                    actualHeightBeforeSafeArea,
                                actualWidthBeforeSafeArea:
                                    actualWidthBeforeSafeArea,
                              ),
                              bottomWidget: (context.isLandscape)
                                  //  ? const QeeratBottomHorizontalWidget()
                                  ? const SizedBox()
                                  : const CustomBottomConvextSheet(),
                            );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
