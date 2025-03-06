import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/fetched_questions_cubit/fetched_questions_cubit.dart';

import 'progress_indicators_bloc_wrapped_widget.dart';
import 'question_and_choice_bloc_wrapped_display.dart';

class QAndABlocWrappedBody extends StatelessWidget {
  const QAndABlocWrappedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchedQuestionsCubit, FetchedQuestionsState>(
      builder: (context, fetchedQuestionsState) {
        if (fetchedQuestionsState is FetchedQuestions) {
          return Column(
            children: [
              // Progress Indicator and Question Counter
              const ProgressIndicatorsBlocWrappedWidget(),
              // Question
              QuestionAndChoiceBlocWrappedDisplay(
                totalQuizQuestions: fetchedQuestionsState.totalQuizQuestions,
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
