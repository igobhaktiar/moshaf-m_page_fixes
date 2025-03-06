import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';

class DraggableMenuFAB extends StatefulWidget {
  const DraggableMenuFAB({
    super.key,
    required this.context,
    required this.initialOffset,
    required this.child,
  });
  final BuildContext context;
  final Offset initialOffset;
  final Widget child;

  @override
  _DraggableMenuFABState createState() => _DraggableMenuFABState();
}

class _DraggableMenuFABState extends State<DraggableMenuFAB> {
  bool isFABVisible = true; // Tracks FAB visibility
  Offset fabPosition = const Offset(20, 50); // Initial position of the FAB

  @override
  void initState() {
    super.initState();
    fabPosition = widget.initialOffset;
  }

  void toggleFABVisibility() {
    setState(() {
      isFABVisible = !isFABVisible; // Toggle FAB visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: fabPosition.dx,
      top: fabPosition.dy,
      child: Draggable(
        feedback: widget.child,
        // const SmallFloatingMenu(),
        child: widget.child,
        // isFABVisible
        //     ?
        // const SmallFloatingMenu(),
        // : Container(), // Hide FAB when isFABVisible is false
        onDragEnd: (details) {
          setState(() {
            fabPosition = details.offset; // Update FAB position when dragged
          });
        },
      ),
    );
  }
}

class SmallFloatingMenu extends StatefulWidget {
  const SmallFloatingMenu({Key? key}) : super(key: key);

  @override
  State<SmallFloatingMenu> createState() => _SmallFloatingMenuState();
}

class _SmallFloatingMenuState extends State<SmallFloatingMenu> {
  bool _isExpanded = false;

  void _toggleFAB() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Color? getFloatingActionColor() {
    if (context.theme.brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      FloatingActionButton(
        backgroundColor: getFloatingActionColor(),
        onPressed: _toggleFAB,
        tooltip: 'context.translate.share_ayah',
        child: Icon(_isExpanded ? Icons.close : Icons.menu_open),
      ),
      const SizedBox(height: 10),
      if (_isExpanded) ...[
        FloatingActionButton(
          backgroundColor: getFloatingActionColor(),
          onPressed: () {
            // Handle share action
          },
          tooltip: 'context.translate.share_ayah',
          mini: true,
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          backgroundColor: getFloatingActionColor(),
          onPressed: () {},
          tooltip: ' context.translate.cancel',
          mini: true,
          child: const Icon(
            Icons.zoom_out,
          ),
        ),
      ],
    ]);
  }
}
