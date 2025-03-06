import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../main/presentation/screens/bottom_sheet_views/margins_view.dart';
import '../../../main/presentation/screens/bottom_sheet_views/osoul_view.dart';
import '../../../main/presentation/screens/bottom_sheet_views/qeraat_view.dart';
import '../../../main/presentation/screens/bottom_sheet_views/shwahid_view.dart';
import '../cubit/essential_moshaf_cubit.dart';

class QeeratBottomHorizontalWidget extends StatelessWidget {
  const QeeratBottomHorizontalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currantSurah = EssentialMoshafCubit.get(context).currentSurahInt;
    final currentPage = EssentialMoshafCubit.get(context).currentPage;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: context.width,
            height: 45,
            decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.appBarBgDark
                    : AppColors.primary,
                image: context.isDarkMode
                    ? null
                    : const DecorationImage(
                        image: AssetImage(AppAssets.pattern),
                        fit: BoxFit.cover)),
            padding: EdgeInsets.only(
              top: context.topPadding,
              left: 15,
              right: 15,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (currentPage + 1).toString(),
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                    fontSize: 26,
                    fontFamily: 'louts-shamy',
                  ),
                ),
                SvgPicture.asset(
                  AppAssets.getSurahName(currantSurah),
                  height: 26,
                  color: context.theme.primaryIconTheme.color,
                ),
              ],
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  QeraaatView(
                    withScaffold: false,
                  ),
                  OsoulView(
                    withScaffold: false,
                  ),
                  ShwahidView(
                    withScaffold: false,
                  ),
                  MarginsView(
                    withScaffold: false,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
