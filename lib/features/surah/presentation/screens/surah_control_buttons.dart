import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';

import '../../../../core/utils/assets_manager.dart';
import '../cubit/surah_listen_cubit.dart';

/// Displays the play/pause button and volume/speed sliders.
class SurahControlButtons extends StatelessWidget {
  final AudioPlayer player;
  final String selectedSurahId;
  final String currentReciter;

  const SurahControlButtons(this.player,
      {Key? key, required this.selectedSurahId, required this.currentReciter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurahListenCubit, SurahListenState>(
      builder: (context, state) {
        final cubit = context.read<SurahListenCubit>();

        return StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 30.0,
                height: 30.0,
                child: const CircularProgressIndicator(
                  strokeWidth: 5,
                  color: AppColors.white,
                ),
              );
            } else if (playing != true ||
                processingState == ProcessingState.idle) {
              return IconButton(
                icon: SvgPicture.asset(
                  AppAssets.play,
                  height: 25,
                  color: AppColors.white,
                ),
                onPressed: () async {
                  if (processingState == ProcessingState.idle) {
                    await cubit.prepareAndPlaySurah(
                      currentReciter,
                      selectedSurahId,
                    );
                  } else {
                    player.play();
                  }
                },
              );
            } else if (processingState != ProcessingState.completed) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      AppAssets.pause,
                      height: 25,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      cubit.pauseSurah();
                    },
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    child: const Icon(
                      Icons.stop,
                      size: 30,
                      color: AppColors.white,
                    ),
                    onTap: () async {
                      await cubit.forceStopPlayer();
                    },
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: const Icon(
                  Icons.replay,
                  color: AppColors.white,
                ),
                iconSize: 35,
                onPressed: () => player.setAudioSource(player.audioSource!),
              );
            }
          },
        );
      },
    );
  }
}
