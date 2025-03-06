import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/slide_pagee_transition.dart';
import '../../../../main/presentation/screens/quran_fihris_screen.dart';
import '../../cubit/essential_moshaf_cubit.dart';
import '../../cubit/zoom_cubit/zoom_cubit.dart';
import '../../cubit/zoom_cubit/zoom_enum.dart';

class TapableHeader extends StatelessWidget {
  const TapableHeader({super.key});

  Widget containerWidget(
    BuildContext context, {
    Color color = Colors.transparent,
    VoidCallback? onTap,
    double height = 30,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: height,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZoomCubit, ZoomState>(
      builder: (context, zoomCubitState) {
        ZoomEnum currentZoomEnum = ZoomService()
            .getZoomEnumFromPercentage(zoomCubitState.zoomPercentage);
        double topPadding = MediaQuery.of(context).size.height * 0.1;
        double height = 90;
        if (currentZoomEnum == ZoomEnum.medium) {
          topPadding = MediaQuery.of(context).size.height * 0.15;
          height = 90;
        } else if (currentZoomEnum == ZoomEnum.large) {
          topPadding = MediaQuery.of(context).size.height * 0.095;
          height = 90;
        } else if (currentZoomEnum == ZoomEnum.extralarge) {
          topPadding = MediaQuery.of(context).size.height * 0.08;
          height = 70;
        }
        final cubit = EssentialMoshafCubit.get(context);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Positioned(
              top: topPadding,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    containerWidget(
                      context,
                      height: height,
                      onTap: () {
                        print("Current page" + cubit.currentPage.toString());
                        if (cubit.currentPage > 1) {
                          pushSlide(
                            context,
                            pushWithOverlayValues: true,
                            screen: const FihrisScreen(
                              activePageIndex: 1,
                            ),
                          );
                        }
                        cubit.changeFihrisView(1);
                      },
                    ),
                    containerWidget(
                      context,
                      height: height,
                      onTap: () {
                        if (cubit.currentPage > 1) {
                          pushSlide(
                            context,
                            pushWithOverlayValues: true,
                            screen: const FihrisScreen(
                              activePageIndex: 0,
                            ),
                          );
                        }
                        cubit.changeFihrisView(0);
                      },
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
