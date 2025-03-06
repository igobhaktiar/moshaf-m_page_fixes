import 'package:equatable/equatable.dart';

import '../../data/models/surah_model.dart';

sealed class SurahState extends Equatable {
  const SurahState();

  @override
  List<Object> get props => [];
}

class SurahInitial extends SurahState {}

class SurahError extends SurahState {
  final String msg;

  const SurahError({this.msg = ''});

  @override
  List<Object> get props => [msg];
}

class ChangeCurrentReciterState extends SurahState {
  final SurahModel currentSurah;
  const ChangeCurrentReciterState(this.currentSurah);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeCurrentReciterState &&
        other.currentSurah == currentSurah;
  }

  @override
  int get hashCode => currentSurah.hashCode;
}

class SurahAudioDownloadSuccess extends SurahState {
  final String msg;

  const SurahAudioDownloadSuccess({required this.msg});

  @override
  List<Object> get props => [msg];
}

class SurahAudioDownloading extends SurahState {
  final String value;
  const SurahAudioDownloading({this.value = '0%'});

  @override
  List<Object> get props => [value];
}

class SurahAudioDownloadError extends SurahState {
  final String msg;

  const SurahAudioDownloadError({required this.msg});

  @override
  List<Object> get props => [msg];
}

class DownloadedFilesUpdated extends SurahState {
  final Set<String> downloadedSurahIds;

  const DownloadedFilesUpdated({required this.downloadedSurahIds});

  @override
  List<Object> get props => [downloadedSurahIds];
}

class PlaylistSuccess extends SurahState {
  final String message;

  const PlaylistSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PlaylistError extends SurahState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object> get props => [message];
}
