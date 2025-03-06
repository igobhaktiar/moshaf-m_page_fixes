import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/reciters_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/screens/surah_list_screen.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../core/enums/moshaf_type_enum.dart';
import '../../../../core/utils/constants.dart';
import 'surah_control_buttons.dart';

class SurahPlayerScreen extends StatefulWidget {
  final String selectedSurahId;
  final String currentReciter;
  final String reciterName;

  const SurahPlayerScreen({
    super.key,
    required this.selectedSurahId,
    required this.currentReciter,
    required this.reciterName,
  });

  @override
  State<SurahPlayerScreen> createState() => _SurahPlayerScreenState();
}

class _SurahPlayerScreenState extends State<SurahPlayerScreen> {
  @override
  void initState() {
    final surahCubit = context.read<SurahListenCubit>();

    surahCubit.init(widget.currentReciter);
    surahCubit.currentReciterPlaying = widget.currentReciter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialIndex = surahCubit.surahs.indexWhere(
        (surah) =>
            surah.id.toString().padLeft(3, '0') == widget.selectedSurahId,
      );
      if (initialIndex != -1) {
        surahCubit.controller?.jumpToPage(initialIndex);
      }
    });

    surahCubit.prepareAndPlaySurah(
      widget.currentReciter,
      widget.selectedSurahId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: AppConstants.customBackButton(context, invertIconColors: true,
            onPressed: () {
          final recitersCubit = context.read<RecitersCubit>();

          // Find the current reciter based on widget.currentReciter (which is the reciter ID)
          final currentReciterModel = recitersCubit.recitersList.firstWhere(
            (reciter) => reciter.allowedReciters == widget.currentReciter,
            orElse: () => recitersCubit
                .recitersList.first, // Fallback to first reciter if not found
          );

          print("currentReciterModel: $currentReciterModel");

          pushSlide(context,
              screen: SurahListScreen(
                name: context.translate.localeName == AppStrings.arabicCode
                    ? currentReciterModel.nameArabic!
                    : currentReciterModel.nameEnglish!,
                currentReciter: currentReciterModel.allowedReciters ?? "",
                reciterArabicName: currentReciterModel.nameArabic!,
                reciterEnglishName: currentReciterModel.nameEnglish!,
                image: currentReciterModel.photo!,
              ));
        }),
        actions: [
          AppConstants.customHomeButton(context, onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          }),
        ],
      ),
      body: BlocConsumer<SurahListenCubit, SurahListenState>(
        listener: (context, state) {
          if (state is SurahListenAudioDownloadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.translate.audioNotAvailable)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<SurahListenCubit>();

          LoopModeState currentLoopMode;

          if (state is SurahListenStateUpdated) {
            currentLoopMode = state.loopMode;
          } else {
            currentLoopMode = cubit.currentLoopMode;
          }

          return PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: cubit.controller,
            itemCount: cubit.surahs.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final surah = cubit.surahs[index];
              final surahId = cubit.surahs[index].id.toString().padLeft(3, '0');
              final isDownloaded =
                  cubit.isSurahDownloaded(widget.currentReciter, surahId);

              return Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.surahBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient overlay
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
                    top: 55.0,
                    left: 16.0,
                    right: 16.0,
                    child: Text(
                      '${surah.name}',
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
                      widget.reciterName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Audio Slider and Start/End Time
                  Positioned(
                    bottom: 120.0,
                    left: 16.0,
                    right: 16.0,
                    child: BlocBuilder<SurahListenCubit, SurahListenState>(
                      buildWhen: (previous, current) => current
                          is SurahDurationStateUpdated, // Only rebuild for duration updates
                      builder: (context, state) {
                        Duration currentPosition = Duration.zero;
                        Duration totalDuration = Duration.zero;

                        if (state is SurahDurationStateUpdated) {
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
                  // Content
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
                              onPressed: () {
                                cubit.previousSurah(
                                    widget.currentReciter, surahId);
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
                            SurahControlButtons(
                              cubit.player,
                              currentReciter: widget.currentReciter,
                              selectedSurahId: surahId,
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
                              onPressed: () {
                                cubit.nextSurah(widget.currentReciter, surahId);
                              },
                              icon: SvgPicture.asset(
                                AppAssets.next,
                                height: 22,
                                color: AppColors.white,
                              ),
                            ),
                            DownloadButton(
                              isDownloaded: isDownloaded,
                              currentReciter: widget.currentReciter,
                              surahId: surahId,
                              cubit: cubit,
                            )
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

class DownloadButton extends StatelessWidget {
  final bool isDownloaded;
  final String currentReciter;
  final String surahId;
  final SurahListenCubit cubit;

  const DownloadButton({
    super.key,
    required this.isDownloaded,
    required this.currentReciter,
    required this.surahId,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurahListenCubit, SurahListenState>(
      buildWhen: (previous, current) =>
          current is SurahListenAudioDownloading ||
          current
              is SurahListenStateUpdated, // Using the state that's actually defined
      builder: (context, state) {
        if (state is SurahListenAudioDownloading) {
          return const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
          );
        }

        return IconButton(
          onPressed: isDownloaded
              ? null
              : () {
                  cubit.downloadSelectedSurah(currentReciter, surahId);
                },
          icon: SvgPicture.asset(
            isDownloaded
                ? AppAssets.downloadDisabled
                : AppAssets.downloadActive,
            color: isDownloaded
                ? AppColors.white.withOpacity(0.5)
                : AppColors.white,
          ),
        );
      },
    );
  }
}
