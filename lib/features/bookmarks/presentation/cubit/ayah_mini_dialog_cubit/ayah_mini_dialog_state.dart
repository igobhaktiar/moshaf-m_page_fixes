part of 'ayah_mini_dialog_cubit.dart';

sealed class AyahMiniDialogState extends Equatable {
  const AyahMiniDialogState();

  @override
  List<Object> get props => [];
}

final class AyahMiniDialogInitial extends AyahMiniDialogState {}

final class AyahMiniDialogOpened extends AyahMiniDialogState {
  const AyahMiniDialogOpened({
    required this.ayah,
    this.highlight,
    this.scrollOffset,
  });

  final AyahModel ayah;
  final AyahSegsModel? highlight;
  final Offset? scrollOffset;
}
