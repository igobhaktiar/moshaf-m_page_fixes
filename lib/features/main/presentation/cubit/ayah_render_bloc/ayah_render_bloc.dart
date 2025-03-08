import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/play_asset_delivery.dart';
import '../../../../../injection_container.dart';
import '../../../../../navigation_service.dart';
import '../../../../essential_moshaf_feature/data/models/svg_element.dart';
import '../quran_details_cubit/quran_details_service.dart';

part 'ayah_render_event.dart';
part 'ayah_render_state.dart';

class AyahRenderBloc extends Bloc<AyahRenderEvent, AyahRenderState> {
  AyahRenderBloc() : super(AyahRenderInitial()) {
    on<FetchInitialPage>(
      (event, emit) {
        emit(
          AyahRendering(),
        );
        try {
          final SharedPreferences sharedPreferences = getItInstance();
          int pageIndex = sharedPreferences.getInt(AppStrings.savedCurrentMoshafPageNumber) ?? AyahRenderBlocHelper.intialPageIndex;
          emit(
            AyahRendered(
              pageIndex: pageIndex,
            ),
          );
          final BuildContext? currentContext = getItInstance<NavigationService>().getContext();
          if (currentContext != null) {
            AyahRenderBlocHelper.pageChangeInitialize(
              currentContext,
              pageIndex,
            );
          }
        } catch (e) {
          emit(
            AyahRenderInitial(),
          );
        }
      },
    );

    on<IntializeRenderWidgetWithNextPage>(
      (event, emit) async {
        try {
          //Get Application Context To Fetch State
          final BuildContext? currentContext = AppContext.getAppContext();
          if (currentContext != null) {
            final AyahRenderState currentState = BlocProvider.of<AyahRenderBloc>(currentContext).state;
            //Fetch Ayah Render Bloc State
            if (currentState is AyahRendered && currentState.pageIndex != null) {
              final SharedPreferences sharedPreferences = getItInstance();
              sharedPreferences.setInt(AppStrings.savedCurrentMoshafPageNumber, event.currentPageIndex);

              String currentPage = AppStrings.getAssetSvgNormalPagePath(
                event.currentPageIndex + 1,
              );

              if (currentState.svgData != null && currentState.svgDataNextPage != null) {
                //This means that svg data is not null hence we already have svgData
                // Change Next SvgData to Svg Data and Fetch Next Svg Data
                //Update Current Svg Data
                XmlDocument nextDocument = XmlDocument.parse(currentState.svgDataNextPage!);
                List<XmlElement> nextElements = AyahRenderBlocHelper.getXmlElements(
                  nextDocument,
                );
                double nextWidth = 0, nextHeight = 0;
                (nextWidth, nextHeight) = AyahRenderBlocHelper.getWidthAndHeight(
                  nextDocument,
                  nextElements,
                );
                if (nextWidth == 0 && nextHeight == 0) {
                  throw Exception("Condition Failed: width !=0 && height !=0");
                }
                List<SvgElement> nextSvgElementsList = AyahRenderBlocHelper.getSvgElementList(
                  nextElements,
                );

                String? nextOriginalFetchBox = AyahRenderBlocHelper.fetchViewBoxOriginal(currentContext, currentState.svgDataNextPage!);
                emit(
                  AyahRendering(),
                );
                emit(
                  AyahRendered(
                    pageIndex: event.currentPageIndex,
                    quranTextColor: event.quranTextColor,
                    darkThemeTextShade: event.darkThemeTextShade,
                    currentPage: currentPage,
                    svgData: currentState.svgDataNextPage,
                    document: nextDocument,
                    elements: nextElements,
                    svgWidth: nextWidth,
                    svgHeight: nextHeight,
                    svgElementsList: nextSvgElementsList,
                    originalViewBox: nextOriginalFetchBox,
                  ),
                );
                //Fetch Next Svg Data
                String? nextSvgData = await AyahRenderBlocHelper.getNextSvgData(
                  currentContext,
                  event.currentPageIndex,
                  event.zoomPercentage,
                  event.quranTextColor,
                  event.darkThemeTextShade,
                );
                if (nextSvgData != null) {
                  final AyahRenderState currentNewState = BlocProvider.of<AyahRenderBloc>(currentContext).state;
                  if (currentNewState is AyahRendered) {
                    emit(
                      AyahRendering(),
                    );
                    emit(
                      AyahRendered(
                        pageIndex: currentNewState.pageIndex,
                        quranTextColor: currentNewState.quranTextColor,
                        darkThemeTextShade: currentNewState.darkThemeTextShade,
                        currentPage: currentNewState.currentPage,
                        svgData: currentNewState.svgData,
                        document: currentNewState.document,
                        elements: currentNewState.elements,
                        svgWidth: currentNewState.svgWidth,
                        svgHeight: currentNewState.svgHeight,
                        svgElementsList: currentNewState.svgElementsList,
                        originalViewBox: currentNewState.originalViewBox,
                        svgDataNextPage: nextSvgData,
                      ),
                    );
                  }
                }
              } else {
                //This means that svg data is null hence first time we are rendering

                // String? svgData = await rootBundle.loadString(
                //   AyahRenderBlocHelper.getSvgString(event.currentPageIndex),
                // );
                String? svgData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                  AyahRenderBlocHelper.getSvgStringFromIndex(
                    event.currentPageIndex,
                  ),
                );
                if (!ZoomService().isBorderEnable(event.zoomPercentage) && event.currentPageIndex + 1 < 3) {
                  svgData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                    AyahRenderBlocHelper.getSvgStringFromIndex(
                      event.currentPageIndex,
                      addInString: '-level3',
                    ),
                  );
                  // svgData = await rootBundle.loadString(
                  //   AyahRenderBlocHelper.getSvgString(
                  //     event.currentPageIndex,
                  //     addInString: '-level3',
                  //   ),
                  // );
                }

                svgData = await AyahRenderBlocHelper.preprocessingOnSvgData(
                  currentContext,
                  svgData: svgData,
                  svgNumber: event.currentPageIndex + 1,
                  zoomPercentage: event.zoomPercentage,
                );

                bool isCustomColor = false;
                if (event.quranTextColor != QuranDetailsService.defaultQuranTextColor) {
                  isCustomColor = true;
                }
                XmlDocument document = XmlDocument.parse(svgData);
                List<XmlElement> elements = AyahRenderBlocHelper.getXmlElements(
                  document,
                );
                double width = 0, height = 0;
                (width, height) = AyahRenderBlocHelper.getWidthAndHeight(
                  document,
                  elements,
                );
                if (width == 0 && height == 0) {
                  throw Exception("Condition Failed: width !=0 && height !=0");
                }
                if (currentContext.theme.brightness == Brightness.dark) {
                  svgData = AyahRenderBlocHelper.hideShowAyaMarkNight(
                    true,
                    elements: elements,
                    document: document,
                  );
                  svgData = AyahRenderBlocHelper.hideShowAyaMarkLight(
                    false,
                    elements: elements,
                    document: document,
                  );
                  svgData = AyahRenderBlocHelper.colorAllAya(
                    currentContext,
                    (0 + (100 - event.darkThemeTextShade)).toDouble(),
                    elements: elements,
                    document: document,
                    isCustom: isCustomColor,
                  );
                } else {
                  svgData = AyahRenderBlocHelper.hideShowAyaMarkNight(
                    false,
                    elements: elements,
                    document: document,
                  );
                  svgData = AyahRenderBlocHelper.hideShowAyaMarkLight(
                    true,
                    elements: elements,
                    document: document,
                  );
                  svgData = AyahRenderBlocHelper.colorAllAya(
                    currentContext,
                    100,
                    elements: elements,
                    document: document,
                    isCustom: isCustomColor,
                  );
                }
                List<SvgElement> svgElementsList = AyahRenderBlocHelper.getSvgElementList(
                  elements,
                );

                String? originalFetchBox = AyahRenderBlocHelper.fetchViewBoxOriginal(currentContext, svgData);
                emit(
                  AyahRendering(),
                );
                await AyahRenderBlocHelper.getDelay();
                emit(
                  AyahRendered(
                    pageIndex: event.currentPageIndex,
                    quranTextColor: event.quranTextColor,
                    darkThemeTextShade: event.darkThemeTextShade,
                    currentPage: currentPage,
                    svgData: svgData,
                    document: document,
                    elements: elements,
                    svgWidth: width,
                    svgHeight: height,
                    svgElementsList: svgElementsList,
                    originalViewBox: originalFetchBox,
                  ),
                );
                String? nextSvgData = await AyahRenderBlocHelper.getNextSvgData(
                  currentContext,
                  event.currentPageIndex,
                  event.zoomPercentage,
                  event.quranTextColor,
                  event.darkThemeTextShade,
                );
                if (nextSvgData != null) {
                  final AyahRenderState currentNewState = BlocProvider.of<AyahRenderBloc>(currentContext).state;
                  if (currentNewState is AyahRendered) {
                    emit(
                      AyahRendering(),
                    );
                    emit(
                      AyahRendered(
                        pageIndex: currentNewState.pageIndex,
                        quranTextColor: currentNewState.quranTextColor,
                        darkThemeTextShade: currentNewState.darkThemeTextShade,
                        currentPage: currentNewState.currentPage,
                        svgData: currentNewState.svgData,
                        document: currentNewState.document,
                        elements: currentNewState.elements,
                        svgWidth: currentNewState.svgWidth,
                        svgHeight: currentNewState.svgHeight,
                        svgElementsList: currentNewState.svgElementsList,
                        originalViewBox: currentNewState.originalViewBox,
                        svgDataNextPage: nextSvgData,
                      ),
                    );
                  }
                }
              }
            } else {
              throw Exception();
            }
          }
        } catch (e) {
          debugPrint(e.toString());
          emit(
            AyahRenderInitial(),
          );
        }
      },
    );
    on<IntializeRenderWidget>(
      (event, emit) async {
        try {
          final BuildContext? currentContext = getItInstance<NavigationService>().getContext();
          if (currentContext != null) {
            final AyahRenderState currentState = BlocProvider.of<AyahRenderBloc>(currentContext).state;
            AyahRenderState? savedCurrentState;

            if (currentState is AyahRendered && currentState.pageIndex != null) {
              final SharedPreferences sharedPreferences = getItInstance();
              sharedPreferences.setInt(AppStrings.savedCurrentMoshafPageNumber, event.currentPageIndex);
              savedCurrentState = currentState;

              String currentPage = AppStrings.getAssetSvgNormalPagePath(
                event.currentPageIndex + 1,
              );
              String? svgData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                AyahRenderBlocHelper.getSvgStringFromIndex(
                  event.currentPageIndex,
                ),
              );

              // String? svgData = await rootBundle.loadString(
              //   AyahRenderBlocHelper.getSvgString(event.currentPageIndex),
              // );

              if (!ZoomService().isBorderEnable(event.zoomPercentage) && event.currentPageIndex + 1 < 3) {
                svgData = await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                  AyahRenderBlocHelper.getSvgStringFromIndex(
                    event.currentPageIndex,
                    addInString: '-level3',
                  ),
                );

                // svgData = await rootBundle.loadString(
                //   AyahRenderBlocHelper.getSvgString(
                //     event.currentPageIndex,
                //     addInString: '-level3',
                //   ),
                // );
              }

              svgData = await AyahRenderBlocHelper.preprocessingOnSvgData(
                currentContext,
                svgData: svgData,
                svgNumber: event.currentPageIndex + 1,
                zoomPercentage: event.zoomPercentage,
              );

              bool isCustomColor = false;
              if (event.quranTextColor != QuranDetailsService.defaultQuranTextColor) {
                isCustomColor = true;
              }
              XmlDocument document = XmlDocument.parse(svgData);
              List<XmlElement> elements = AyahRenderBlocHelper.getXmlElements(
                document,
              );
              double width = 0, height = 0;
              (width, height) = AyahRenderBlocHelper.getWidthAndHeight(
                document,
                elements,
              );
              if (width == 0 && height == 0) {
                throw Exception("Condition Failed: width !=0 && height !=0");
              }
              if (currentContext.theme.brightness == Brightness.dark) {
                svgData = AyahRenderBlocHelper.hideShowAyaMarkNight(
                  true,
                  elements: elements,
                  document: document,
                );
                svgData = AyahRenderBlocHelper.hideShowAyaMarkLight(
                  false,
                  elements: elements,
                  document: document,
                );
                svgData = AyahRenderBlocHelper.colorAllAya(
                  currentContext,
                  (0 + (100 - event.darkThemeTextShade)).toDouble(),
                  elements: elements,
                  document: document,
                  isCustom: isCustomColor,
                );
              } else {
                svgData = AyahRenderBlocHelper.hideShowAyaMarkNight(
                  false,
                  elements: elements,
                  document: document,
                );
                svgData = AyahRenderBlocHelper.hideShowAyaMarkLight(
                  true,
                  elements: elements,
                  document: document,
                );
                svgData = AyahRenderBlocHelper.colorAllAya(
                  currentContext,
                  100,
                  elements: elements,
                  document: document,
                  isCustom: isCustomColor,
                );
              }
              List<SvgElement> svgElementsList = AyahRenderBlocHelper.getSvgElementList(
                elements,
              );

              String? originalFetchBox = AyahRenderBlocHelper.fetchViewBoxOriginal(currentContext, svgData);
              emit(
                AyahRendering(),
              );
              await AyahRenderBlocHelper.getDelay();
              emit(
                AyahRendered(
                  pageIndex: event.currentPageIndex,
                  quranTextColor: event.quranTextColor,
                  darkThemeTextShade: event.darkThemeTextShade,
                  currentPage: currentPage,
                  svgData: svgData,
                  document: document,
                  elements: elements,
                  svgWidth: width,
                  svgHeight: height,
                  svgElementsList: svgElementsList,
                  originalViewBox: originalFetchBox,
                ),
              );
            } else {
              throw Exception();
            }
          }
        } catch (e) {
          debugPrint(e.toString());
          emit(
            AyahRenderInitial(),
          );
        }
      },
    );

    on<UpdateAyahRenderedState>(
      (event, emit) async {
        try {
          emit(
            AyahRendering(),
          );
          emit(AyahRendered(
            pageIndex: event.pageIndex ?? event.previousState.pageIndex,
            quranTextColor: event.quranTextColor ?? event.previousState.quranTextColor,
            darkThemeTextShade: event.darkThemeTextShade ?? event.previousState.darkThemeTextShade,
            currentPage: event.currentPage ?? event.previousState.currentPage,
            svgData: event.svgData ?? event.previousState.svgData,
            document: event.document ?? event.previousState.document,
            elements: event.elements ?? event.previousState.elements,
            svgWidth: event.svgWidth ?? event.previousState.svgWidth,
            svgHeight: event.svgHeight ?? event.previousState.svgHeight,
            svgElementsList: event.svgElementsList ?? event.previousState.svgElementsList,
            layoutContext: event.layoutContext ?? event.previousState.layoutContext,
            originalViewBox: event.originalViewBox ?? event.previousState.originalViewBox,
          ));
        } catch (e) {
          debugPrint(e.toString());
          emit(
            AyahRenderInitial(),
          );
        }
      },
    );
  }
}
