import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_context.dart';
import '../../../data/models/qanda_model.dart';
import '../qanda_service.dart';

part 'fetched_questions_state.dart';

class FetchedQuestionsCubit extends Cubit<FetchedQuestionsState> {
  FetchedQuestionsCubit() : super(FetchedQuestionsInitial());

  init() async {
    emit(FetchedQuestionsLoading());
    List<QuizQuestion> fetchedQuestions =
        await QandaService.fetchListOfQuestions();
    emit(
      FetchedQuestions(
        totalQuizQuestions: fetchedQuestions,
      ),
    );
  }

  void nextPageLoad() {
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      final FetchedQuestionsState fetchedQuestionsState =
          BlocProvider.of<FetchedQuestionsCubit>(appContext).state;
      if (fetchedQuestionsState is FetchedQuestions) {
        List<QuizQuestion> fetchedQuestions =
            fetchedQuestionsState.totalQuizQuestions;
        emit(FetchedQuestionsLoading());
        emit(
          FetchedQuestions(
            totalQuizQuestions: fetchedQuestions,
          ),
        );
      }
    }
  }
}
