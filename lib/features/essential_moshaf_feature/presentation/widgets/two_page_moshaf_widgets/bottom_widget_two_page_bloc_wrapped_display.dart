import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/two_pages_widget.dart';

class BottomWidgetTwoPageBlocWrappedDisplay extends StatelessWidget {
  const BottomWidgetTwoPageBlocWrappedDisplay({
    super.key,
    required this.actualHeight,
    required this.actualWidth,
    required this.isOpened,
    required this.firstPageIndex,
    required this.secondPageIndex,
  });

  final double actualWidth, actualHeight;
  final bool isOpened;
  final int firstPageIndex, secondPageIndex;
  @override
  Widget build(BuildContext context) {
    return TwoPagesWidget(
      firstPageIndex: firstPageIndex,
      secondPageIndex: secondPageIndex,
    );
  }
}
