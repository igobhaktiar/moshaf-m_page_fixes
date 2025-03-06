part of 'ayat_menu_control_cubit.dart';

abstract class AyatMenuControlState extends Equatable {
  final AyatMenu selectedMenu;

  const AyatMenuControlState({
    required this.selectedMenu,
  });

  @override
  List<Object> get props => [
        selectedMenu,
      ];
}

class AppAyatMenuControlState extends AyatMenuControlState {
  @override
  // ignore: overridden_fields
  final AyatMenu selectedMenu;
  const AppAyatMenuControlState({
    required this.selectedMenu,
  }) : super(
          selectedMenu: selectedMenu,
        );
}
