import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/ayah_render_svg_bloc_wrapped_widget.dart';

import '../../../../core/utils/constants.dart';
import '../cubit/essential_moshaf_cubit.dart';
import 'quran_page_ontap_wrapper.dart';

class BottomWidgetBlocWrappedQuranPageWidget extends StatelessWidget {
  const BottomWidgetBlocWrappedQuranPageWidget({
    super.key,
    required this.actualHeight,
    required this.actualWidth,
    required this.isOpened,
  });

  final double actualWidth, actualHeight;
  final bool isOpened;
  @override
  Widget build(BuildContext context) {
    return _ScrollControlledChild(
        actualHeight: actualHeight,
        actualWidth: actualWidth,
        isBottomOpened: isOpened,
        child: const Center(
          child: AyahBlocWrappedWidget(),
        ));
  }
}

class _ScrollControlledChild extends StatelessWidget {
  const _ScrollControlledChild({
    required this.actualHeight,
    required this.actualWidth,
    required this.child,
    required this.isBottomOpened,
  });

  final double actualWidth, actualHeight;
  final bool isBottomOpened;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Container(
      width: actualWidth,
      height: orientation == Orientation.landscape ? (actualWidth / AppConstants.moshafPageAspectRatio) - 200 : actualHeight,
      padding: context.read<EssentialMoshafCubit>().isToShowTopBottomNavListViews ? const EdgeInsets.symmetric(vertical: 10, horizontal: 0) : EdgeInsets.zero,
      child: QuranPageOnTapWrapper(
        isBottomOpened: isBottomOpened,
        height: orientation == Orientation.landscape ? (actualWidth / AppConstants.moshafPageAspectRatio) - 200 : actualHeight,
        child: child,
      ),
    );
  }
}
