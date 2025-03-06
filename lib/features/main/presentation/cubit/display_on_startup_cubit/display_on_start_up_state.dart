// ignore_for_file: overridden_fields

part of 'display_on_start_up_cubit.dart';

sealed class DisplayOnStartUpState extends Equatable {
  final bool isPageOneSwitched;
  final bool isLastPositionSwitched;
  final bool isIndexSwitched;
  final bool isBookmarkSwitched;
  const DisplayOnStartUpState({
    required this.isPageOneSwitched,
    required this.isLastPositionSwitched,
    required this.isIndexSwitched,
    required this.isBookmarkSwitched,
  });

  @override
  List<Object> get props => [
        isPageOneSwitched,
        isLastPositionSwitched,
        isIndexSwitched,
        isBookmarkSwitched,
      ];
}

class DisplayOnStartUpStateUpdated extends DisplayOnStartUpState {
  @override
  final bool isPageOneSwitched;
  @override
  final bool isLastPositionSwitched;
  @override
  final bool isIndexSwitched;
  @override
  final bool isBookmarkSwitched;

  const DisplayOnStartUpStateUpdated({
    required this.isPageOneSwitched,
    required this.isLastPositionSwitched,
    required this.isIndexSwitched,
    required this.isBookmarkSwitched,
  }) : super(
          isPageOneSwitched: isPageOneSwitched,
          isLastPositionSwitched: isLastPositionSwitched,
          isIndexSwitched: isIndexSwitched,
          isBookmarkSwitched: isBookmarkSwitched,
        );
}
