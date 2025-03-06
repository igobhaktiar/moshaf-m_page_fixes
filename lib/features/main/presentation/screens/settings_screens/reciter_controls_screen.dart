// ayat menu
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/reciter_image_cubit/reciter_image_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/widgets/button_row_display.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../cubit/reciter_image_cubit/reciter_image_service.dart';

class ReciterControlsScreen extends StatelessWidget {
  const ReciterControlsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.reciters),
          leading: AppConstants.customBackButton(context),
          actions: [
            AppConstants.customHomeButton(context, doublePop: true),
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0.0, 16, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
                          child: Text(
                            context.translate.show_reciter_images,
                            style: context.textTheme.displayMedium,
                          ),
                        ),
                        Card(
                          clipBehavior: Clip.antiAlias,
                          color: context.theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            side: BorderSide(
                                color: AppColors.border,
                                width:
                                    context.theme.brightness == Brightness.dark
                                        ? 0.0
                                        : 1.5),
                          ),
                          child:
                              BlocBuilder<ReciterImageCubit, ReciterImageState>(
                            builder: (context, reciterImageCubitState) {
                              bool isShowReciterImage = true;
                              if (reciterImageCubitState
                                  is ReciterImageControlState) {
                                isShowReciterImage =
                                    reciterImageCubitState.showReciterImages;
                              }
                              return Column(
                                children: [
                                  _SelectionCard(
                                    index: 0,
                                    headingText: context.translate.yes,
                                    bodyText: context
                                        .translate.see_images_when_listening,
                                    isSelected:
                                        isShowReciterImage ? true : false,
                                    onTap: () {
                                      ReciterControlsService
                                          .setReciterImagesToShow(context,
                                              showReciterImages: true);
                                    },
                                  ),
                                  AppConstants.appDivider(context, indent: 40),
                                  _SelectionCard(
                                    index: 1,
                                    headingText: context.translate.no,
                                    bodyText: context.translate
                                        .dont_see_images_when_listening,
                                    isSelected:
                                        isShowReciterImage ? false : true,
                                    onTap: () {
                                      ReciterControlsService
                                          .setReciterImagesToShow(context,
                                              showReciterImages: false);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ),
                ),
              )
            ]));
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.index,
    required this.headingText,
    required this.bodyText,
    required this.isSelected,
    required this.onTap,
  });
  final int index;
  final String headingText, bodyText;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: index != 1
          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 12)
          : EdgeInsets.zero,
      child: InkWell(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding: index == 1
                        ? const EdgeInsets.fromLTRB(5, 12, 5, 20)
                        : EdgeInsets.zero,
                    child: ButtonRowDisplay(
                      title: headingText,
                      subtitle: bodyText,
                      height: 8,
                      isChecked: isSelected,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
