import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/fetched_questions_cubit/fetched_questions_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_cubit/qanda_cubit.dart';
import 'package:share/share.dart';

import '../../data/datasources/qanda_database_service.dart';
import '../../data/models/qanda_model.dart';

class QandaService {
  QandaService._();

  static Future<List<QuizQuestion>> fetchListOfQuestions() async {
    List<QuizQuestion> fetchedQuizQuestions = [];
    try {
      fetchedQuizQuestions = await QAndADatabaseService.loadCsvData();
    } catch (e) {
      debugPrint(e.toString());
    }
    return fetchedQuizQuestions;
  }

  static void switchToNextQuestion() {
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      BlocProvider.of<FetchedQuestionsCubit>(appContext).nextPageLoad();
    }
  }

  static int getCompletedQuizCount() {
    int completedQuizCount = 0;
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      final QandaState qandaState =
          BlocProvider.of<QandaCubit>(appContext).state;
      if (qandaState is UserQandADetailsFetched) {
        completedQuizCount = qandaState.userAnswers.length;
      }
    }
    return completedQuizCount;
  }

  static int getTotalQuizesCount() {
    int totalCount = 0;
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      final FetchedQuestionsState fetchedQuestionsState =
          BlocProvider.of<FetchedQuestionsCubit>(appContext).state;
      if (fetchedQuestionsState is FetchedQuestions) {
        totalCount = fetchedQuestionsState.totalQuizQuestions.length;
      }
    }
    return totalCount;
  }

  static QuizQuestion? getCurrentQuestion() {
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      final FetchedQuestionsState fetchedQuestionsState =
          BlocProvider.of<FetchedQuestionsCubit>(appContext).state;
      if (fetchedQuestionsState is FetchedQuestions) {
        QuizQuestion currentQuestion = fetchedQuestionsState
            .totalQuizQuestions[QandaService.getCompletedQuizCount()];
        return currentQuestion;
      }
    }
    return null;
  }

  static void shareCurrentQuestion() {
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      final FetchedQuestionsState fetchedQuestionsState =
          BlocProvider.of<FetchedQuestionsCubit>(appContext).state;
      if (fetchedQuestionsState is FetchedQuestions) {
        QuizQuestion currentQuestion = fetchedQuestionsState
            .totalQuizQuestions[QandaService.getCompletedQuizCount()];
        final shareString =
            'سؤال:${currentQuestion.question}\nالخيار 1: ${currentQuestion.optionA}\nالخيار 2: ${currentQuestion.optionB} \nالخيار 3: ${currentQuestion.optionC}';
        Share.share(shareString);
      }
    }
  }

  static void giveUserAnswer(UserQandA userAnswer) {
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      BlocProvider.of<QandaCubit>(appContext).setAndUpdateUserQandA(
        userAnswer,
      );
    }
  }

  static void resetUserAnswers() {
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      BlocProvider.of<QandaCubit>(appContext).resetUserQandA();
    }
  }

  static QuizQuestion? getQuestionById(int id) {
    QuizQuestion? toReturnQuestion;
    BuildContext? appContext = AppContext.getAppContext();

    if (appContext != null) {
      final FetchedQuestionsState fetchedQuestionsState =
          BlocProvider.of<FetchedQuestionsCubit>(appContext).state;
      if (fetchedQuestionsState is FetchedQuestions) {
        for (final QuizQuestion singleQuestion
            in fetchedQuestionsState.totalQuizQuestions) {
          if (singleQuestion.id == id) {
            toReturnQuestion = singleQuestion;
          }
        }
      }
    }
    return toReturnQuestion;
  }
}
