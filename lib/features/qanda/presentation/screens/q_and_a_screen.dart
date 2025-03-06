import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_service.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/screens/review_answers_screen.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/widgets/bloc_wrapped_state_widgets/q_and_a_bloc_wrapped_body.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/slide_pagee_transition.dart';
import '../widgets/static_widgets/bottom_option_button.dart';
import '../widgets/static_widgets/timer_circle_display.dart';

class QandAScreen extends StatelessWidget {
  const QandAScreen({Key? key}) : super(key: key);

  final Color _playAgainButtonColor = const Color(0xff3e7dab),
      _reviewAnswerButtonColor = const Color(0xffc29a73),
      _shareButtonColor = const Color(0xff6d7dd5),
      _curvedBackgroundTopperColor = const Color(0xff8f5c0b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(context.translate.quranQA),
        leading: AppConstants.customBackButton(context),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft:
                      Radius.circular(50), // Curving the bottom left corner
                  bottomRight:
                      Radius.circular(50), // Curving the bottom right corner
                ),
                color: _curvedBackgroundTopperColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
              right: 30.0,
              bottom: 30.0,
              top: 50.0,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 16.0,
                top: 25.0,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft:
                      Radius.circular(50), // Curving the bottom left corner
                  topRight:
                      Radius.circular(50), // Curving the bottom right corner
                ),
                color: context.isDarkMode ? Colors.black : Colors.white,
              ),
              child: Column(
                children: [
                  const QAndABlocWrappedBody(),

                  // Bottom Options
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BottomOption(
                        icon: Icons.refresh,
                        label: context.translate.playAgain,
                        color: _playAgainButtonColor,
                        onTap: () {
                          QandaService.resetUserAnswers();
                          Future.delayed(
                              const Duration(
                                milliseconds: 200,
                              ), () {
                            pushSlide(
                              AppContext.getAppContext()!,
                              pushWithOverlayValues: true,
                              screen: const QandAScreen(),
                            );
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      BottomOption(
                        icon: Icons.visibility,
                        label: context.translate.reviewAnswer,
                        color: _reviewAnswerButtonColor,
                        onTap: () {
                          pushSlide(
                            AppContext.getAppContext()!,
                            pushWithOverlayValues: true,
                            screen: const ReviewAnswersScreen(),
                          );
                        },
                      ),
                      BottomOption(
                        icon: Icons.share,
                        label: context.translate.share,
                        color: _shareButtonColor,
                        onTap: () {
                          QandaService.shareCurrentQuestion();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              top: 16.0,
            ),
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: TimerCircleDisplay(),
            ),
          ),
        ],
      ),
    );
  }
}
