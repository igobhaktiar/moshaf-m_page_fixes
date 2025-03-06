part of 'tafseer_page_cubit.dart';

sealed class TafseerPageState extends Equatable {
  const TafseerPageState();
  @override
  List<Object> get props => [];
}

class CurrentTafseerPageLoading extends TafseerPageState {}

class CurrentTafseerPageState extends TafseerPageState {
  final int pageNumber;
  final String tafseerCode;
  final TafseerPageList currentTafseerPageList;
  const CurrentTafseerPageState({
    required this.pageNumber,
    required this.tafseerCode,
    required this.currentTafseerPageList,
  });
}
