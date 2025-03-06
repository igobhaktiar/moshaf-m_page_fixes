import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/assets_manager.dart';

class BookGenericIcon extends StatelessWidget {
  const BookGenericIcon({
    super.key,
    required this.widthHeight,
    required this.color,
  });

  final double widthHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.tafseerBookListIcon,
      color: color,
      height: widthHeight,
      width: widthHeight,
    );
  }
}
