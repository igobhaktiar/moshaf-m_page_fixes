import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/top_navigation_bar/top_navigation_widgets.dart';

class TopFlyingAppBar extends StatelessWidget {
  final bool withNavitateSourah, isLeftAligned;
  const TopFlyingAppBar({
    super.key,
    required this.withNavitateSourah,
    this.isLeftAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (BuildContext context, EssentialMoshafState state) {
        final isToShowFlyingLayers =
            EssentialMoshafCubit.get(context).isToShowAppBar;
        final currantSurah = EssentialMoshafCubit.get(context).currentSurahInt;

        return isToShowFlyingLayers
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: context.width,
                    height: 70,
                    decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? AppColors.appBarBgDark
                            : AppColors.primary,
                        image: context.isDarkMode
                            ? null
                            : const DecorationImage(
                                image: AssetImage(AppAssets.pattern),
                                fit: BoxFit.cover)),
                    padding: EdgeInsets.only(top: context.topPadding),
                    alignment: Alignment.center,
                    child: TopNavigationWidgets(
                      currentSurah: currantSurah,
                    ),
                  ),
                ],
              )
            : Container();
      },
    );
  }
}
