part of 'moshaf_background_color_cubit.dart';

abstract class MoshafBackgroundColorState extends Equatable {
  final Color currentColor;

  const MoshafBackgroundColorState({
    required this.currentColor,
  });

  @override
  List<Object> get props => [
        currentColor,
      ];
}

class AppMoshafBackgroundColorState extends MoshafBackgroundColorState {
  @override
  // ignore: overridden_fields
  final Color currentColor;
  const AppMoshafBackgroundColorState({
    required this.currentColor,
  }) : super(
          currentColor: currentColor,
        );
}
