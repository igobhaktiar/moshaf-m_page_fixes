import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/widgets/playlist_control_buttons.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../core/enums/moshaf_type_enum.dart';
import '../../../../core/utils/constants.dart';
import '../../../drawer/data/data_sources/drawer_constants.dart';
import '../../data/models/playlist_surah_model.dart';

class PlaylistSurahListen extends StatefulWidget {
  final List<PlaylistSurahModel> surahs;
  final String selectedAudioPath;
  final int playlistId;

  const PlaylistSurahListen({
    super.key,
    required this.surahs,
    required this.selectedAudioPath,
    required this.playlistId,
  });

  @override
  State<PlaylistSurahListen> createState() => _PlaylistSurahListenState();
}

class _PlaylistSurahListenState extends State<PlaylistSurahListen> {
  @override
  void initState() {
    final cubit = context.read<PlaylistSurahListenCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialIndex = widget.surahs.indexWhere(
        (surah) => surah.audioPath == widget.selectedAudioPath,
      );
      if (initialIndex != -1) {
        cubit.controller?.jumpToPage(initialIndex);
      }

      cubit.prepareAndPlaySurah(widget.surahs, initialIndex, widget.playlistId);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistSurahListenCubit, PlaylistSurahListenState>(
        builder: (context, state) {
          final cubit = context.read<PlaylistSurahListenCubit>();

          LoopModeState currentLoopMode;

          if (state is PlaylistSurahListenStateUpdated) {
            currentLoopMode = state.loopMode;
          } else {
            currentLoopMode = cubit.currentLoopMode;
          }

          return PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: cubit.controller,
            itemCount: widget.surahs.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final surah = widget.surahs[index];

              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.surahBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.4),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50.0,
                    right: context.translate.localeName == "ar" ? null : 10.0,
                    left: context.translate.localeName == "ar" ? 10.0 : null,
                    child: Image.asset(
                      DrawerConstants.drawerQuranIcon,
                      height: 35,
                    ),
                  ),
                  Positioned(
                    top: 50.0,
                    left: 16.0,
                    right: 16.0,
                    child: Text(
                      '${surah.surahName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 220.0,
                    left: 16.0,
                    right: 16.0,
                    child: Text(
                      '${context.translate.localeName == "ar" ? surah.reciterArabicName : surah.reciterEnglishName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    top: 55.0,
                    left: context.translate.localeName == "ar" ? null : 10.0,
                    right: context.translate.localeName == "ar" ? 10.0 : null,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 120.0,
                    left: 16.0,
                    right: 16.0,
                    child: BlocBuilder<PlaylistSurahListenCubit,
                        PlaylistSurahListenState>(
                      builder: (context, state) {
                        Duration currentPosition = Duration.zero;
                        Duration totalDuration = Duration.zero;

                        if (state is PlaylistSurahDurationStateUpdated) {
                          currentPosition = state.currentPosition;
                          totalDuration = state.totalDuration!;
                        }

                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Column(
                            children: [
                              SfSliderTheme(
                                data: SfSliderThemeData(
                                  disabledInactiveTrackColor:
                                      AppColors.beige.withOpacity(0.5),
                                ),
                                child: SfSlider(
                                  min: 0.0,
                                  max: totalDuration.inMilliseconds > 0
                                      ? totalDuration.inMilliseconds.toDouble()
                                      : 1.0,
                                  value: currentPosition.inMilliseconds
                                      .clamp(
                                          0,
                                          totalDuration.inMilliseconds > 0
                                              ? totalDuration.inMilliseconds
                                              : 1)
                                      .toDouble(),
                                  onChanged: totalDuration.inMilliseconds > 0
                                      ? (value) {
                                          cubit.seekAudio(Duration(
                                              milliseconds: value.toInt()));
                                        }
                                      : null,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formatDuration(currentPosition),
                                      style: const TextStyle(
                                          color: AppColors.white)),
                                  Text(formatDuration(totalDuration),
                                      style: const TextStyle(
                                          color: AppColors.white)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                cubit.toggleLoopMode();
                              },
                              icon: Icon(
                                currentLoopMode == LoopModeState.one
                                    ? Icons.repeat_one
                                    : Icons.repeat,
                                color: AppColors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await cubit.previousSurah(
                                    widget.surahs, widget.playlistId);
                              },
                              icon: SvgPicture.asset(
                                AppAssets.prev,
                                height: 22,
                                color: AppColors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                cubit.seekBackward();
                              },
                              icon: const Icon(
                                Icons.replay_10_rounded,
                                color: AppColors.white,
                              ),
                            ),
                            PlaylistControlButtons(
                              player: cubit.player,
                              surahs: widget.surahs,
                              initialIndex: index,
                              playlistId: widget.playlistId,
                            ),
                            IconButton(
                              onPressed: () {
                                cubit.seekForward();
                              },
                              icon: const Icon(
                                Icons.forward_10_rounded,
                                color: AppColors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await cubit.gotoNextSurah(
                                    widget.surahs, widget.playlistId);
                              },
                              icon: SvgPicture.asset(
                                AppAssets.next,
                                color: AppColors.white,
                                height: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
