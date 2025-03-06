import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/data/models/playlist_surah_model.dart';

import '../../data/datasources/playlist_database.dart';

part 'playlist_surah_state.dart';

class PlaylistSurahCubit extends Cubit<PlaylistSurahState> {
  PlaylistSurahCubit() : super(PlaylistSurahInitial());

  final PlaylistDatabase _playlistDatabase = PlaylistDatabase();

  Future<void> fetchSurahsInPlaylist(int playlistId) async {
    emit(PlaylistSurahLoading());
    try {
      final surahs = await _playlistDatabase.getSurahsInPlaylist(playlistId);

      emit(PlaylistSurahLoaded(playlistId, surahs));
    } catch (e) {
      emit(const PlaylistSurahError("Failed to load surahs"));
    }
  }

  Future<void> deleteSurahsInPlaylist(
    String audioSource,
    int playlistId,
  ) async {
    try {
      await _playlistDatabase.deleteSurahByAudioPath(audioSource);
      emit(PlaylistSurahLoading());
      fetchSurahsInPlaylist(playlistId);

      emit(const PlaylistSurahDelete('Deleted successfully'));
    } catch (e) {
      emit(const PlaylistSurahError("Failed to load surahs"));
    }
  }
}
