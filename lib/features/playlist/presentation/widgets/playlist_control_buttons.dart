import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';

import '../../data/models/playlist_surah_model.dart';
import '../cubit/playlist_surah_listen_cubit.dart';

class PlaylistControlButtons extends StatelessWidget {
  final int initialIndex;
  final AudioPlayer player;
  final List<PlaylistSurahModel> surahs;
  final bool disable;
  final Color buttonColor;
  final int playlistId;

  const PlaylistControlButtons({
    super.key,
    required this.initialIndex,
    required this.player,
    required this.surahs,
    required this.playlistId,
    this.disable = false,
    this.buttonColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistSurahListenCubit, PlaylistSurahListenState>(
      builder: (context, state) {
        final cubit = context.read<PlaylistSurahListenCubit>();
        final isActive = cubit.currentPlaylistId == playlistId;

        return StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            final isCurrentSurahPlaying =
                cubit.currentSurahIndex == initialIndex &&
                    isActive &&
                    playing == true;

            if (cubit.currentSurahIndex == initialIndex &&
                processingState == ProcessingState.loading) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: buttonColor,
                ),
              );
            } else if (!isCurrentSurahPlaying ||
                processingState == ProcessingState.idle) {
              return IconButton(
                icon: SvgPicture.asset(
                  AppAssets.play,
                  height: 25,
                  color: buttonColor,
                ),
                onPressed: disable
                    ? () async {
                        await cubit.prepareAndPlaySurah(
                            surahs, initialIndex, playlistId);
                      }
                    : () async {
                        if (processingState == ProcessingState.idle) {
                          await cubit.prepareAndPlaySurah(
                              surahs, initialIndex, playlistId);
                        } else {
                          player.play();
                        }
                      },
              );
            } else if (!isCurrentSurahPlaying ||
                processingState != ProcessingState.completed) {
              return disable
                  ? IconButton(
                      icon: SvgPicture.asset(
                        AppAssets.pause,
                        height: 25,
                        color: buttonColor,
                      ),
                      onPressed: () {
                        cubit.forceStopPlayer();
                      },
                    )
                  : Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            AppAssets.pause,
                            height: 25,
                            color: buttonColor,
                          ),
                          onPressed: () {
                            cubit.pauseSurah();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.stop,
                            size: 30,
                            color: buttonColor,
                          ),
                          onPressed: () async {
                            await cubit.forceStopPlayer();
                          },
                        ),
                      ],
                    );
            } else {
              return IconButton(
                icon: Icon(
                  Icons.replay,
                  color: buttonColor,
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
