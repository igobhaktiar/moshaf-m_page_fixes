import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/enums/moshaf_type_enum.dart';
import '../../data/models/playlist_surah_model.dart';

part 'playlist_surah_listen_state.dart';

class PlaylistSurahListenCubit extends Cubit<PlaylistSurahListenState> {
  late AudioPlayer player;
  PageController? controller;
  int? currentSurahIndex;
  int? currentPlaylistId;

  LoopModeState currentLoopMode = LoopModeState.none;

  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<Duration?>? durationSubscription;

  Duration currentAudioPosition = Duration.zero;
  Duration? totalAudioDuration;

  PlaylistSurahListenCubit({
    required this.player,
  }) : super(PlaylistSurahListenInitial()) {
    controller = PageController();
  }

  void initializePlayerListeners() {
    player.currentIndexStream.listen((index) {
      if (index != null && index != currentSurahIndex) {
        currentSurahIndex = index;
        updatePageController(index);
      }
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        nextSurah();
      }
    });
  }

  bool isSurahCurrentlyPlaying(int initialIndex, int playlistId) {
    return currentSurahIndex == initialIndex && currentPlaylistId == playlistId;
  }

  Future<void> prepareAndPlaySurah(
    List<PlaylistSurahModel> surahs,
    int initialIndex,
    int playlistId,
  ) async {
    if (isSurahCurrentlyPlaying(initialIndex, playlistId)) {
      emit(PlaylistPlayerAlreadyPlaying());
      return;
    }

    await forceStopPlayer();

    currentSurahIndex = initialIndex;
    currentPlaylistId = playlistId;

    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: false,
      shuffleOrder: DefaultShuffleOrder(),
      children: await Future.wait(surahs.map((surah) async {
        if (await File(surah.audioPath!).exists()) {
          return AudioSource.file(surah.audioPath!);
        } else if (surah.audioUrl != null) {
          return AudioSource.uri(Uri.parse(surah.audioUrl!));
        } else {
          emit(const PlaylistSurahListenError(
              msg: 'Surah audio file or URL not found.'));
          throw Exception('Surah audio file or URL not found.');
        }
      }).toList()),
    );

    try {
      await player.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      initializePlayerListeners();

      emit(PlaylistPlayerStart());
      player.play();
      _listenToAudioPositionAndDuration();
    } catch (e) {
      emit(PlaylistSurahListenError(msg: 'Failed to play surah: $e'));
    }
  }

  void _listenToAudioPositionAndDuration() {
    positionSubscription = player.positionStream.listen((position) {
      if (currentPlaylistId != null) {
        currentAudioPosition = position;
        emit(PlaylistSurahDurationStateUpdated(
          currentPosition: currentAudioPosition,
          totalDuration: totalAudioDuration,
        ));
      }
    });

    durationSubscription = player.durationStream.listen((duration) {
      totalAudioDuration = duration;
      if (currentPlaylistId != null) {
        emit(PlaylistSurahDurationStateUpdated(
          currentPosition: currentAudioPosition,
          totalDuration: totalAudioDuration,
        ));
      }
    });
  }

  void seekAudio(Duration position) {
    player.seek(position);
    emit(PlaylistSurahDurationStateUpdated(
      currentPosition: position,
      totalDuration: totalAudioDuration,
    ));
  }

  Future<void> forceStopPlayer() async {
    await player.stop();
    await player.dispose();
    currentPlaylistId = null;
    currentSurahIndex = null;
    player = AudioPlayer();
    emit(PlaylistPlayerStopped());
  }

  Future<void> pauseSurah() async {
    await player.pause();
    emit(PlaylistPlayerPaused());
  }

  void toggleLoopMode() {
    switch (currentLoopMode) {
      case LoopModeState.none:
        currentLoopMode = LoopModeState.one;
        player.setLoopMode(LoopMode.one);
        break;
      case LoopModeState.one:
        currentLoopMode = LoopModeState.none;
        player.setLoopMode(LoopMode.off);
        break;
    }
    emit(PlaylistSurahListenStateUpdated(loopMode: currentLoopMode));
  }

  void updatePageController(int index) {
    if (controller != null && controller!.hasClients) {
      controller!.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> previousSurah(
    List<PlaylistSurahModel> surahs,
    int playlistId,
  ) async {
    final currentPage = controller?.page?.round() ?? 0;
    if (currentPage <= 0) {
      return;
    }

    await forceStopPlayer();

    try {
      await controller?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      final previousIndex = currentPage - 1;

      await prepareAndPlaySurah(surahs, previousIndex, playlistId);

      emit(PlaylistPlayerStart());
    } catch (e) {
      emit(PlaylistSurahListenError(msg: 'Failed to play previous surah: $e'));
    }
  }

  Future<void> gotoNextSurah(
    List<PlaylistSurahModel> surahs,
    int playlistId,
  ) async {
    final currentPage = controller?.page?.round() ?? 0;
    if (currentPage >= surahs.length - 1) {
      return;
    }

    await forceStopPlayer();

    try {
      await controller?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      final nextIndex = currentPage + 1;

      await prepareAndPlaySurah(surahs, nextIndex, playlistId);

      emit(PlaylistPlayerStart());
    } catch (e) {
      emit(PlaylistSurahListenError(msg: 'Failed to play next surah: $e'));
    }
  }

  Future<void> nextSurah() async {
    if (currentSurahIndex == null) return;

    final nextIndex = currentSurahIndex! + 1;

    if (nextIndex < (player.sequence?.length ?? 0)) {
      controller?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      player.seek(Duration.zero, index: nextIndex);
    } else {
      await forceStopPlayer();
    }
  }

  void seekForward() {
    final currentPos = player.position;
    final maxDuration = player.duration ?? Duration.zero;
    final newPosition = currentPos + const Duration(seconds: 10);

    final seekPosition = newPosition < maxDuration ? newPosition : maxDuration;

    player.seek(seekPosition);
    emit(PlaylistSurahDurationStateUpdated(
      currentPosition: seekPosition,
      totalDuration: maxDuration,
    ));
  }

  void seekBackward() {
    final currentPos = player.position;
    final newPosition = currentPos - const Duration(seconds: 10);

    final seekPosition =
        newPosition > Duration.zero ? newPosition : Duration.zero;

    player.seek(seekPosition);
    emit(PlaylistSurahDurationStateUpdated(
      currentPosition: seekPosition,
      totalDuration: player.duration ?? Duration.zero,
    ));
  }

  @override
  Future<void> close() {
    positionSubscription?.cancel();
    durationSubscription?.cancel();
    controller?.dispose();
    return super.close();
  }
}
