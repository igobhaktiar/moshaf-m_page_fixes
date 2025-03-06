part of 'ayah_two_page_render_bloc.dart';

sealed class AyahTwoPageRenderState extends Equatable {
  const AyahTwoPageRenderState();

  @override
  List<Object> get props => [];
}

final class AyahTwoPageRenderInitial extends AyahTwoPageRenderState {}

final class TwoPageAyahRendered extends AyahTwoPageRenderState {
  int? firstPageIndex;
  int? secondPageIndex;
  Color? quranTextColor;
  int? darkThemeTextShade;
  String? firstCurrentPage;
  String? secondCurrentPage;
  String? firstPageSvgData;
  String? secondPageSvgData;
  String? svgDataNextPageFirst;
  String? svgDataNextPageSecond;
  XmlDocument? firstPageDocument;
  XmlDocument? secondPageDocument;
  List<XmlElement>? firstPageElements;
  List<XmlElement>? secondPageElements;
  double? firstPageSvgWidth;
  double? firstPageSvgHeight;
  double? secondPageSvgWidth;
  double? secondPageSvgHeight;
  List<SvgElement>? firstPageSvgElementsList;
  List<SvgElement>? secondPageSvgElementsList;
  BuildContext? layoutContext;
  String? firstOriginalViewBox;
  String? secondOriginalViewBox;
  TwoPageAyahRendered({
    this.firstPageIndex,
    this.secondPageIndex,
    this.quranTextColor,
    this.darkThemeTextShade,
    this.firstCurrentPage,
    this.secondCurrentPage,
    this.firstPageSvgData,
    this.secondPageSvgData,
    this.svgDataNextPageFirst,
    this.svgDataNextPageSecond,
    this.firstPageDocument,
    this.secondPageDocument,
    this.firstPageElements,
    this.secondPageElements,
    this.firstPageSvgWidth,
    this.firstPageSvgHeight,
    this.secondPageSvgWidth,
    this.secondPageSvgHeight,
    this.firstPageSvgElementsList,
    this.secondPageSvgElementsList,
    this.layoutContext,
    this.firstOriginalViewBox,
    this.secondOriginalViewBox,
  });
}

final class AyahTwoPageRendering extends AyahTwoPageRenderState {}
