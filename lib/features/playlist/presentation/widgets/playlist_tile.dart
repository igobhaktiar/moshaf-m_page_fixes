import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/core/utils/number_to_arabic.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/cubit/playlist_surah_listen_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/widgets/playlist_dialog.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../screens/playlist_surah.dart';

class PlaylistTile extends StatefulWidget {
  final bool shrinkSize;

  const PlaylistTile({super.key, this.shrinkSize = false});

  @override
  State<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
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
          if (state.playlists.isEmpty && widget.shrinkSize == false) {
            return Center(child: Text(context.translate.noPlaylistsFound));
          }

          return BlocBuilder<PlaylistSurahListenCubit,
              PlaylistSurahListenState>(
            builder: (context, listenState) {
              final playingPlaylistId =
                  context.watch<PlaylistSurahListenCubit>().currentPlaylistId;

              return SizedBox(
                height: widget.shrinkSize && state.playlists.isNotEmpty
                    ? context.height * 0.17
                    : 0,
                child: ListView.builder(
                  itemCount: state.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = state.playlists[index];
                    final isPlaying =
                        playlist['playlist_id'] == playingPlaylistId;

                    return Dismissible(
                      key: ValueKey(playlist['playlist_id']),
                      background: Container(
                        alignment: context.translate.localeName == "ar"
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.blue,
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: context.translate.localeName == "ar"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          editPlaylist(
                            context: context,
                            playlistId: playlist['playlist_id'],
                          );
                          return false;
                        } else if (direction == DismissDirection.endToStart) {
                          bool? shouldDelete =
                              await showDeleteConfirmationDialog(
                            context: context,
                            text: 'Playlist',
                            onConfirmed: () {
                              context
                                  .read<PlaylistCubit>()
                                  .deletePlaylist(playlist['playlist_id']);
                            },
                          );
                          return shouldDelete ?? false;
                        }
                        return false;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.beige,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: widget.shrinkSize
                              ? null
                              : const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 15,
                            backgroundColor: context.theme.cardColor,
                            child: Text(
                              context.translate.localeName == "ar"
                                  ? convertToArabicNumber(
                                      (index + 1).toString())
                                  : (index + 1).toString(),
                              style: context.textTheme.bodyMedium!.copyWith(
                                  color: context.theme.brightness ==
                                          Brightness.dark
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
                                playlistId: playlist['playlist_id'],
                              ),
                            );
                          },
                          trailing: isPlaying
                              ? Text(
                                  context.translate.nowPlaying,
                                  style: context.textTheme.bodySmall!.copyWith(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
