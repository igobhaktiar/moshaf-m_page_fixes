part of 'playlist_surah_cubit.dart';

abstract class PlaylistSurahState extends Equatable {
  const PlaylistSurahState();

  @override
  List<Object> get props => [];
}

class PlaylistSurahInitial extends PlaylistSurahState {}

class PlaylistSurahLoading extends PlaylistSurahState {}

class PlaylistSurahLoaded extends PlaylistSurahState {
  final int playlistId;
  final List<PlaylistSurahModel> surahs;

  const PlaylistSurahLoaded(this.playlistId, this.surahs);

  @override
  List<Object> get props => [playlistId, surahs];
}

class PlaylistSurahError extends PlaylistSurahState {
  final String message;

  const PlaylistSurahError(this.message);

  @override
  List<Object> get props => [message];
}

class PlaylistSurahDelete extends PlaylistSurahState {
  final String message;

  const PlaylistSurahDelete(this.message);

  @override
  List<Object> get props => [message];
}
