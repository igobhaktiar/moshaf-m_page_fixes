import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/moshaf_loader.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'package:xml/xml.dart';

import '../cubit/zoom_cubit/zoom_enum.dart';

class AyahBlocWrappedWidget extends StatelessWidget {
  const AyahBlocWrappedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AyahRenderBloc, AyahRenderState>(
      builder: (context, ayahRenderState) {
        if (ayahRenderState is AyahRendering) {
          return const MoshafLoader();
        }
        if (ayahRenderState is AyahRendered &&
            ayahRenderState.svgData != null) {
          ZoomEnum currentZoom = ZoomService().getCurrentZoomEnum(context);

          return Padding(
            padding: (currentZoom == ZoomEnum.extralarge)
                ? EdgeInsets.only(
                    top: ayahRenderState.pageIndex! < 2 ? 0 : 35.0,
                    left: ayahRenderState.pageIndex! < 2 ? 30.5 : 17.5,
                    right: ayahRenderState.pageIndex! < 2 ? 30.5 : 17.5,
                    bottom: 50,
                  )
                : const EdgeInsets.only(
                    top: 20.0,
                    left: 7.5,
                    right: 7.5,
                    bottom: 50,
                  ),
            child: AyahSvgRenderDisplay(
              svgData: ayahRenderState.svgData!,
              document: ayahRenderState.document!,
              elements: ayahRenderState.elements!,
            ),
          );
        }
        return const MoshafLoader();
        // return const CircularProgressIndicator();
        // return const Text("No data");
      },
    );
  }
}

class AyahSvgRenderDisplay extends StatelessWidget {
  const AyahSvgRenderDisplay({
    super.key,
    required this.svgData,
    required this.document,
    required this.elements,
  });
  final String svgData;
  final XmlDocument document;
  final List<XmlElement> elements;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext layoutContext, BoxConstraints constraints) {
        AyahRenderBlocHelper.layoutContext = layoutContext;

        return SvgPicture.string(
          svgData,
          width: constraints.maxWidth,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
