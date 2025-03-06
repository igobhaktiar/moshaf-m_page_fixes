import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/utils/language_service.dart';

class InvertHandledContainer extends StatelessWidget {
  const InvertHandledContainer({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: LanguageService.isLanguageRtl(context) ? 0 : 2,
      child: child,
    );
  }
}
