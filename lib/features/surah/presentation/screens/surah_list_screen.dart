import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/utils/number_to_arabic.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/screens/soorah_reciter_list_screen.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/screens/surah_player_screen.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/assets_manager.dart';
import '../../../playlist/presentation/cubit/playlist_surah_listen_cubit.dart';
import '../../../playlist/presentation/screens/playlist.dart';
import '../../../playlist/presentation/widgets/playlist_dialog.dart';
import '../../data/models/surah_model.dart';
import '../cubit/surah_cubit.dart';
import '../cubit/surah_listen_cubit.dart';
import '../cubit/surah_state.dart';

class SurahListScreen extends StatefulWidget {
  final String name;
  final String reciterArabicName;
  final String reciterEnglishName;
  final String currentReciter;
  final String image;

  const SurahListScreen({
    super.key,
    required this.name,
    required this.reciterArabicName,
    required this.reciterEnglishName,
    required this.image,
    required this.currentReciter,
  });

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  @override
  void initState() {
    context.read<SurahCubit>().init(widget.currentReciter);
    context.read<SurahListenCubit>().init(widget.currentReciter);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.the_surah),
        leading: AppConstants.customBackButton(context, onPressed: () {
//reciterScreen
          pushSlide(context, screen: const SoorahRecitersListScreen());
        }),
        actions: [
          IconButton(
            onPressed: () {
              pushSlide(context, screen: const Playlist());
            },
            icon: const Icon(Icons.playlist_add_check),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ListTile(
            dense: true,
            title: Text(
              widget.name,
              style: context.textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(widget.image),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocConsumer<SurahCubit, SurahState>(
              listener: (context, state) {
                if (state is SurahAudioDownloadError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(context.translate.audioNotAvailable)),
                  );
                }
                if (state is PlaylistSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(context.translate.surahAddedToPlaylist)),
                  );
                }
              },
              builder: (context, state) {
                var cubit = SurahCubit.get(context);

                return ListView.separated(
                  itemCount: cubit.surahs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final surah = cubit.surahs[index];
                    return _buildSurahOptions(surah, cubit);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahOptions(SurahModel surah, SurahCubit cubit) {
    final isDownloaded = cubit.isSurahDownloaded(
      widget.currentReciter,
      surah.id.toString().padLeft(3, '0'),
    );

    final isDownloading =
        cubit.downloadingSurahId == surah.id.toString().padLeft(3, '0');

    final surahCubit = context.watch<SurahListenCubit>();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            onTap: () {
              context.read<PlaylistSurahListenCubit>().forceStopPlayer();
              surahCubit.currentReciterPlaying = widget.currentReciter;
              pushSlide(
                context,
                screen: SurahPlayerScreen(
                  reciterName: widget.name,
                  currentReciter: widget.currentReciter,
                  selectedSurahId: surah.id.toString().padLeft(3, '0'),
                ),
              );
            },
            dense: true,
            title: Row(
              children: [
                Text(
                  surah.name.toString(),
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                surahCubit.isSurahCurrentlyPlaying(
                  widget.currentReciter,
                  surah.id.toString().padLeft(3, '0'),
                )
                    ? Text(
                        ' ${context.translate.nowPlaying}',
                        style: context.textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            leading: CircleAvatar(
              radius: 15,
              backgroundColor: context.theme.cardColor,
              child: Text(
                context.translate.localeName == "ar"
                    ? convertToArabicNumber(surah.id.toString())
                    : surah.id.toString(),
                style: context.textTheme.bodyMedium!.copyWith(
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<PlaylistCubit>().fetchPlaylists();
                    playlistBottomSheet(
                      context: context,
                      surahId: surah.id.toString().padLeft(3, '0'),
                      surahName: surah.name!,
                      reciterName: widget.currentReciter,
                      reciterArabicName: widget.reciterArabicName,
                      reciterEnglishName: widget.reciterEnglishName,
                    );
                  },
                  icon: const Icon(Icons.playlist_add),
                ),
                BlocBuilder<SurahListenCubit, SurahListenState>(
                  builder: (context, state) {
                    final cubit = context.read<SurahListenCubit>();
                    final surahId = surah.id.toString().padLeft(3, '0');
                    final isDownloaded =
                        cubit.isSurahDownloaded(widget.currentReciter, surahId);
                    final isThisSurahDownloading = cubit.isSurahDownloading(
                        widget.currentReciter, surahId);

                    if (isThisSurahDownloading) {
                      // Show loading indicator only for this specific surah
                      return const Padding(
                        padding: EdgeInsets.only(right: 11),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    return IconButton(
                      onPressed: isDownloaded
                          ? null
                          : () async {
                              await cubit.downloadSelectedSurah(
                                widget.currentReciter,
                                surahId,
                              );
                            },
                      icon: isDownloaded
                          ? Image.asset(
                              AppAssets.downloadCheck,
                              height: 24,
                              width: 24,
                            )
                          : const Icon(Icons.download),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        AppConstants.appDivider(
          context,
          color: context.theme.brightness == Brightness.dark
              ? AppColors.shiekhDividerDark
              : null,
        ),
      ],
    );
  }
}
