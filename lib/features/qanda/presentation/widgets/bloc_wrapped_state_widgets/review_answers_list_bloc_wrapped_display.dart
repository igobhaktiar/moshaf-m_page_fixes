import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/data/models/qanda_model.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_cubit/qanda_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_service.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class ReviewAnswersListBlocWrappedDisplay extends StatelessWidget {
  const ReviewAnswersListBlocWrappedDisplay({super.key});

  Widget nullReturn(BuildContext context) {
    return Center(
      child: Text(context.translate.noQuestionsAnsweredYet),
    );
  }

  String getAnswerByNumber(
    int correctAns,
    QuizQuestion currentQuestion,
  ) {
    String currentReturnOption = ' ';
    if (correctAns == 1) {
      currentReturnOption = currentQuestion.optionA;
    } else if (correctAns == 2) {
      currentReturnOption = currentQuestion.optionB;
    } else if (correctAns == 3) {
      currentReturnOption = currentQuestion.optionC;
    }
    return currentReturnOption;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QandaCubit, QandaState>(
      builder: (context, qandAState) {
        if (qandAState is UserQandADetailsFetched &&
            qandAState.userAnswers.isNotEmpty) {
          return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: qandAState.userAnswers.length,
              itemBuilder: (context, index) {
                UserQandA currentQandA = qandAState.userAnswers[index];
                QuizQuestion? currentQuestion =
                    QandaService.getQuestionById(currentQandA.id);
                if (currentQuestion != null) {
                  bool isCorrectAnswer =
                      currentQandA.answerNumber == currentQuestion.correctAnswer
                          ? true
                          : false;
                  return Container(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        CircleAvatar(
                          backgroundColor: context.isDarkMode
                              ? Colors.white
                              : isCorrectAnswer
                                  ? Colors.green
                                  : Colors.red,
                          child: Icon(
                            isCorrectAnswer ? Icons.check : Icons.close,
                            color: context.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  '${context.translate.question}: ${currentQuestion.question}'),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  '${context.translate.correctAnswer}: ${getAnswerByNumber(currentQuestion.correctAnswer, currentQuestion)}'),
                              Text(
                                  '${context.translate.yourAnswer}: ${getAnswerByNumber(currentQandA.answerNumber, currentQuestion)}'),
                              Text(
                                isCorrectAnswer
                                    ? context.translate.yourAnswerIsCorrect
                                    : context.translate.yourAnswerIsWrong,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  );
                } else {
                  return nullReturn(context);
                }
              });
        } else {
          return nullReturn(context);
        }
      },
    );
  }
}
