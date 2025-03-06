import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/play_asset_delivery.dart';
import '../../../../../injection_container.dart';
import '../../../../essential_moshaf_feature/data/models/svg_element.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';
import '../ayah_render_bloc/ayah_render_bloc_helper.dart';
import '../quran_details_cubit/quran_details_service.dart';

part 'ayah_two_page_render_event.dart';
part 'ayah_two_page_render_state.dart';

class AyahTwoPageRenderBloc
    extends Bloc<AyahTwoPageRenderEvent, AyahTwoPageRenderState> {
  AyahTwoPageRenderBloc() : super(AyahTwoPageRenderInitial()) {
    on<FetchInitialTwoPages>(
      (event, emit) {
        emit(
          AyahTwoPageRendering(),
        );
        try {
          int firstPageIndex = AyahRenderBlocHelper.intialPageIndex;
          int secondPageIndex = firstPageIndex + 1;
          final SharedPreferences sharedPreferences = getItInstance();
          int pageIndex = sharedPreferences
                  .getInt(AppStrings.savedCurrentMoshafPageNumber) ??
              AyahRenderBlocHelper.intialPageIndex;
          if (pageIndex % 2 == 0) {
            firstPageIndex = pageIndex;
            secondPageIndex = firstPageIndex + 1;
          } else {
            secondPageIndex = pageIndex;
            firstPageIndex = secondPageIndex - 1;
          }

          emit(
            TwoPageAyahRendered(
              firstPageIndex: firstPageIndex,
              secondPageIndex: secondPageIndex,
            ),
          );
          final BuildContext? currentContext = AppContext.getAppContext();
          if (currentContext != null) {
            AyahRenderBlocHelper.pageChangeInitialize(
              currentContext,
              pageIndex,
            );
          }
        } catch (e) {
          emit(
            AyahTwoPageRenderInitial(),
          );
        }
      },
    );

    on<IntializeTwoPageRenderWidget>(
      (event, emit) async {
        try {
          final BuildContext? currentContext = AppContext.getAppContext();
          if (currentContext != null) {
            final AyahTwoPageRenderState currentState =
                BlocProvider.of<AyahTwoPageRenderBloc>(currentContext).state;
            AyahTwoPageRenderState? savedCurrentState;

            if (currentState is TwoPageAyahRendered &&
                currentState.firstPageIndex != null &&
                currentState.secondPageIndex != null) {
              final SharedPreferences sharedPreferences = getItInstance();
              sharedPreferences.setInt(AppStrings.savedCurrentMoshafPageNumber,
                  event.firstPagePageIndex);
              savedCurrentState = currentState;
              emit(
                AyahTwoPageRendering(),
              );

              String currentPageOne = AppStrings.getAssetSvgNormalPagePath(
                event.firstPagePageIndex + 1,
              );
              String currentPageTwo = AppStrings.getAssetSvgNormalPagePath(
                event.secondPagePageIndex + 1,
              );
              // String? svgDataOne = await rootBundle.loadString(
              //   AyahRenderBlocHelper.getSvgString(event.firstPagePageIndex),
              // );
              // String? svgDataTwo = await rootBundle.loadString(
              //   AyahRenderBlocHelper.getSvgString(event.secondPagePageIndex),
              // );

              String? svgDataOne =
                  await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                AyahRenderBlocHelper.getSvgStringFromIndex(
                    event.firstPagePageIndex),
              );
              String? svgDataTwo =
                  await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                AyahRenderBlocHelper.getSvgStringFromIndex(
                    event.secondPagePageIndex),
              );
              if (!ZoomService().isBorderEnable(event.zoomPercentage) &&
                  event.firstPagePageIndex == 0 &&
                  event.secondPagePageIndex == 1) {
                // svgDataOne = await rootBundle.loadString(
                //   AyahRenderBlocHelper.getSvgString(
                //     event.firstPagePageIndex,
                //     addInString: '-level3',
                //   ),
                // );
                // svgDataTwo = await rootBundle.loadString(
                //   AyahRenderBlocHelper.getSvgString(
                //     event.secondPagePageIndex,
                //     addInString: '-level3',
                //   ),
                // );
                svgDataOne =
                    await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                  AyahRenderBlocHelper.getSvgStringFromIndex(
                    event.firstPagePageIndex,
                    addInString: '-level3',
                  ),
                );
                svgDataTwo =
                    await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                  AyahRenderBlocHelper.getSvgStringFromIndex(
                    event.secondPagePageIndex,
                    addInString: '-level3',
                  ),
                );
              }

              svgDataOne = await AyahRenderBlocHelper.preprocessingOnSvgData(
                currentContext,
                svgData: svgDataOne,
                svgNumber: event.firstPagePageIndex + 1,
                zoomPercentage: event.zoomPercentage,
              );
              svgDataTwo = await AyahRenderBlocHelper.preprocessingOnSvgData(
                currentContext,
                svgData: svgDataTwo,
                svgNumber: event.secondPagePageIndex + 1,
                zoomPercentage: event.zoomPercentage,
              );

              bool isCustomColor = false;
              if (event.quranTextColor !=
                  QuranDetailsService.defaultQuranTextColor) {
                isCustomColor = true;
              }
              XmlDocument documentOne = XmlDocument.parse(svgDataOne);
              XmlDocument documentTwo = XmlDocument.parse(svgDataTwo);
              List<XmlElement> elementsOne =
                  AyahRenderBlocHelper.getXmlElements(
                documentOne,
              );
              List<XmlElement> elementsTwo =
                  AyahRenderBlocHelper.getXmlElements(
                documentTwo,
              );
              double widthOne = 0, heightOne = 0;
              (widthOne, heightOne) = AyahRenderBlocHelper.getWidthAndHeight(
                documentOne,
                elementsOne,
              );
              if (widthOne == 0 && heightOne == 0) {
                throw Exception(
                    "Condition Failed: widthOne !=0 && heightOne !=0");
              }

              double widthTwo = 0, heightTwo = 0;
              (widthTwo, heightTwo) = AyahRenderBlocHelper.getWidthAndHeight(
                documentTwo,
                elementsTwo,
              );
              if (widthTwo == 0 && heightTwo == 0) {
                throw Exception(
                    "Condition Failed: widthTwo !=0 && heightTwo !=0");
              }
              if (currentContext.theme.brightness == Brightness.dark) {
                svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkNight(
                  true,
                  elements: elementsOne,
                  document: documentOne,
                );
                svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkNight(
                  true,
                  elements: elementsTwo,
                  document: documentTwo,
                );
                svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkLight(
                  false,
                  elements: elementsOne,
                  document: documentOne,
                );
                svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkLight(
                  false,
                  elements: elementsTwo,
                  document: documentTwo,
                );
                svgDataOne = AyahRenderBlocHelper.colorAllAya(
                  currentContext,
                  (0 + (100 - event.darkThemeTextShade)).toDouble(),
                  elements: elementsOne,
                  document: documentOne,
                  isCustom: isCustomColor,
                );
                svgDataTwo = AyahRenderBlocHelper.colorAllAya(
                  currentContext,
                  (0 + (100 - event.darkThemeTextShade)).toDouble(),
                  elements: elementsTwo,
                  document: documentTwo,
                  isCustom: isCustomColor,
                );
              } else {
                svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkNight(
                  false,
                  elements: elementsOne,
                  document: documentOne,
                );
                svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkNight(
                  false,
                  elements: elementsTwo,
                  document: documentTwo,
                );
                svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkLight(
                  true,
                  elements: elementsOne,
                  document: documentOne,
                );
                svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkLight(
                  true,
                  elements: elementsTwo,
                  document: documentTwo,
                );
                svgDataOne = AyahRenderBlocHelper.colorAllAya(
                  currentContext,
                  100,
                  elements: elementsOne,
                  document: documentOne,
                  isCustom: isCustomColor,
                );
                svgDataTwo = AyahRenderBlocHelper.colorAllAya(
                  currentContext,
                  100,
                  elements: elementsTwo,
                  document: documentTwo,
                  isCustom: isCustomColor,
                );
              }
              List<SvgElement> svgElementsListOne =
                  AyahRenderBlocHelper.getSvgElementList(
                elementsOne,
              );
              List<SvgElement> svgElementsListTwo =
                  AyahRenderBlocHelper.getSvgElementList(
                elementsTwo,
              );

              String? originalFetchBoxOne =
                  AyahRenderBlocHelper.fetchViewBoxOriginal(
                      currentContext, svgDataOne);
              String? originalFetchBoxTwo =
                  AyahRenderBlocHelper.fetchViewBoxOriginal(
                      currentContext, svgDataTwo);
              await AyahRenderBlocHelper.getDelay();
              emit(
                TwoPageAyahRendered(
                  firstPageIndex: event.firstPagePageIndex,
                  secondPageIndex: event.secondPagePageIndex,
                  quranTextColor: event.quranTextColor,
                  darkThemeTextShade: event.darkThemeTextShade,
                  firstCurrentPage: currentPageOne,
                  secondCurrentPage: currentPageTwo,
                  firstPageSvgData: svgDataOne,
                  secondPageSvgData: svgDataTwo,
                  firstPageDocument: documentOne,
                  secondPageDocument: documentTwo,
                  firstPageElements: elementsOne,
                  secondPageElements: elementsTwo,
                  firstPageSvgWidth: widthOne,
                  firstPageSvgHeight: heightOne,
                  secondPageSvgWidth: widthTwo,
                  secondPageSvgHeight: heightTwo,
                  firstPageSvgElementsList: svgElementsListOne,
                  secondPageSvgElementsList: svgElementsListTwo,
                  firstOriginalViewBox: originalFetchBoxOne,
                  secondOriginalViewBox: originalFetchBoxTwo,
                ),
              );
            } else {
              throw Exception();
            }
          }
        } catch (e) {
          debugPrint(e.toString());
          emit(
            AyahTwoPageRenderInitial(),
          );
        }
      },
    );

    on<IntializeTwoPageRenderWidgetWithTwoNextPage>(
      (event, emit) async {
        try {
          //Get Application Context To Fetch State
          final BuildContext? currentContext = AppContext.getAppContext();
          if (currentContext != null) {
            final AyahTwoPageRenderState currentState =
                BlocProvider.of<AyahTwoPageRenderBloc>(currentContext).state;
            //Fetch Ayah Render Bloc State
            if (currentState is TwoPageAyahRendered &&
                currentState.firstPageIndex != null &&
                currentState.secondPageIndex != null) {
              final SharedPreferences sharedPreferences = getItInstance();
              sharedPreferences.setInt(AppStrings.savedCurrentMoshafPageNumber,
                  event.firstPagePageIndex);

              emit(
                AyahTwoPageRendering(),
              );
              String currentPageOne = AppStrings.getAssetSvgNormalPagePath(
                event.firstPagePageIndex + 1,
              );
              String currentPageTwo = AppStrings.getAssetSvgNormalPagePath(
                event.secondPagePageIndex + 1,
              );

              if (currentState.firstPageSvgData != null &&
                  currentState.svgDataNextPageFirst != null &&
                  currentState.firstPageSvgData != null &&
                  currentState.svgDataNextPageSecond != null) {
                //This means that svg data is not null hence we already have svgData
                // Change Next SvgData to Svg Data and Fetch Next Svg Data
                //Update Current Svg Data
                XmlDocument nextDocumentOne =
                    XmlDocument.parse(currentState.svgDataNextPageFirst!);
                XmlDocument nextDocumentTwo =
                    XmlDocument.parse(currentState.svgDataNextPageSecond!);
                List<XmlElement> nextElementsOne =
                    AyahRenderBlocHelper.getXmlElements(
                  nextDocumentOne,
                );
                List<XmlElement> nextElementsTwo =
                    AyahRenderBlocHelper.getXmlElements(
                  nextDocumentTwo,
                );
                double nextWidthOne = 0, nextHeightOne = 0;
                double nextWidthTwo = 0, nextHeightTwo = 0;
                (nextWidthOne, nextHeightOne) =
                    AyahRenderBlocHelper.getWidthAndHeight(
                  nextDocumentOne,
                  nextElementsOne,
                );
                (nextWidthTwo, nextHeightTwo) =
                    AyahRenderBlocHelper.getWidthAndHeight(
                  nextDocumentTwo,
                  nextElementsTwo,
                );
                if (nextWidthOne == 0 &&
                    nextHeightOne == 0 &&
                    nextWidthTwo == 0 &&
                    nextHeightTwo == 0) {
                  throw Exception("Condition Failed: width !=0 && height !=0");
                }
                List<SvgElement> nextSvgElementsListOne =
                    AyahRenderBlocHelper.getSvgElementList(
                  nextElementsOne,
                );
                List<SvgElement> nextSvgElementsListTwo =
                    AyahRenderBlocHelper.getSvgElementList(
                  nextElementsTwo,
                );

                String? nextOriginalFetchBoxOne =
                    AyahRenderBlocHelper.fetchViewBoxOriginal(
                        currentContext, currentState.svgDataNextPageFirst!);
                String? nextOriginalFetchBoxTwo =
                    AyahRenderBlocHelper.fetchViewBoxOriginal(
                        currentContext, currentState.svgDataNextPageSecond!);

                emit(
                  TwoPageAyahRendered(
                    firstPageIndex: event.firstPagePageIndex,
                    secondPageIndex: event.secondPagePageIndex,
                    quranTextColor: event.quranTextColor,
                    darkThemeTextShade: event.darkThemeTextShade,
                    firstCurrentPage: currentPageOne,
                    secondCurrentPage: currentPageTwo,
                    firstPageSvgData: currentState.svgDataNextPageFirst,
                    secondPageSvgData: currentState.svgDataNextPageSecond,
                    firstPageDocument: nextDocumentOne,
                    secondPageDocument: nextDocumentTwo,
                    firstPageElements: nextElementsOne,
                    secondPageElements: nextElementsTwo,
                    firstPageSvgWidth: nextWidthOne,
                    firstPageSvgHeight: nextHeightOne,
                    secondPageSvgWidth: nextWidthTwo,
                    secondPageSvgHeight: nextHeightTwo,
                    firstPageSvgElementsList: nextSvgElementsListOne,
                    secondPageSvgElementsList: nextSvgElementsListTwo,
                    firstOriginalViewBox: nextOriginalFetchBoxOne,
                    secondOriginalViewBox: nextOriginalFetchBoxTwo,
                  ),
                );

                //Fetch Next Svg Data
                String? nextSvgDataOne =
                    await AyahRenderBlocHelper.getNextSvgData(
                  currentContext,
                  event.firstPagePageIndex + 1,
                  event.zoomPercentage,
                  event.quranTextColor,
                  event.darkThemeTextShade,
                );
                String? nextSvgDataTwo =
                    await AyahRenderBlocHelper.getNextSvgData(
                  currentContext,
                  event.secondPagePageIndex + 1,
                  event.zoomPercentage,
                  event.quranTextColor,
                  event.darkThemeTextShade,
                );
                if (nextSvgDataOne != null && nextSvgDataTwo != null) {
                  final AyahTwoPageRenderState currentNewState =
                      BlocProvider.of<AyahTwoPageRenderBloc>(currentContext)
                          .state;
                  if (currentNewState is TwoPageAyahRendered) {
                    emit(
                      AyahTwoPageRendering(),
                    );
                    emit(
                      TwoPageAyahRendered(
                        firstPageIndex: currentNewState.firstPageIndex,
                        secondPageIndex: currentNewState.secondPageIndex,
                        quranTextColor: currentNewState.quranTextColor,
                        darkThemeTextShade: currentNewState.darkThemeTextShade,
                        firstCurrentPage: currentNewState.firstCurrentPage,
                        secondCurrentPage: currentNewState.secondCurrentPage,
                        firstPageSvgData: currentNewState.svgDataNextPageFirst,
                        secondPageSvgData:
                            currentNewState.svgDataNextPageSecond,
                        firstPageDocument: currentNewState.firstPageDocument,
                        secondPageDocument: currentNewState.secondPageDocument,
                        firstPageElements: currentNewState.firstPageElements,
                        secondPageElements: currentNewState.secondPageElements,
                        firstPageSvgWidth: currentNewState.firstPageSvgWidth,
                        firstPageSvgHeight: currentNewState.firstPageSvgHeight,
                        secondPageSvgWidth: currentNewState.secondPageSvgWidth,
                        secondPageSvgHeight:
                            currentNewState.secondPageSvgHeight,
                        firstPageSvgElementsList:
                            currentNewState.firstPageSvgElementsList,
                        secondPageSvgElementsList:
                            currentNewState.secondPageSvgElementsList,
                        firstOriginalViewBox:
                            currentNewState.firstOriginalViewBox,
                        secondOriginalViewBox:
                            currentNewState.secondOriginalViewBox,
                        svgDataNextPageFirst: nextSvgDataOne,
                        svgDataNextPageSecond: nextSvgDataTwo,
                      ),
                    );
                  }
                }
              } else {
                //This means that svg data is null hence first time we are rendering

                // String? svgDataOne = await rootBundle.loadString(
                //   AyahRenderBlocHelper.getSvgString(event.firstPagePageIndex),
                // );
                // String? svgDataTwo = await rootBundle.loadString(
                //   AyahRenderBlocHelper.getSvgString(event.secondPagePageIndex),
                // );
                String? svgDataOne =
                    await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                  AyahRenderBlocHelper.getSvgStringFromIndex(
                      event.firstPagePageIndex),
                );
                String? svgDataTwo =
                    await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                  AyahRenderBlocHelper.getSvgStringFromIndex(
                      event.secondPagePageIndex),
                );
                if (!ZoomService().isBorderEnable(event.zoomPercentage) &&
                    event.firstPagePageIndex == 0 &&
                    event.secondPagePageIndex == 1) {
                  svgDataOne =
                      await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                    AyahRenderBlocHelper.getSvgStringFromIndex(
                      event.firstPagePageIndex,
                      addInString: '-level3',
                    ),
                  );
                  svgDataTwo =
                      await PlayAssetDelivery.getSvgDataFromPlayAssetDelivery(
                    AyahRenderBlocHelper.getSvgStringFromIndex(
                      event.secondPagePageIndex,
                      addInString: '-level3',
                    ),
                  );
                  // svgDataOne = await rootBundle.loadString(
                  //   AyahRenderBlocHelper.getSvgString(
                  //     event.firstPagePageIndex,
                  //     addInString: '-level3',
                  //   ),
                  // );
                  // svgDataTwo = await rootBundle.loadString(
                  //   AyahRenderBlocHelper.getSvgString(
                  //     event.secondPagePageIndex,
                  //     addInString: '-level3',
                  //   ),
                  // );
                }

                svgDataOne = await AyahRenderBlocHelper.preprocessingOnSvgData(
                  currentContext,
                  svgData: svgDataOne,
                  svgNumber: event.firstPagePageIndex + 1,
                  zoomPercentage: event.zoomPercentage,
                );
                svgDataTwo = await AyahRenderBlocHelper.preprocessingOnSvgData(
                  currentContext,
                  svgData: svgDataTwo,
                  svgNumber: event.secondPagePageIndex + 1,
                  zoomPercentage: event.zoomPercentage,
                );

                bool isCustomColor = false;
                if (event.quranTextColor !=
                    QuranDetailsService.defaultQuranTextColor) {
                  isCustomColor = true;
                }
                XmlDocument documentOne = XmlDocument.parse(svgDataOne);
                XmlDocument documentTwo = XmlDocument.parse(svgDataTwo);
                List<XmlElement> elementsOne =
                    AyahRenderBlocHelper.getXmlElements(
                  documentOne,
                );
                List<XmlElement> elementsTwo =
                    AyahRenderBlocHelper.getXmlElements(
                  documentTwo,
                );
                double widthOne = 0, heightOne = 0;
                (widthOne, heightOne) = AyahRenderBlocHelper.getWidthAndHeight(
                  documentOne,
                  elementsOne,
                );
                if (widthOne == 0 && heightOne == 0) {
                  throw Exception(
                      "Condition Failed: widthOne !=0 && heightOne !=0");
                }

                double widthTwo = 0, heightTwo = 0;
                (widthTwo, heightTwo) = AyahRenderBlocHelper.getWidthAndHeight(
                  documentTwo,
                  elementsTwo,
                );
                if (widthTwo == 0 && heightTwo == 0) {
                  throw Exception(
                      "Condition Failed: widthTwo !=0 && heightTwo !=0");
                }
                if (currentContext.theme.brightness == Brightness.dark) {
                  svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkNight(
                    true,
                    elements: elementsOne,
                    document: documentOne,
                  );
                  svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkNight(
                    true,
                    elements: elementsTwo,
                    document: documentTwo,
                  );
                  svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkLight(
                    false,
                    elements: elementsOne,
                    document: documentOne,
                  );
                  svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkLight(
                    false,
                    elements: elementsTwo,
                    document: documentTwo,
                  );
                  svgDataOne = AyahRenderBlocHelper.colorAllAya(
                    currentContext,
                    (0 + (100 - event.darkThemeTextShade)).toDouble(),
                    elements: elementsOne,
                    document: documentOne,
                    isCustom: isCustomColor,
                  );
                  svgDataTwo = AyahRenderBlocHelper.colorAllAya(
                    currentContext,
                    (0 + (100 - event.darkThemeTextShade)).toDouble(),
                    elements: elementsTwo,
                    document: documentTwo,
                    isCustom: isCustomColor,
                  );
                } else {
                  svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkNight(
                    false,
                    elements: elementsOne,
                    document: documentOne,
                  );
                  svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkNight(
                    false,
                    elements: elementsTwo,
                    document: documentTwo,
                  );
                  svgDataOne = AyahRenderBlocHelper.hideShowAyaMarkLight(
                    true,
                    elements: elementsOne,
                    document: documentOne,
                  );
                  svgDataTwo = AyahRenderBlocHelper.hideShowAyaMarkLight(
                    true,
                    elements: elementsTwo,
                    document: documentTwo,
                  );
                  svgDataOne = AyahRenderBlocHelper.colorAllAya(
                    currentContext,
                    100,
                    elements: elementsOne,
                    document: documentOne,
                    isCustom: isCustomColor,
                  );
                  svgDataTwo = AyahRenderBlocHelper.colorAllAya(
                    currentContext,
                    100,
                    elements: elementsTwo,
                    document: documentTwo,
                    isCustom: isCustomColor,
                  );
                }
                List<SvgElement> svgElementsListOne =
                    AyahRenderBlocHelper.getSvgElementList(
                  elementsOne,
                );
                List<SvgElement> svgElementsListTwo =
                    AyahRenderBlocHelper.getSvgElementList(
                  elementsTwo,
                );

                String? originalFetchBoxOne =
                    AyahRenderBlocHelper.fetchViewBoxOriginal(
                        currentContext, svgDataOne);
                String? originalFetchBoxTwo =
                    AyahRenderBlocHelper.fetchViewBoxOriginal(
                        currentContext, svgDataTwo);
                await AyahRenderBlocHelper.getDelay();
                emit(
                  TwoPageAyahRendered(
                    firstPageIndex: event.firstPagePageIndex,
                    secondPageIndex: event.secondPagePageIndex,
                    quranTextColor: event.quranTextColor,
                    darkThemeTextShade: event.darkThemeTextShade,
                    firstCurrentPage: currentPageOne,
                    secondCurrentPage: currentPageTwo,
                    firstPageSvgData: svgDataOne,
                    secondPageSvgData: svgDataTwo,
                    firstPageDocument: documentOne,
                    secondPageDocument: documentTwo,
                    firstPageElements: elementsOne,
                    secondPageElements: elementsTwo,
                    firstPageSvgWidth: widthOne,
                    firstPageSvgHeight: heightOne,
                    secondPageSvgWidth: widthTwo,
                    secondPageSvgHeight: heightTwo,
                    firstPageSvgElementsList: svgElementsListOne,
                    secondPageSvgElementsList: svgElementsListTwo,
                    firstOriginalViewBox: originalFetchBoxOne,
                    secondOriginalViewBox: originalFetchBoxTwo,
                  ),
                );
                String? nextSvgDataOne =
                    await AyahRenderBlocHelper.getNextSvgData(
                  currentContext,
                  event.firstPagePageIndex,
                  event.zoomPercentage,
                  event.quranTextColor,
                  event.darkThemeTextShade,
                );
                String? nextSvgDataTwo =
                    await AyahRenderBlocHelper.getNextSvgData(
                  currentContext,
                  event.secondPagePageIndex,
                  event.zoomPercentage,
                  event.quranTextColor,
                  event.darkThemeTextShade,
                );
                if (nextSvgDataOne != null && nextSvgDataTwo != null) {
                  final AyahTwoPageRenderState currentNewState =
                      BlocProvider.of<AyahTwoPageRenderBloc>(currentContext)
                          .state;
                  if (currentNewState is TwoPageAyahRendered) {
                    emit(
                      TwoPageAyahRendered(
                        firstPageIndex: currentNewState.firstPageIndex,
                        secondPageIndex: currentNewState.secondPageIndex,
                        quranTextColor: currentNewState.quranTextColor,
                        darkThemeTextShade: currentNewState.darkThemeTextShade,
                        firstCurrentPage: currentNewState.firstCurrentPage,
                        secondCurrentPage: currentNewState.secondCurrentPage,
                        firstPageSvgData: currentNewState.svgDataNextPageFirst,
                        secondPageSvgData:
                            currentNewState.svgDataNextPageSecond,
                        firstPageDocument: currentNewState.firstPageDocument,
                        secondPageDocument: currentNewState.secondPageDocument,
                        firstPageElements: currentNewState.firstPageElements,
                        secondPageElements: currentNewState.secondPageElements,
                        firstPageSvgWidth: currentNewState.firstPageSvgWidth,
                        firstPageSvgHeight: currentNewState.firstPageSvgHeight,
                        secondPageSvgWidth: currentNewState.secondPageSvgWidth,
                        secondPageSvgHeight:
                            currentNewState.secondPageSvgHeight,
                        firstPageSvgElementsList:
                            currentNewState.firstPageSvgElementsList,
                        secondPageSvgElementsList:
                            currentNewState.secondPageSvgElementsList,
                        firstOriginalViewBox:
                            currentNewState.firstOriginalViewBox,
                        secondOriginalViewBox:
                            currentNewState.secondOriginalViewBox,
                        svgDataNextPageFirst: nextSvgDataOne,
                        svgDataNextPageSecond: nextSvgDataTwo,
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
            AyahTwoPageRenderInitial(),
          );
        }
      },
    );

    on<UpdateAyahTwoPageRenderedState>(
      (event, emit) async {
        try {
          emit(
            AyahTwoPageRendering(),
          );
          emit(TwoPageAyahRendered(
            firstPageIndex:
                event.firstPageIndex ?? event.previousState.firstPageIndex,
            secondPageIndex:
                event.secondPageIndex ?? event.previousState.secondPageIndex,
            quranTextColor:
                event.quranTextColor ?? event.previousState.quranTextColor,
            darkThemeTextShade: event.darkThemeTextShade ??
                event.previousState.darkThemeTextShade,
            firstCurrentPage:
                event.firstCurrentPage ?? event.previousState.firstCurrentPage,
            secondCurrentPage: event.secondCurrentPage ??
                event.previousState.secondCurrentPage,
            firstPageSvgData:
                event.firstPageSvgData ?? event.previousState.firstPageSvgData,
            secondPageSvgData: event.secondPageSvgData ??
                event.previousState.secondPageSvgData,
            firstPageDocument: event.firstPageDocument ??
                event.previousState.firstPageDocument,
            secondPageDocument: event.secondPageDocument ??
                event.previousState.secondPageDocument,
            firstPageElements: event.firstPageElements ??
                event.previousState.firstPageElements,
            secondPageElements: event.secondPageElements ??
                event.previousState.secondPageElements,
            firstPageSvgWidth: event.firstPageSvgWidth ??
                event.previousState.firstPageSvgWidth,
            firstPageSvgHeight: event.firstPageSvgHeight ??
                event.previousState.firstPageSvgHeight,
            secondPageSvgWidth: event.secondPageSvgWidth ??
                event.previousState.secondPageSvgWidth,
            secondPageSvgHeight: event.secondPageSvgHeight ??
                event.previousState.secondPageSvgHeight,
            firstPageSvgElementsList: event.firstPageSvgElementsList ??
                event.previousState.firstPageSvgElementsList,
            secondPageSvgElementsList: event.secondPageSvgElementsList ??
                event.previousState.secondPageSvgElementsList,
            layoutContext:
                event.layoutContext ?? event.previousState.layoutContext,
            firstOriginalViewBox: event.firstPageOriginalViewBox ??
                event.previousState.firstOriginalViewBox,
            secondOriginalViewBox: event.secondPageOriginalViewBox ??
                event.previousState.secondOriginalViewBox,
          ));
        } catch (e) {
          debugPrint(e.toString());
          emit(
            AyahTwoPageRenderInitial(),
          );
        }
      },
    );
  }
}
