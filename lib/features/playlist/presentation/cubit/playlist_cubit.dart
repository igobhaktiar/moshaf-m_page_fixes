import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/playlist_database.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit() : super(PlaylistInitial());

  final PlaylistDatabase _playlistDatabase = PlaylistDatabase();

  Future<void> fetchPlaylists() async {
    try {
      emit(PlaylistLoading());

      List<Map<String, dynamic>> playlists =
          await _playlistDatabase.getPlaylistsWithNames();

      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(const PlaylistLoadError("Failed to load playlists"));
    }
  }

  Future<void> insertPlaylist(String playlistName) async {
    try {
      await _playlistDatabase.insertPlaylist(playlistName);
      await fetchPlaylists();
    } catch (e) {
      emit(const PlaylistLoadError("Failed to add playlist"));
    }
  }

  Future<void> editPlaylist(int playlistId, String newPlaylistName) async {
    try {
      await _playlistDatabase.editPlaylist(
        playlistId: playlistId,
        newPlaylistName: newPlaylistName,
      );
      await fetchPlaylists();
    } catch (e) {
      emit(const PlaylistLoadError("Failed to add playlist"));
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    try {
      await _playlistDatabase.deletePlaylist(playlistId);
      await fetchPlaylists();
    } catch (e) {
      emit(const PlaylistLoadError("Failed to add playlist"));
    }
  }
}
