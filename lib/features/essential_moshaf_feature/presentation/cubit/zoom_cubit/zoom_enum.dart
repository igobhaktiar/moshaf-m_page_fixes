import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';

enum ZoomEnum { extralarge, large, medium, small }

class ZoomService {
  ZoomEnum defaultZoom = ZoomEnum.extralarge;

  void updateZoom(BuildContext context, {required ZoomEnum zoom}) {
    context.read<ZoomCubit>().setCurrentZoom(zoom);
  }

  void setZoomInOut(
    BuildContext context, {
    bool isZoomIn = true,
  }) {
    ZoomService zoomService = ZoomService();
    ZoomEnum currentZoomedPercentageEnum = ZoomService().getCurrentZoomEnum(
      context,
    );

    String svgData = AyahRenderBlocHelper.getSvgData(context);
    String pageNumber = AyahRenderBlocHelper.getPageNumber(context);
    String newSvgData = '';
    int index = AyahRenderBlocHelper.getPageIndex(context);

    if (isZoomIn) {
      //ZOOMING IN
      // if (currentZoomedPercentageEnum == ZoomEnum.small) {
      //   AyahRenderBlocHelper.initializePage(
      //     context,
      //     index: index,
      //     zoomPercentage: zoomService.zoomPercentage[ZoomEnum.medium]!,
      //   );
      //   // AyahSvgService.initWithZoom(
      //   //   context,
      //   //   zoomPercentage: zoomService.zoomPercentage[ZoomEnum.medium]!,
      //   // );
      //   debugPrint(ZoomEnum.medium.name);
      // } else
      if (currentZoomedPercentageEnum == ZoomEnum.medium) {
        AyahRenderBlocHelper.initializePage(
          context,
          index: index,
          zoomPercentage: zoomService.zoomPercentage[ZoomEnum.large]!,
        );
        // AyahSvgService.initWithZoom(
        //   context,
        //   zoomPercentage: zoomService.zoomPercentage[ZoomEnum.large]!,
        // );
        debugPrint(ZoomEnum.large.name);
      } else if (currentZoomedPercentageEnum == ZoomEnum.large) {
        AyahRenderBlocHelper.initializePage(
          context,
          index: index,
          zoomPercentage: zoomService.zoomPercentage[ZoomEnum.extralarge]!,
        );
        // AyahSvgService.initWithZoom(
        //   context,
        //   zoomPercentage: zoomService.zoomPercentage[ZoomEnum.extralarge]!,
        // );
        debugPrint(ZoomEnum.extralarge.name);
      }
    } else {
      //ZOOMING OUT
      if (currentZoomedPercentageEnum == ZoomEnum.extralarge) {
        AyahRenderBlocHelper.initializePage(
          context,
          index: index,
          zoomPercentage: zoomService.zoomPercentage[ZoomEnum.large]!,
        );

        // AyahSvgService.initWithZoom(
        //   context,
        //   zoomPercentage: zoomService.zoomPercentage[ZoomEnum.large]!,
        // );
        debugPrint(ZoomEnum.large.name);
      } else if (currentZoomedPercentageEnum == ZoomEnum.large) {
        AyahRenderBlocHelper.initializePage(
          context,
          index: index,
          zoomPercentage: zoomService.zoomPercentage[ZoomEnum.medium]!,
        );
        // AyahSvgService.initWithZoom(
        //   context,
        //   zoomPercentage: zoomService.zoomPercentage[ZoomEnum.medium]!,
        // );
        debugPrint(ZoomEnum.medium.name);
      }
      // else if (currentZoomedPercentageEnum == ZoomEnum.medium) {
      //   AyahRenderBlocHelper.initializePage(
      //     context,
      //     index: index,
      //     zoomPercentage: zoomService.zoomPercentage[ZoomEnum.small]!,
      //   );
      //   // AyahSvgService.initWithZoom(
      //   //   context,
      //   //   zoomPercentage: zoomService.zoomPercentage[ZoomEnum.small]!,
      //   // );
      //   debugPrint(ZoomEnum.small.name);
      // }
    }
  }

