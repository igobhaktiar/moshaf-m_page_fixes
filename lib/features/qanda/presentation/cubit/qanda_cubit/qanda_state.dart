part of 'qanda_cubit.dart';

sealed class QandaState extends Equatable {
  const QandaState();

  @override
  List<Object> get props => [];
}

final class QandaInitial extends QandaState {}

final class UserQandADetailsLoading extends QandaState {}

class UserQandADetailsFetched extends QandaState {
  List<UserQandA> userAnswers;

  UserQandADetailsFetched({
    required this.userAnswers,
  });
}
