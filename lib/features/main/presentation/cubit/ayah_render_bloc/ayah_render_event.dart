part of 'ayah_render_bloc.dart';

abstract class AyahRenderEvent extends Equatable {
  const AyahRenderEvent();

  @override
  List<Object> get props => [];
}

class FetchInitialPage extends AyahRenderEvent {}

class IntializeRenderWidget extends AyahRenderEvent {
  final int currentPageIndex;
  final Color quranTextColor;
  final int darkThemeTextShade;
  final int zoomPercentage;

  const IntializeRenderWidget({
    required this.currentPageIndex,
    required this.quranTextColor,
    required this.darkThemeTextShade,
    required this.zoomPercentage,
  });
}

class IntializeRenderWidgetWithNextPage extends AyahRenderEvent {
  final int currentPageIndex;
  final Color quranTextColor;
  final int darkThemeTextShade;
  final int zoomPercentage;

  const IntializeRenderWidgetWithNextPage({
    required this.currentPageIndex,
    required this.quranTextColor,
    required this.darkThemeTextShade,
    required this.zoomPercentage,
  });
}

class UpdateAyahRenderedState extends AyahRenderEvent {
  final AyahRendered previousState;
  int? pageIndex;
  Color? quranTextColor;
  int? darkThemeTextShade;
  String? currentPage;
  String? svgData;
  XmlDocument? document;
  List<XmlElement>? elements;
  double? svgWidth;
  double? svgHeight;
  List<SvgElement>? svgElementsList;
  BuildContext? layoutContext;
  String? originalViewBox;

  UpdateAyahRenderedState({
    required this.previousState,
    this.pageIndex,
    this.quranTextColor,
    this.darkThemeTextShade,
    this.currentPage,
    this.svgData,
    this.document,
    this.elements,
    this.svgWidth,
    this.svgHeight,
    this.svgElementsList,
    this.layoutContext,
    this.originalViewBox,
  });
}
