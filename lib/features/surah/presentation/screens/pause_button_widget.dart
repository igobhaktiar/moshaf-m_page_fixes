import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/surah_listen_cubit.dart';

class PauseButtonWidget extends StatelessWidget {
  const PauseButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurahListenCubit, SurahListenState>(
      builder: (context, state) {
        final cubit = context.read<SurahListenCubit>();

        // Only show pause button when audio is actively playing
        // Check if player is actually playing using the player's playing property
        if (cubit.currentSurahPlaying != null &&
            cubit.currentReciterPlaying != null &&
            cubit.player.playing) {
          return IconButton(
            icon: SvgPicture.asset(
              AppAssets.pause,
              height: 30,
              width: 30,
              fit: BoxFit.cover,
            ),
            onPressed: () => cubit.pauseSurah(),
            tooltip: 'Pause',
          );
        } else {
          // Return an empty container when not playing
          return const SizedBox.shrink();
        }
      },
    );
  }
}
