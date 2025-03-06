part of 'share_cubit.dart';

abstract class ShareState extends Equatable {
  const ShareState();

  @override
  List<Object> get props => [];
}

class ShareInitial extends ShareState {}

class ShareLoaded extends ShareState {
  final List<ShareAyahModel> selectedAyahs;

  const ShareLoaded(this.selectedAyahs);

  @override
  List<Object> get props => [selectedAyahs];
}

class ShareError extends ShareState {
  final String message;

  const ShareError(this.message);

  @override
  List<Object> get props => [message];
}
