import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/number_to_arabic.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/screens/playlist_surah_listen.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/widgets/playlist_control_buttons.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/constants.dart';
import '../../../surah/presentation/cubit/surah_listen_cubit.dart';
import '../cubit/playlist_surah_listen_cubit.dart';
import '../widgets/playlist_dialog.dart';

class PlaylistSurah extends StatefulWidget {
  final String playlistName;
  final int playlistId;

  const PlaylistSurah({
    super.key,
    required this.playlistName,
    required this.playlistId,
  });

  @override
  State<PlaylistSurah> createState() => _PlaylistSurahState();
}

class _PlaylistSurahState extends State<PlaylistSurah> {
  @override
  void initState() {
    context.read<SurahListenCubit>().forceStopPlayer();
    context.read<PlaylistSurahCubit>().fetchSurahsInPlaylist(widget.playlistId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName),
        leading: AppConstants.customBackButton(context),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: BlocConsumer<PlaylistSurahCubit, PlaylistSurahState>(
          listener: (context, state) {
            if (state is PlaylistSurahDelete) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.translate.deletedSuccessfully)),
              );
            }
          },
          builder: (context, state) {
            if (state is PlaylistSurahLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PlaylistSurahLoaded) {
              final surahs = state.surahs;

              if (surahs.isEmpty) {
                return Center(child: Text(context.translate.noSurahsFound));
              }

              return ListView.separated(
                itemCount: surahs.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return Dismissible(
                    key: ValueKey(surah.audioPath),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: context.translate.localeName == "ar"
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      final shouldDelete = await showDeleteConfirmationDialog(
                        context: context,
                        onConfirmed: () {},
                      );
                      return shouldDelete ?? false;
                    },
                    onDismissed: (direction) {
                      context.read<PlaylistSurahCubit>().deleteSurahsInPlaylist(
                          surah.audioPath!, widget.playlistId);
                    },
                    child: ListTile(
                      onTap: () {
                        pushSlide(
                          context,
                          screen: PlaylistSurahListen(
                            surahs: surahs,
                            selectedAudioPath: surah.audioPath!,
                            playlistId: widget.playlistId,
                          ),
                        );
                      },
                      dense: true,
                      title: Text(
                        '${surah.surahName} (${context.translate.localeName == "ar" ? surah.reciterArabicName : surah.reciterEnglishName})',
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: CircleAvatar(
                        radius: 15,
                        backgroundColor: context.theme.cardColor,
                        child: Text(
                          context.translate.localeName == "ar"
                              ? convertToArabicNumber((index + 1).toString())
                              : (index + 1).toString(),
                          style: context.textTheme.bodyMedium!.copyWith(
                              color: context.theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      trailing: PlaylistControlButtons(
                        player:
                            context.watch<PlaylistSurahListenCubit>().player,
                        surahs: surahs,
                        initialIndex: index,
                        playlistId: widget.playlistId,
                        disable: true,
                        buttonColor: AppColors.beige,
                      ),
                    ),
                  );
                },
              );
            } else if (state is PlaylistSurahError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No Surahs found.'));
          },
        ),
      ),
    );
  }
}
