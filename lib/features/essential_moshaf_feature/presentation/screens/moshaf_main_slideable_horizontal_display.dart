import 'package:flutter/material.dart';

import '../widgets/moshaf_main_scaffold_wrapper.dart';

class MoshafMainSlideableHorizontalDisplay extends StatefulWidget {
  const MoshafMainSlideableHorizontalDisplay({
    super.key,
    required this.topWidget,
    required this.bottomWidget,
    required this.isOpenOnlyTop,
  });

  final Widget topWidget;
  final Widget bottomWidget;
  final bool isOpenOnlyTop;

  @override
  State<MoshafMainSlideableHorizontalDisplay> createState() =>
      _MoshafMainSlideableHorizontalDisplayState();
}

class _MoshafMainSlideableHorizontalDisplayState
    extends State<MoshafMainSlideableHorizontalDisplay> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MoshafMainScaffoldWrapper(
        body: widget.topWidget,
      ),
    );
  }
}
