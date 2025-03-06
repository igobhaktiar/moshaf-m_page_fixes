import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/number_to_arabic.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/widgets/playlist_dialog.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../cubit/playlist_surah_cubit.dart';
import '../screens/playlist_surah.dart';
import 'playlist_control_buttons.dart';

class PlaylistTileTest extends StatefulWidget {
  final bool shrinkSize;

  const PlaylistTileTest({super.key, this.shrinkSize = false});

  @override
  State<PlaylistTileTest> createState() => _PlaylistTileTestState();
}

class _PlaylistTileTestState extends State<PlaylistTileTest> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistCubit>().fetchPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state is PlaylistLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PlaylistLoaded) {
          return ListView.builder(
            itemCount: state.playlists.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final playlist = state.playlists[index];
              final playlistId = playlist['playlist_id'];

              WidgetsBinding.instance.addPostFrameCallback((_) {
                context
                    .read<PlaylistSurahCubit>()
                    .fetchSurahsInPlaylist(playlistId);
              });

              return Dismissible(
                key: ValueKey(playlistId),
                background: _buildEditBackground(context),
                secondaryBackground: _buildDeleteBackground(context),
                confirmDismiss: (direction) =>
                    _handleDismiss(context, direction, playlistId),
                child: _buildPlaylistTile(context, playlist, playlistId, index),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildPlaylistTile(
    BuildContext context,
    Map<String, dynamic> playlist,
    int playlistId,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: widget.shrinkSize
            ? null
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        title: Text(
          playlist['playlist_name'] ?? '',
          style: context.textTheme.bodyMedium!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          pushSlide(
            context,
            screen: PlaylistSurah(
              playlistName: playlist['playlist_name'],
              playlistId: playlistId,
            ),
          );
        },
        trailing: BlocBuilder<PlaylistSurahCubit, PlaylistSurahState>(
          builder: (context, surahState) {
            if (surahState is PlaylistSurahLoaded &&
                surahState.playlistId == playlistId) {
              final surahs = surahState.surahs;

              return PlaylistControlButtons(
                player: context.watch<PlaylistSurahListenCubit>().player,
                surahs: surahs,
                initialIndex: 0,
                playlistId: playlistId,
                disable: true,
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEditBackground(BuildContext context) {
    return Container(
      alignment: context.translate.localeName == "ar"
          ? Alignment.centerRight
          : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.blue,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  Widget _buildDeleteBackground(BuildContext context) {
    return Container(
      alignment: context.translate.localeName == "ar"
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool?> _handleDismiss(
      BuildContext context, DismissDirection direction, int playlistId) async {
    if (direction == DismissDirection.startToEnd) {
      editPlaylist(context: context, playlistId: playlistId);
      return false;
    } else if (direction == DismissDirection.endToStart) {
      bool? shouldDelete = await showDeleteConfirmationDialog(
        context: context,
        text: 'Playlist',
        onConfirmed: () {
          context.read<PlaylistCubit>().deletePlaylist(playlistId);
        },
      );
      return shouldDelete ?? false;
    }
    return false;
  }
}
