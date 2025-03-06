part of 'playlist_cubit.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object> get props => [];
}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<Map<String, dynamic>> playlists;

  const PlaylistLoaded(this.playlists);

  @override
  List<Object> get props => [playlists];
}

class PlaylistLoadError extends PlaylistState {
  final String message;

  const PlaylistLoadError(this.message);

  @override
  List<Object> get props => [message];
}
