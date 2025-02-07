import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ts/models/photo.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'photo_gallery.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE photos(
            id TEXT PRIMARY KEY,
            name TEXT,
            url TEXT,
            createdTime TEXT,
            isFavorite INTEGER
          )
        ''');
        
        await db.execute('''
          CREATE TABLE metadata(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
      version: 1,
    );
  }
  
  Future<void> savePhotos(List<Photo> photos) async {
    final db = await database;
    final batch = db.batch();
    
    for (final photo in photos) {
      batch.insert(
        'photos',
        photo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }
  
  Future<List<Photo>> getPhotos() async {
    final db = await database;
    final maps = await db.query('photos', orderBy: 'createdTime DESC');
    return maps.map((map) => Photo.fromMap(map)).toList();
  }
  
  Future<void> updatePhoto(Photo photo) async {
    final db = await database;
    await db.update(
      'photos',
      photo.toMap(),
      where: 'id = ?',
      whereArgs: [photo.id],
    );
  }
  
  Future<DateTime?> getLastSyncTime() async {
    final db = await database;
    final result = await db.query(
      'metadata',
      where: 'key = ?',
      whereArgs: ['last_sync'],
    );
    
    if (result.isEmpty) return null;
    return DateTime.parse(result.first['value'] as String);
  }
  
  Future<void> updateLastSyncTime() async {
    final db = await database;
    await db.insert(
      'metadata',
      {
        'key': 'last_sync',
        'value': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}