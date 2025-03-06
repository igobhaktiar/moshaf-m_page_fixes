part of 'ayah_render_bloc.dart';

sealed class AyahRenderState extends Equatable {
  const AyahRenderState();

  @override
  List<Object> get props => [];
}

final class AyahRenderInitial extends AyahRenderState {}

final class AyahRendered extends AyahRenderState {
  int? pageIndex;
  Color? quranTextColor;
  int? darkThemeTextShade;
  String? currentPage;
  String? svgData;
  String? svgDataNextPage;
  XmlDocument? document;
  List<XmlElement>? elements;
  double? svgWidth;
  double? svgHeight;
  List<SvgElement>? svgElementsList;
  BuildContext? layoutContext;
  String? originalViewBox;
  AyahRendered({
    this.pageIndex,
    this.quranTextColor,
    this.darkThemeTextShade,
    this.currentPage,
    this.svgData,
    this.svgDataNextPage,
    this.document,
    this.elements,
    this.svgWidth,
    this.svgHeight,
    this.svgElementsList,
    this.layoutContext,
    this.originalViewBox,
  });
}

final class AyahRendering extends AyahRenderState {}
