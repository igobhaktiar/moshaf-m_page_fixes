import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/widgets/book_generic_icon.dart';

import '../../../../core/utils/app_colors.dart';

class MoshafLoader extends StatelessWidget {
  const MoshafLoader({super.key});

  Color getCurrentTranslationIconColor(
    BuildContext context,
  ) {
    return (context.isDarkMode) ? Colors.white : AppColors.bottomSheetBorderDark;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: Column(
          children: [
            BookGenericIcon(
              widthHeight: 25,
              color: getCurrentTranslationIconColor(context),
            ),
            const SizedBox(
              height: 10,
            ),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
