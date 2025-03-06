part of 'surah_listen_cubit.dart';

sealed class SurahListenState extends Equatable {
  const SurahListenState();

  @override
  List<Object> get props => [];
}

class SurahListenInitial extends SurahListenState {}

class SurahPlayerStopped extends SurahListenState {}

class SurahPlayerStart extends SurahListenState {}

class CheckYourNetworkConnectionState extends SurahListenState {}

class SurahListenError extends SurahListenState {
  final String msg;

  const SurahListenError({this.msg = ''});

  @override
  List<Object> get props => [msg];
}

class SurahListenAudioDownloadSuccess extends SurahListenState {
  final String msg;

  const SurahListenAudioDownloadSuccess({required this.msg});

  @override
  List<Object> get props => [msg];
}

class SurahListenAudioDownloading extends SurahListenState {
  final String value;
  const SurahListenAudioDownloading({this.value = '0%'});

  @override
  List<Object> get props => [value];
}

class SurahListenAudioDownloadError extends SurahListenState {}

class PlayerAlreadyPlaying extends SurahListenState {}

class WaitUntilDownloadFinish extends SurahListenState {}

class ChangeEnablePlayInBackgroundState extends SurahListenState {
  final bool enabled;
  const ChangeEnablePlayInBackgroundState({this.enabled = true});

  @override
  List<Object> get props => [enabled];
}

class DownloadedFilesUpdated extends SurahListenState {
  final Set<String> downloadedSurahIds;

  const DownloadedFilesUpdated({required this.downloadedSurahIds});

  @override
  List<Object> get props => [downloadedSurahIds];
}

class SurahListenStateUpdated extends SurahListenState {
  final LoopModeState loopMode;

  const SurahListenStateUpdated({required this.loopMode});

  @override
  List<Object> get props => [loopMode];
}

class SurahDurationStateUpdated extends SurahListenState {
  final Duration currentPosition;
  final Duration? totalDuration;

  const SurahDurationStateUpdated({
    required this.currentPosition,
    required this.totalDuration,
  });

  @override
  List<Object> get props => [currentPosition, totalDuration ?? Duration.zero];
}

// Add these new state classes
class SurahDownloadStarted extends SurahListenState {
  final String reciter;
  final String surahId;
  final String progress;

  const SurahDownloadStarted({
    required this.reciter,
    required this.surahId,
    required this.progress,
  });
}

class SurahDownloadProgress extends SurahListenState {
  final String reciter;
  final String surahId;
  final String progress;

  const SurahDownloadProgress({
    required this.reciter,
    required this.surahId,
    required this.progress,
  });
}

class SurahDownloadCompleted extends SurahListenState {
  final String reciter;
  final String surahId;

  const SurahDownloadCompleted({
    required this.reciter,
    required this.surahId,
  });
}

class SurahDownloadError extends SurahListenState {
  final String reciter;
  final String surahId;
  final String error;

  const SurahDownloadError({
    required this.reciter,
    required this.surahId,
    required this.error,
  });
}
