import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_service.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/screens/section_repeat_enum.dart';

import '../../../../core/utils/assets_manager.dart';
import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;
  final bool removeRepeatButton;
  final bool? listenFromThisAyah;
  final AyahModel? ayah;
  final bool isFromAppBar;

  const ControlButtons(
    this.player, {
    Key? key,
    this.removeRepeatButton = false,
    this.isFromAppBar = false,
    this.listenFromThisAyah,
    this.ayah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        BlocBuilder<ListeningCubit, ListeningState>(
      builder: (context, state) {
        final cubit = context.read<ListeningCubit>();
        return StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (isFromAppBar) {
              if (playing == true) {
                return Row(
                  children: [
                    IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.pause,
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                          color: context.theme.brightness == Brightness.dark
                              ? Colors.white
                              : null,
                        ),
                        onPressed: () async {
                          await player.pause();
                        }),
                  ],
                );
              } else {
                return const SizedBox();
              }
            } else {
              if (processingState == ProcessingState.loading ||
                  cubit.isDownloading) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 30.0,
                  height: 30.0,
                  child: const CircularProgressIndicator(
                    strokeWidth: 5,
                  ),
                );
              } else if (playing != true ||
                  processingState == ProcessingState.idle) {
                return IconButton(
                  icon: SvgPicture.asset(
                    AppAssets.play,
                    height: 30,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  ),
                  onPressed: () async {
                    if (removeRepeatButton &&
                        listenFromThisAyah != null &&
                        ayah != null) {
                      if (listenFromThisAyah!) {
                        context
                            .read<ListeningCubit>()
                            .startListenFromAyah(ayah: ayah!);
                      } else {
                        context
                            .read<ListeningCubit>()
                            .listenToAyah(ayah: ayah!);
                      }
                    } else {
                      if (processingState == ProcessingState.idle) {
                        context.read<ListeningCubit>().listenToCurrentPage(
                          repeatType: SectionRepeatType.continuous,
                          ayatForCustomRange: [
                            BottomWidgetService.ayahId,
                          ],
                        );
                        // context.read<ListeningCubit>().showChooseRepeat();
                      } else {
                        player.play();
                      }
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
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : null,
                      ),
                      onPressed: () async => await player.pause(),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      child: Icon(
                        Icons.stop,
                        size: 35,
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.activeButtonColor,
                      ),
                      onTap: () async {
                        context.read<ListeningCubit>().forceStopPlayer();
                      },
                    ),
                  ],
                );
              } else {
                return IconButton(
                  icon: Icon(
                    Icons.replay,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.activeButtonColor,
                  ),
                  iconSize: 40.0,
                  onPressed: () => player.setAudioSource(player.audioSource!),
                );
              }
            }
          },
        );
      },
    );
  }
}
