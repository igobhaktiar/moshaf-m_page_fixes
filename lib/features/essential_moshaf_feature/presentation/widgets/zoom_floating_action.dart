import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';

class ZoomFloatingAction extends StatelessWidget {
  const ZoomFloatingAction({
    super.key,
    required this.context,
  });

  final BuildContext context;

  void _zoomIn() {
    ZoomService().setZoom(
      context,
    );
  }

  Color? getFloatingActionColor() {
    if (context.theme.brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return null;
    }
  }

  // Color? getFloatingActionColor() {
  //   if (context.theme.brightness == Brightness.dark) {
  //     return Colors.white;
  //   } else {
  //     return context.theme.primaryColor;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: getFloatingActionColor(),
      onPressed: _zoomIn,
      // tooltip: context.translate.share_ayah,
      child: const Icon(Icons.zoom_in),
    );

    //  Theme(
    //   data: ThemeData(
    //     splashColor: Colors.transparent,
    //     highlightColor: Colors.transparent,
    //   ),
    //   child: Padding(
    //     padding: const EdgeInsets.only(bottom: 15.0),
    //     child: FloatingActionButton(
    //       onPressed: _zoomIn,
    //       backgroundColor: Colors.transparent,
    //       disabledElevation: 0,
    //       elevation: 0,
    //       highlightElevation: 0,
    //       child: Icon(
    //         Icons.zoom_in,
    //         size: 35,
    //         color: getFloatingActionIconColor(),
    //       ),
    //     ),
    //   ),
    // );
  }
}
