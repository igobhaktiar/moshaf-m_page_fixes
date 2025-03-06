part of 'ayah_two_page_render_bloc.dart';

sealed class AyahTwoPageRenderEvent extends Equatable {
  const AyahTwoPageRenderEvent();

  @override
  List<Object> get props => [];
}

class FetchInitialTwoPages extends AyahTwoPageRenderEvent {}

class IntializeTwoPageRenderWidget extends AyahTwoPageRenderEvent {
  final int firstPagePageIndex;
  final int secondPagePageIndex;

  final Color quranTextColor;
  final int darkThemeTextShade;
  final int zoomPercentage;

  const IntializeTwoPageRenderWidget({
    required this.firstPagePageIndex,
    required this.secondPagePageIndex,
    required this.quranTextColor,
    required this.darkThemeTextShade,
    required this.zoomPercentage,
  });
}

class IntializeTwoPageRenderWidgetWithTwoNextPage
    extends AyahTwoPageRenderEvent {
  final int firstPagePageIndex;
  final int secondPagePageIndex;

  final Color quranTextColor;
  final int darkThemeTextShade;
  final int zoomPercentage;

  const IntializeTwoPageRenderWidgetWithTwoNextPage({
    required this.firstPagePageIndex,
    required this.secondPagePageIndex,
    required this.quranTextColor,
    required this.darkThemeTextShade,
    required this.zoomPercentage,
  });
}

class UpdateAyahTwoPageRenderedState extends AyahTwoPageRenderEvent {
  final TwoPageAyahRendered previousState;
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
  String? firstPageOriginalViewBox;
  String? secondPageOriginalViewBox;

  UpdateAyahTwoPageRenderedState({
    required this.previousState,
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
    this.firstPageOriginalViewBox,
    this.secondPageOriginalViewBox,
  });
}
