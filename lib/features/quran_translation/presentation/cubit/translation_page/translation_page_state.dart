part of 'translation_page_cubit.dart';

sealed class TranslationPageState extends Equatable {
  const TranslationPageState();
  @override
  List<Object> get props => [];
}

class CurrentTranslationPageInitial extends TranslationPageState {}

class CurrentTranslationPageLoading extends TranslationPageState {}

class CurrentTranslationPageState extends TranslationPageState {
  final int pageNumber;
  final String languageCode;
  final TranslationPageList currentTranslationPageList;
  const CurrentTranslationPageState({
    required this.pageNumber,
    required this.languageCode,
    required this.currentTranslationPageList,
  });
}
