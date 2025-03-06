import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/surah_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../config/themes/theme_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../cubit/playlist_cubit.dart';

Future<void> createPlaylist({required BuildContext context}) async {
  TextEditingController controller = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.translate.createNewPlaylist),
        content: Container(
          margin: const EdgeInsets.all(5),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: context.isDarkMode
                      ? Colors.white
                      : AppColors.inactiveColor,
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: context.translate.playlistName,
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(context.translate.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final playlistName = controller.text.trim();
              if (playlistName.isNotEmpty) {
                final playlistCubit = context.read<PlaylistCubit>();
                await playlistCubit.insertPlaylist(playlistName);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.translate.playlistNameCannotBeEmpty),
                  ),
                );
              }
            },
            child: Text(context.translate.submit),
          ),
        ],
      );
    },
  );
}

Future<void> editPlaylist({
  required BuildContext context,
  required int playlistId,
}) async {
  TextEditingController controller = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.translate.editPlaylist),
        content: Container(
          margin: const EdgeInsets.all(5),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: context.isDarkMode
                      ? Colors.white
                      : AppColors.inactiveColor,
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: context.translate.newPlaylistName,
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(context.translate.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final playlistName = controller.text.trim();
              if (playlistName.isNotEmpty) {
                final playlistCubit = context.read<PlaylistCubit>();
                await playlistCubit.editPlaylist(playlistId, playlistName);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.translate.playlistNameCannotBeEmpty),
                  ),
                );
              }
            },
            child: Text(context.translate.submit),
          ),
        ],
      );
    },
  );
}

Future<void> playlistBottomSheet({
  required BuildContext context,
  required String surahId,
  required String surahName,
  required String reciterName,
  required String reciterArabicName,
  required String reciterEnglishName,
}) async {
  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.translate.allPlaylists,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        createPlaylist(context: context);
                      },
                      child: Text(
                        context.translate.addPlaylist,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state is PlaylistLoaded)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = state.playlists[index];
                      return ListTile(
                        title: Text(playlist['playlist_name'] ?? ''),
                        onTap: () async {
                          Navigator.pop(context);
                          context.read<SurahCubit>().insertSurahInPlaylist(
                                playlistId: playlist['playlist_id'],
                                surahId: surahId,
                                surahName: surahName,
                                reciterName: reciterName,
                                reciterArabicName: reciterArabicName,
                                reciterEnglishName: reciterEnglishName,
                              );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required Function()? onConfirmed,
  String text = 'Surah',
}) async {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${context.translate.delete} $text'),
      content:
          Text('${context.translate.areYouSureYouWantToDeleteThis} $text?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(context.translate.cancel),
        ),
        TextButton(
          onPressed: () {
            onConfirmed?.call();
            Navigator.of(ctx).pop(true);
          },
          child: Text(context.translate.delete),
        ),
      ],
    ),
  );
}
