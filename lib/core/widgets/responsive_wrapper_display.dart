import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveWrapperDisplay extends StatelessWidget {
  const ResponsiveWrapperDisplay({
    super.key,
    this.childForMobile,
    this.childForTablet,
  });
  final Widget? childForTablet;
  final Widget? childForMobile;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return childForMobile!;
    }
    if (childForMobile != null && ResponsiveBreakpoints.of(context).isMobile) {
      return childForMobile!;
    }
    if (childForMobile != null && ResponsiveBreakpoints.of(context).isMobile) {
      return childForMobile!;
    }
    if (childForMobile != null &&
        (ResponsiveBreakpoints.of(context).isTablet ||
            ResponsiveBreakpoints.of(context).isDesktop) &&
        MediaQuery.of(context).size.height < 500) {
      return childForMobile!;
    }
    if (childForTablet != null &&
        (ResponsiveBreakpoints.of(context).isTablet ||
            ResponsiveBreakpoints.of(context).isDesktop)) {
      return childForTablet!;
    }
    return const SizedBox();
  }
}
