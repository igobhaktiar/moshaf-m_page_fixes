part of 'quran_details_cubit.dart';

sealed class QuranDetailsState extends Equatable {
  final Color currentQuranTextColor;
  final int currentTextShadeInDarkValue;

  const QuranDetailsState({
    required this.currentQuranTextColor,
    required this.currentTextShadeInDarkValue,
  });

  @override
  List<Object> get props => [
        currentQuranTextColor,
        currentTextShadeInDarkValue,
      ];
}

class AppQuranDetailsState extends QuranDetailsState {
  @override
  // ignore: overridden_fields
  final Color currentQuranTextColor;
  @override
  // ignore: overridden_fields
  final int currentTextShadeInDarkValue;
  const AppQuranDetailsState({
    required this.currentQuranTextColor,
    required this.currentTextShadeInDarkValue,
  }) : super(
          currentQuranTextColor: currentQuranTextColor,
          currentTextShadeInDarkValue: currentTextShadeInDarkValue,
        );
}
