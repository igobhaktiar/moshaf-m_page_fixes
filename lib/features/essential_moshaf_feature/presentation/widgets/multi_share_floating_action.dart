import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/cubit/share_cubit/share_cubit_helper_service.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:share/share.dart';

import '../../../bookmarks/presentation/cubit/share_cubit/share_cubit.dart';

class MultiShareFloatingAction extends StatefulWidget {
  const MultiShareFloatingAction({
    super.key,
    required this.shareState,
  });
  final ShareState shareState;

  @override
  State<MultiShareFloatingAction> createState() =>
      _MultiShareFloatingActionState();
}

class _MultiShareFloatingActionState extends State<MultiShareFloatingAction> {
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
    if (widget.shareState is ShareLoaded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ...[
            FloatingActionButton(
              backgroundColor: getFloatingActionColor(),
              onPressed: () {
                ShareCubitHelperService()
                    .cancelSelectionForMultiSharing(context);
              },
              tooltip: context.translate.cancel,
              mini: true,
              child: const Icon(
                Icons.cancel,
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              backgroundColor: getFloatingActionColor(),
              onPressed: () {
                // Handle share action
                Share.share(
                  ShareCubitHelperService().getMultiSharedAyahs(context),
                );
              },
              tooltip: context.translate.share_ayah,
              mini: true,
              child: const Icon(Icons.share),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            backgroundColor: getFloatingActionColor(),
            onPressed: _toggleFAB,
            tooltip: context.translate.share_ayah,
            child: Icon(_isExpanded ? Icons.close : Icons.share),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
