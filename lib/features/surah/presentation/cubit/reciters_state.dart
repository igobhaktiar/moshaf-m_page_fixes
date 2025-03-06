part of 'reciters_cubit.dart';

sealed class RecitersState extends Equatable {
  const RecitersState();

  @override
  List<Object> get props => [];
}

class RecitersInitial extends RecitersState {}

class ChangeCurrentReciterState extends RecitersState {
  final ReciterModel currentReciter;
  const ChangeCurrentReciterState(this.currentReciter);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeCurrentReciterState &&
        other.currentReciter == currentReciter;
  }

  @override
  int get hashCode => currentReciter.hashCode;
}

class RecitersAvailability extends RecitersState {
  final String msg;

  const RecitersAvailability({this.msg = ''});

  @override
  List<Object> get props => [msg];
}
