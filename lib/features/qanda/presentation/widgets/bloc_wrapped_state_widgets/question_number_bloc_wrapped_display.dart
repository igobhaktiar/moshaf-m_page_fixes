import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_cubit/qanda_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../data/models/qanda_model.dart';

class QuestionNumberBlocWrappedDisplay extends StatelessWidget {
  const QuestionNumberBlocWrappedDisplay({
    super.key,
    required this.totalAnswers,
    required this.currentQuestion,
  });
  final QuizQuestion currentQuestion;
  final int totalAnswers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Directionality(
          textDirection:
              context.isDarkMode ? TextDirection.rtl : TextDirection.ltr,
          child: BlocBuilder<QandaCubit, QandaState>(
            builder: (context, userQuestionState) {
              bool isAnswered = false;
              if (userQuestionState is UserQandADetailsFetched) {
                for (final UserQandA currentUserQuestion
                    in userQuestionState.userAnswers) {
                  if (currentUserQuestion.id == currentQuestion.id) {
                    isAnswered = true;
                  }
                }
              }
              //next question name
              return _StyledTextField(
                text:
                    '${context.translate.question} ${(userQuestionState is UserQandADetailsFetched) ? (isAnswered ? userQuestionState.userAnswers.length : userQuestionState.userAnswers.length + 1).toString() : 1} / ${totalAnswers.toString()}',
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        color: context.isDarkMode ? Colors.white : Colors.purple,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