  void setZoom(
    BuildContext context,
  ) {
    ZoomService zoomService = ZoomService();
    ZoomEnum currentZoomedPercentageEnum = ZoomService().getCurrentZoomEnum(
      context,
    );

    int index = AyahRenderBlocHelper.getPageIndex(context);
    if (currentZoomedPercentageEnum == ZoomEnum.small) {
      AyahRenderBlocHelper.initializePage(
        context,
        index: index,
        zoomPercentage: zoomService.zoomPercentage[ZoomEnum.medium]!,
      );
      BottomWidgetCubit.get(context).setBottomWidgetState(false);
    } else if (currentZoomedPercentageEnum == ZoomEnum.medium) {
      AyahRenderBlocHelper.initializePage(
        context,
        index: index,
        zoomPercentage: zoomService.zoomPercentage[ZoomEnum.large]!,
      );
    } else if (currentZoomedPercentageEnum == ZoomEnum.large) {
      AyahRenderBlocHelper.initializePage(
        context,
        index: index,
        zoomPercentage: zoomService.zoomPercentage[ZoomEnum.extralarge]!,
      );
    } else if (currentZoomedPercentageEnum == ZoomEnum.extralarge) {
      AyahRenderBlocHelper.initializePage(
        context,
        index: index,
        zoomPercentage: zoomService.zoomPercentage[ZoomEnum.medium]!,
      );
      BottomWidgetCubit.get(context).setBottomWidgetState(false);
    }
    // else if (currentZoomedPercentageEnum == ZoomEnum.medium) {
    //   AyahRenderBlocHelper.initializePage(
    //     context,
    //     index: index,
    //     zoomPercentage: zoomService.zoomPercentage[ZoomEnum.large]!,
    //   );
    // } else if (currentZoomedPercentageEnum == ZoomEnum.extralarge) {
    //   AyahRenderBlocHelper.initializePage(
    //     context,
    //     index: index,
    //     zoomPercentage: zoomService.zoomPercentage[ZoomEnum.medium]!,
    //   );
    // }
  }

  double getZoomOffsetAccordingToZoomPercentage(
      BuildContext context, double verticalOffset) {
    double neutralOffsetFactor = 60;
    double returnVerticalOffset = verticalOffset;
    int currentZoomPercentage = zoomPercentage[getCurrentZoomEnum(context)]!;
    returnVerticalOffset = returnVerticalOffset -
        neutralOffsetFactor -
        currentZoomPercentage.toDouble();
    return returnVerticalOffset;
  }

  ZoomEnum getCurrentZoomEnum(
    BuildContext context,
  ) {
    int initialZoomPercentage = zoomPercentage[defaultZoom]!;
    final zoomState = context.read<ZoomCubit>().state;
    if (zoomState is AyahZoomState) {
      initialZoomPercentage = zoomState.zoomPercentage;
    }
    return getZoomEnumFromPercentage(initialZoomPercentage);
  }

  bool isOnTapEnable(
    BuildContext context,
  ) {
    bool toReturn = true;
    ZoomEnum zoomEnum = getCurrentZoomEnum(context);
    if (zoomEnum == ZoomEnum.small || zoomEnum == ZoomEnum.medium) {
      toReturn = false;
    }
    return toReturn;
  }

  bool isBorderEnable(
    int zoomPercentage,
  ) {
    bool toReturn = true;
    if (zoomPercentage > 35) {
      toReturn = false;
    }
    return toReturn;
  }

  Map<ZoomEnum, int> zoomPercentage = {
    ZoomEnum.small: 0,
    ZoomEnum.medium: 28,
    ZoomEnum.large: 30,
    ZoomEnum.extralarge: 36,
  };

  ZoomEnum getZoomEnumFromPercentage(
    int percentage,
  ) {
    ZoomEnum toReturnEnum = ZoomEnum.medium;
    if (percentage == 0) {
      toReturnEnum = ZoomEnum.small;
    } else if (percentage == 28) {
      toReturnEnum = ZoomEnum.medium;
    }
    if (percentage == 30) {
      toReturnEnum = ZoomEnum.large;
    }
    if (percentage == 36) {
      toReturnEnum = ZoomEnum.extralarge;
    }
    return toReturnEnum;
  }
}
