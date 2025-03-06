import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import '../utils/app_colors.dart';

enum ResponsiveEnum {
  mobilePortrait,
  mobileLandscape,
  tabletPortrait,
  tabletLandscape,
}

class ResponsiveFrameworkHelper {
  ResponsiveEnum defaultResponsiveEnum = ResponsiveEnum.mobilePortrait;

  double getHeightByCurrentEnum(BuildContext context, int zoomPercentage,
      {double? customHeightForMobilePortrait}) {
    ResponsiveEnum currentResponsiveEnum = getResponsiveEnumStatus();
    double toReturnHeight = MediaQuery.of(context).size.height * 0.85;
    if (currentResponsiveEnum == ResponsiveEnum.mobilePortrait) {
      if (customHeightForMobilePortrait != null) {
        toReturnHeight =
            (ZoomService().getZoomEnumFromPercentage(zoomPercentage) ==
                    ZoomEnum.medium)
                ? customHeightForMobilePortrait * 0.81
                : customHeightForMobilePortrait - 35;
      } else {
        toReturnHeight = MediaQuery.of(context).size.height * 0.85;
      }
    } else if (currentResponsiveEnum == ResponsiveEnum.mobileLandscape) {
      toReturnHeight = MediaQuery.of(context).size.height;
      // toReturnHeight = MediaQuery.of(context).size.height * 3;
    } else if (currentResponsiveEnum == ResponsiveEnum.tabletPortrait) {
      toReturnHeight = MediaQuery.of(context).size.height * 1.15;
    } else if (currentResponsiveEnum == ResponsiveEnum.tabletLandscape) {
      toReturnHeight = toReturnHeight = MediaQuery.of(context).size.height * 3;
    }
    return toReturnHeight;
  }

  ResponsiveEnum getResponsiveEnumStatus() {
    ResponsiveEnum currentResponsiveEnum = defaultResponsiveEnum;
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      if (ResponsiveBreakpoints.of(appContext).isMobile) {
        // Is Mobile View
        currentResponsiveEnum = ResponsiveEnum.mobilePortrait;
      } else {
        //Is Tablet/Desktop View
        if (MediaQuery.of(appContext).orientation == Orientation.portrait) {
          if (MediaQuery.of(appContext).size.height < 1000) {
            currentResponsiveEnum = ResponsiveEnum.mobilePortrait;
          } else {
            currentResponsiveEnum = ResponsiveEnum.tabletPortrait;
          }
        } else {
          // It means that this is either tablet or mobile landscape
          if (MediaQuery.of(appContext).size.height < 500) {
            currentResponsiveEnum = ResponsiveEnum.mobileLandscape;
          } else {
            currentResponsiveEnum = ResponsiveEnum.tabletLandscape;
          }
        }
      }
    }
    return currentResponsiveEnum;
  }

  bool isTwoPaged() {
    bool isTwoPaged = false;
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      if (ResponsiveBreakpoints.of(appContext).isMobile) {
        isTwoPaged = false;
      } else {
        if (MediaQuery.of(appContext).size.height < 500) {
          isTwoPaged = false;
        } else {
          if (MediaQuery.of(appContext).orientation == Orientation.portrait) {
            isTwoPaged = false;
          } else {
            isTwoPaged = true;
          }
        }
      }
    }
    return isTwoPaged;
  }

  Widget responsiveBreakpointsBuilder(Widget child) {
    return ResponsiveBreakpoints.builder(
      child: child,
      breakpoints: [
        const Breakpoint(start: 0, end: 450, name: MOBILE),
        const Breakpoint(start: 451, end: 800, name: TABLET),
        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
    );
  }

  MaxWidthBox responsiveFrameworkMaxWidthBox(
      BuildContext context, Widget child) {
    return MaxWidthBox(
      // A widget that limits the maximum width.
      // This is used to create a gutter area on either side of the content.
      maxWidth: 1200,
      backgroundColor: AppColors.backgroundColor,
      child: ResponsiveScaledBox(
          // ResponsiveScaledBox renders its child with a FittedBox set to the `width` value.
          // Set the fixed width value based on the active breakpoint.
          width: ResponsiveValue<double>(context, conditionalValues: [
            const Condition.equals(name: MOBILE, value: 450),
            const Condition.between(start: 800, end: 1100, value: 800),
            const Condition.between(start: 1000, end: 1200, value: 1000),
            // There are no conditions for width over 1200
            // because the `maxWidth` is set to 1200 via the MaxWidthBox.
          ]).value,
          child: child),
    );
  }
}
