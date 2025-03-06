part of 'playlist_surah_listen_cubit.dart';

sealed class PlaylistSurahListenState extends Equatable {
  const PlaylistSurahListenState();

  @override
  List<Object> get props => [];
}

class PlaylistSurahListenInitial extends PlaylistSurahListenState {}

class PlaylistPlayerStopped extends PlaylistSurahListenState {}

class PlaylistPlayerPaused extends PlaylistSurahListenState {}

class PlaylistPlayerStart extends PlaylistSurahListenState {}

class PlaylistPlayerAlreadyPlaying extends PlaylistSurahListenState {}

class PlaylistSurahListenError extends PlaylistSurahListenState {
  final String msg;

  const PlaylistSurahListenError({this.msg = ''});

  @override
  List<Object> get props => [msg];
}

class ChangeEnablePlayInBackgroundState extends PlaylistSurahListenState {
  final bool enabled;
  const ChangeEnablePlayInBackgroundState({this.enabled = true});

  @override
  List<Object> get props => [enabled];
}

class DownloadedFilesUpdated extends PlaylistSurahListenState {
  final Set<String> downloadedSurahIds;

  const DownloadedFilesUpdated({required this.downloadedSurahIds});

  @override
  List<Object> get props => [downloadedSurahIds];
}

class PlaylistSurahListenStateUpdated extends PlaylistSurahListenState {
  final LoopModeState loopMode;

  const PlaylistSurahListenStateUpdated({required this.loopMode});

  @override
  List<Object> get props => [loopMode];
}

class PlaylistSurahDurationStateUpdated extends PlaylistSurahListenState {
  final Duration currentPosition;
  final Duration? totalDuration;

  const PlaylistSurahDurationStateUpdated({
    required this.currentPosition,
    required this.totalDuration,
  });

  @override
  List<Object> get props => [currentPosition, totalDuration ?? Duration.zero];
}
