part of 'fetched_questions_cubit.dart';

sealed class FetchedQuestionsState extends Equatable {
  const FetchedQuestionsState();

  @override
  List<Object> get props => [];
}

final class FetchedQuestionsInitial extends FetchedQuestionsState {}

class FetchedQuestionsLoading extends FetchedQuestionsState {}

class FetchedQuestions extends FetchedQuestionsState {
  final List<QuizQuestion> totalQuizQuestions;
  const FetchedQuestions({
    required this.totalQuizQuestions,
  });
}
