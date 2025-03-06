import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets_manager.dart';
import '../cubit/bottom_widget_cubit/bottom_widget_cubit.dart';

class SlideableDisplay extends StatefulWidget {
  const SlideableDisplay({
    super.key,
    required this.topWidget,
    required this.bottomWidget,
    required this.isOpenOnlyTop,
  });

  final Widget topWidget;
  final Widget bottomWidget;
  final bool isOpenOnlyTop;

  @override
  State<SlideableDisplay> createState() => _SlideableDisplayState();
}

class _SlideableDisplayState extends State<SlideableDisplay> {
  double division = 0.5;
  final double _snapCloseThreshold = 500; // Set Velocity of Threshold to close
  bool isClosing = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.isLandscape) {
          return Row(
            children: [
              // First widget
              SizedBox(
                width: widget.isOpenOnlyTop
                    ? constraints.maxWidth
                    : constraints.maxWidth * division,
                child: widget.topWidget,
              ),

              if (!widget.isOpenOnlyTop) ...[
                // Divider that can be dragged
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    setState(() {
                      // Update the division based on drag amount
                      division += details.delta.dx / constraints.maxWidth;
                      division =
                          division.clamp(0.1, 0.9); // Limit between 10% and 90%
                    });
                  },
                  onPanEnd: (details) {
                    // Check the velocity of the drag
                    if (details.velocity.pixelsPerSecond.dx >
                        _snapCloseThreshold) {
                      // If velocity is greater than the threshold, close the bottom widget
                      setState(() {
                        isClosing = true;
                        division = 1.0; // Snap to close
                      });
                      context.read<BottomWidgetCubit>().setBottomWidgetState(
                          false, afterExecutionFunction: () {
                        setState(() {
                          division = 0.5;
                          isClosing = false;
                        });
                      });
                      // Optionally: You could add an animation to make it smooth
                    } else if (details.velocity.pixelsPerSecond.dx <
                        -_snapCloseThreshold) {
                      // If dragged upwards fast, fully open the bottom widget
                      setState(() {
                        isClosing = false;
                        division = 0.1; // Snap open to minimum size
                      });
                    }
                  },
                  child: Container(
                    width: 20,
                    decoration: BoxDecoration(
                      image: context.isDarkMode
                          ? null
                          : const DecorationImage(
                              image: AssetImage(AppAssets.pattern),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Icon(
                            Icons.drag_handle,
                            color: context.isDarkMode
                                ? Colors.white
                                : AppColors.cardBgDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Second widget
                SizedBox(
                  width: (constraints.maxWidth * (1 - division)) - 20,
                  child: widget.bottomWidget,
                ),
              ]
            ],
          );
        } else {
          return Column(
            children: [
              // First widget
              SizedBox(
                height: widget.isOpenOnlyTop
                    ? constraints.maxHeight
                    : constraints.maxHeight * division,
                child: widget.topWidget,
              ),

              if (!widget.isOpenOnlyTop) ...[
                // Divider that can be dragged
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    setState(() {
                      // Update the division based on drag amount
                      division += details.delta.dy / constraints.maxHeight;
                      division =
                          division.clamp(0.1, 0.9); // Limit between 10% and 90%
                    });
                  },
                  onPanEnd: (details) {
                    // Check the velocity of the drag
                    if (details.velocity.pixelsPerSecond.dy >
                        _snapCloseThreshold) {
                      // If velocity is greater than the threshold, close the bottom widget
                      setState(() {
                        isClosing = true;
                        division = 1.0; // Snap to close
                      });
                      context.read<BottomWidgetCubit>().setBottomWidgetState(
                          false, afterExecutionFunction: () {
                        setState(() {
                          division = 0.5;
                          isClosing = false;
                        });
                      });
                      // Optionally: You could add an animation to make it smooth
                    } else if (details.velocity.pixelsPerSecond.dy <
                        -_snapCloseThreshold) {
                      // If dragged upwards fast, fully open the bottom widget
                      setState(() {
                        isClosing = false;
                        division = 0.1; // Snap open to minimum size
                      });
                    }
                  },
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      image: context.isDarkMode
                          ? null
                          : const DecorationImage(
                              image: AssetImage(AppAssets.pattern),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.drag_handle,
                        color: context.isDarkMode
                            ? Colors.white
                            : AppColors.cardBgDark,
                      ),
                    ),
                  ),
                ),
                // Second widget
                SizedBox(
                  height: (constraints.maxHeight * (1 - division)) - 20,
                  child: widget.bottomWidget,
                ),
              ]
            ],
          );
        }
      },
    );
  }
}
