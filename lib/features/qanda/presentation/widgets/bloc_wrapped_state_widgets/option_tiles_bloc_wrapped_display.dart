import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/data/models/qanda_model.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_cubit/qanda_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_service.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../static_widgets/gradient_button.dart';

class OptionTilesBlocWrappedDisplay extends StatefulWidget {
  const OptionTilesBlocWrappedDisplay({
    super.key,
    required this.quizQuestionDetails,
  });
  final QuizQuestion quizQuestionDetails;

  @override
  State<OptionTilesBlocWrappedDisplay> createState() =>
      _OptionTilesBlocWrappedDisplayState();
}

class _OptionTilesBlocWrappedDisplayState
    extends State<OptionTilesBlocWrappedDisplay> {
  bool isSelectedA = false, isSelectedB = false, isSelectedC = false;

  final Color _buttonColorShadeDarkGreen = const Color(0xff78ca8c),
      _buttonColorShadeLightGreen = const Color(0xff98dbaf);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QandaCubit, QandaState>(
      builder: (context, qandaState) {
        bool isAnswered = false;
        if (qandaState is UserQandADetailsFetched) {
          for (final UserQandA currentUserQuestion in qandaState.userAnswers) {
            if (currentUserQuestion.id == widget.quizQuestionDetails.id) {
              isAnswered = true;
            }
          }
        }
        bool isCorrectA = false, isCorrectB = false, isCorrectC = false;
        if (widget.quizQuestionDetails.correctAnswer == 1) {
          isCorrectA = true;
        } else if (widget.quizQuestionDetails.correctAnswer == 2) {
          isCorrectB = true;
        } else if (widget.quizQuestionDetails.correctAnswer == 3) {
          isCorrectC = true;
        }

        return Column(
          children: [
            _OptionTile(
              optionText: widget.quizQuestionDetails.optionA,
              isCorrect: isAnswered ? isCorrectA : null,
              isAnswered: isAnswered,
              onTap: () {
                setState(() {
                  isSelectedA = !isSelectedA;
                  isSelectedB = false;
                  isSelectedC = false;
                });
              },
              isSelected: isSelectedA,
            ),
            _OptionTile(
              optionText: widget.quizQuestionDetails.optionB,
              isCorrect: isAnswered ? isCorrectB : null,
              isAnswered: isAnswered,
              onTap: () {
                setState(() {
                  isSelectedB = !isSelectedB;
                  isSelectedA = false;
                  isSelectedC = false;
                });
              },
              isSelected: isSelectedB,
            ),
            _OptionTile(
              optionText: widget.quizQuestionDetails.optionC,
              isCorrect: isAnswered ? isCorrectC : null,
              isAnswered: isAnswered,
              onTap: () {
                setState(() {
                  isSelectedC = !isSelectedC;
                  isSelectedA = false;
                  isSelectedB = false;
                });
              },
              isSelected: isSelectedC,
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            // Check Button
            GradientButton(
              text: isAnswered
                  ? context.translate.next
                  : context.translate.verify,
              onPressed: () {
                print(isAnswered);
                if (!isAnswered) {
                  int answerNumber = 0;
                  if (isSelectedA) {
                    answerNumber = 1;
                  } else if (isSelectedB) {
                    answerNumber = 2;
                  } else if (isSelectedC) {
                    answerNumber = 3;
                  }
                  if (answerNumber != 0) {
                    UserQandA currentAnswer = UserQandA(
                      id: widget.quizQuestionDetails.id,
                      answerNumber: answerNumber,
                      points: widget.quizQuestionDetails.correctAnswer ==
                              answerNumber
                          ? 1
                          : 0,
                    );
                    QandaService.giveUserAnswer(currentAnswer);
                  }
                } else {
                  setState(() {
                    isSelectedA = false;
                    isSelectedB = false;
                    isSelectedC = false;
                  });
                  QandaService.switchToNextQuestion();
                }
              },
              colorHigh: _buttonColorShadeLightGreen,
              colorLow: _buttonColorShadeDarkGreen,
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String optionText;
  final bool? isCorrect;
  final bool isAnswered;
  final bool isSelected;
  final VoidCallback? onTap;
  const _OptionTile({
    required this.optionText,
    required this.isAnswered,
    this.isSelected = false,
    this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.purple;
    IconData? icon;

    if (isAnswered) {
      borderColor = isCorrect == true ? Colors.green : Colors.red;
      icon = isCorrect == true ? Icons.check : Icons.close;
    }
    if (isSelected && !isAnswered) {
      icon = Icons.check;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
          color: context.isDarkMode ? Colors.black : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              optionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon != null) Icon(icon, color: borderColor),
          ],
        ),
      ),
    );
  }
}
