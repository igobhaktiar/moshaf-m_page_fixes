import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/playlist_surah_model.dart';

class PlaylistDatabase {
  static final PlaylistDatabase _instance = PlaylistDatabase._internal();
  static Database? _database;

  factory PlaylistDatabase() => _instance;

  PlaylistDatabase._internal();

  // Table and column names for playlists
  static const String tablePlaylists = 'playlists';
  static const String columnPlaylistId = 'playlist_id';
  static const String columnPlaylistName = 'playlist_name';

  // Table and column names for surahs
  static const String tableSurahs = 'surahs';
  static const String columnSurahId = 'surah_id';
  static const String columnSurahName = 'surah_name';
  static const String columnReciterName = 'reciter_name';
  static const String columnReciterArabicName = 'reciter_arabic_name';
  static const String columnReciterEnglishName = 'reciter_english_name';
  static const String columnAudioPath = 'audio_path';
  static const String columnAudioUrl = 'audio_url';
  static const String columnPlaylistForeignKey = 'playlist_id';

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Create and open the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'playlist_surahs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE $tablePlaylists (
          $columnPlaylistId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnPlaylistName TEXT NOT NULL)''');

        await db.execute('''CREATE TABLE $tableSurahs (
          $columnSurahId INTEGER,
          $columnSurahName TEXT NOT NULL,
          $columnReciterName TEXT NOT NULL,
          $columnReciterArabicName TEXT NOT NULL,
          $columnReciterEnglishName TEXT NOT NULL,
          $columnAudioPath TEXT NOT NULL,
          $columnAudioUrl TEXT NOT NULL,
          $columnPlaylistForeignKey INTEGER,
          FOREIGN KEY($columnPlaylistForeignKey) REFERENCES $tablePlaylists($columnPlaylistId) ON DELETE CASCADE,
          UNIQUE($columnAudioPath, $columnAudioUrl, $columnPlaylistForeignKey) ON CONFLICT REPLACE)''');
      },
    );
  }

  // Fetch all playlists with names
  Future<List<Map<String, dynamic>>> getPlaylistsWithNames() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(tablePlaylists);

    return result.map((e) {
      return {
        'playlist_id': e[columnPlaylistId],
        'playlist_name': e[columnPlaylistName],
      };
    }).toList();
  }

  // Insert a new playlist
  Future<int> insertPlaylist(String playlistName) async {
    final db = await database;
    return await db.insert(tablePlaylists, {columnPlaylistName: playlistName});
  }

  // Insert a surah into a playlist
  Future<void> insertSurahToPlaylist({
    required int playlistId,
    required String surahId,
    required String surahName,
    required String reciterName,
    required String reciterArabicName,
    required String reciterEnglishName,
    required String audioPath,
    required String audioUrl,
  }) async {
    final db = await database;

    await db.insert(
      tableSurahs,
      {
        columnSurahId: surahId,
        columnSurahName: surahName,
        columnReciterName: reciterName,
        columnReciterArabicName: reciterArabicName,
        columnReciterEnglishName: reciterEnglishName,
        columnAudioPath: audioPath,
        columnAudioUrl: audioUrl,
        columnPlaylistForeignKey: playlistId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch surahs in a specific playlist
  Future<List<PlaylistSurahModel>> getSurahsInPlaylist(int playlistId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableSurahs,
      where: '$columnPlaylistForeignKey = ?',
      whereArgs: [playlistId],
    );
    return List.generate(maps.length, (i) {
      return PlaylistSurahModel.fromMap(maps[i]);
    });
  }

  // Delete a playlist by ID
  Future<void> deletePlaylist(int playlistId) async {
    final db = await database;
    await db.delete(tablePlaylists,
        where: '$columnPlaylistId = ?', whereArgs: [playlistId]);
  }

  // Delete a surah from playlist by audio path
  Future<void> deleteSurahByAudioPath(String audioPath) async {
    final db = await database;
    await db.delete(tableSurahs,
        where: '$columnAudioPath = ?', whereArgs: [audioPath]);
  }

  // Edit a playlist name by ID
  Future<void> editPlaylist({
    required int playlistId,
    required String newPlaylistName,
  }) async {
    final db = await database;
    await db.update(
      tablePlaylists,
      {columnPlaylistName: newPlaylistName},
      where: '$columnPlaylistId = ?',
      whereArgs: [playlistId],
    );
  }

  // Close the database
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}
