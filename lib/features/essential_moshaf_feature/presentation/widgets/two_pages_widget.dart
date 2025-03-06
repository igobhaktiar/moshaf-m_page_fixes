import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/moshaf_loader.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_two_page_render_bloc/ayah_two_page_render_bloc.dart';

class TwoPagesWidget extends StatelessWidget {
  const TwoPagesWidget({
    super.key,
    required this.firstPageIndex,
    required this.secondPageIndex,
  });
  final int firstPageIndex, secondPageIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AyahTwoPageRenderBloc, AyahTwoPageRenderState>(
      builder: (context, ayahTwoPageRenderState) {
        if (ayahTwoPageRenderState is AyahTwoPageRendering) {
          return const MoshafLoader();
        }
        if (ayahTwoPageRenderState is TwoPageAyahRendered &&
            ayahTwoPageRenderState.firstPageSvgData != null &&
            ayahTwoPageRenderState.secondPageSvgData != null) {
          ZoomEnum currentZoom = ZoomService().getCurrentZoomEnum(context);

          return Padding(
            padding: (currentZoom == ZoomEnum.extralarge)
                ? const EdgeInsets.only(
                    top: 20.0,
                    left: 27.5,
                    right: 27.5,
                    bottom: 50,
                  )
                : const EdgeInsets.only(
                    top: 30.0,
                    left: 7.5,
                    right: 7.5,
                    bottom: 50,
                  ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SvgWidgetForLandscape(
                    svgData: ayahTwoPageRenderState.firstPageSvgData!,
                    isFirstPage: true,
                  ),
                ),
                if (MediaQuery.of(context).orientation != Orientation.landscape)
                  const SizedBox(
                    width: 10,
                  ),
                secondPageIndex < 604
                    ? Expanded(
                        child: SvgWidgetForLandscape(
                          svgData: ayahTwoPageRenderState.secondPageSvgData!,
                          isFirstPage: false,
                        ),
                      )
                    : Expanded(child: Container()),
              ],
            ),
          );
        }
        return const MoshafLoader();
      },
    );
  }
}

class SvgWidgetForLandscape extends StatelessWidget {
  const SvgWidgetForLandscape({
    super.key,
    required this.svgData,
    required this.isFirstPage,
  });
  final String svgData;

  final bool isFirstPage;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext layoutContext, BoxConstraints constraints) {
        if (isFirstPage) {
          AyahRenderBlocHelper.firstPageLayoutContext = layoutContext;
        } else {
          AyahRenderBlocHelper.secondPageLayoutContext = layoutContext;
        }

        return SvgPicture.string(
          svgData,
          width: constraints.maxWidth,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
