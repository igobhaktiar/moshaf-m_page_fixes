import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/features/listening/presentation/screens/control_buttons.dart';

import '../cubit/listening_cubit.dart';

class MediaPlayerControl extends StatefulWidget {
  const MediaPlayerControl({super.key});

  @override
  State<MediaPlayerControl> createState() => _MediaPlayerControlState();
}

class _MediaPlayerControlState extends State<MediaPlayerControl> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 15),
                //todo: forward icon
                StreamBuilder<int?>(
                    stream: context
                        .read<ListeningCubit>()
                        .player
                        .currentIndexStream,
                    builder: (context, snapshot) {
                      var currentIndex = snapshot.data;
                      bool hasNext = false;
                      print("currentIndex: $currentIndex");
                      if (currentIndex != null) {
                        hasNext = context.read<ListeningCubit>().player.hasNext;
                      }
                      return Opacity(
                        opacity: hasNext ? 1.0 : 0.5,
                        child: IconButton(
                            onPressed: () async {
                              await context
                                  .read<ListeningCubit>()
                                  .player
                                  .seekToNext();
                            },
                            icon: SvgPicture.asset(
                              AppAssets.next,
                              height: 25,
                              color: context.theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : null,
                            )),
                      );
                    }),
                //todo: play icon
                ControlButtons(context.read<ListeningCubit>().player),
                // todo: previous icon
                StreamBuilder<int?>(
                    stream: context
                        .read<ListeningCubit>()
                        .player
                        .currentIndexStream,
                    builder: (context, snapshot) {
                      var currentIndex = snapshot.data;
                      bool hasPrevious = false;
                      if (currentIndex != null) {
                        hasPrevious =
                            context.read<ListeningCubit>().player.hasPrevious;
                      }
                      return Opacity(
                        opacity: hasPrevious ? 1.0 : 0.5,
                        child: IconButton(
                            onPressed: () async {
                              print("hasPrevious: $hasPrevious");
                              await context
                                  .read<ListeningCubit>()
                                  .player
                                  .seekToPrevious();
                            },
                            icon: SvgPicture.asset(
                              AppAssets.prev,
                              height: 25,
                              color: context.theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : null,
                            )),
                      );
                    }),
                //todo: repeat icon
                IconButton(
                    onPressed: () async {
                      setState(() {
                        ListeningCubit.get(context).showChooseRepeat();
                      });
                    },
                    icon: SvgPicture.asset(
                      AppAssets.repeat,
                      height: 17,
                      color: context.theme.brightness == Brightness.dark
                          ? Colors.white
                          : null,
                    )),
              ],
            ),
          ),
        ), //todo: slider and timeStamps here
        SizedBox(
          height: 37,
          child: StreamBuilder<Duration>(
            stream: context.read<ListeningCubit>().player.positionStream,
            builder: (context, snapshot) {
              Duration? currentPosition = snapshot.data;
              Duration? totalDuration =
                  context.read<ListeningCubit>().player.duration;

              if (currentPosition != null && totalDuration != null) {
                double currentPositionInMilliseconds =
                    currentPosition.inMilliseconds.toDouble();
                double totalDurationInMilliseconds =
                    totalDuration.inMilliseconds.toDouble();

                currentPositionInMilliseconds = currentPositionInMilliseconds
                    .clamp(0.0, totalDurationInMilliseconds);

                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Slider(
                        min: 0.0,
                        max: totalDurationInMilliseconds,
                        value: currentPositionInMilliseconds,
                        onChanged: (seekToValue) {
                          context.read<ListeningCubit>().player.seek(
                                Duration(milliseconds: seekToValue.round()),
                              );
                        },
                        label:
                            "${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}",
                      ),
                      Positioned(
                        child: Container(
                          width: context.width,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}",
                                style: context.textTheme.bodyMedium!.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${totalDuration.inMinutes}:${(totalDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                                style: context.textTheme.bodyMedium!.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }
}
