import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/screens/pause_button_widget.dart';

import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../drawer/data/data_sources/drawer_constants.dart';
import '../../../../listening/presentation/cubit/listening_cubit.dart';
import '../../../../listening/presentation/screens/control_buttons.dart';
import '../../../../main/presentation/screens/quran_search_screen.dart';
import '../../cubit/zoom_cubit/zoom_enum.dart';
import 'bookmark_button_display.dart';

class TopNavigationWidgets extends StatelessWidget {
  const TopNavigationWidgets({
    super.key,
    required this.currentSurah,
  });
  final int currentSurah;

  @override
  Widget build(BuildContext context) {
    List<Widget> topWidgets = [];
    topWidgets.addAll([
      Row(
        children: [
          const SizedBox(
            width: 20,
          ),
          InkWell(
            onTap: () {
              bool isDrawerOpen =
                  AppConstants.moshafScaffoldKey.currentState?.isDrawerOpen ??
                      false;
              if (isDrawerOpen) {
                DrawerConstants.closeDrawer();
              } else {
                DrawerConstants.openDrawer();
              }
            },
            child: SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                Icons.menu,
                color: context.theme.primaryIconTheme.color,
              ),
            ),
          ),
          const PauseButtonWidget()
        ],
      ),
      if (ZoomService().getCurrentZoomEnum(context) != ZoomEnum.medium)
        Row(
          children: [
            const BookmarkButtonDisplay(),
            const SizedBox(
              width: 17,
            ),
            InkWell(
              onTap: () => pushSlide(context, screen: const QuranSearch()),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: SvgPicture.asset(
                  AppAssets.search,
                  color: context.theme.primaryIconTheme.color,
                ),
              ),
            ),
            const SizedBox(
              width: 25,
            ),
          ],
        )
      else
        const SizedBox(
          width: 50,
        ),
    ]);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: topWidgets,
        ),
        SvgPicture.asset(
          AppAssets.getSurahName(currentSurah),
          height: 35,
          color: context.theme.primaryIconTheme.color,
        ),
      ],
    );
  }
}
