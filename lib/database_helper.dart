import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "AquariumDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'fish_table';
  static const columnId = '_id';
  static const columnSpeed = 'speed';         // Speed of the fish
  static const columnColor = 'color';         // Color stored as hex or int
  
  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnSpeed REAL,
        $columnColor TEXT
      )
    ''');
  }

  // Insert fish data
  Future<int> insertFish(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

  // Query all fish
  Future<List<Map<String, dynamic>>> queryAllFish() async {
    return await _db.query(table);
  }

  // Update fish
  Future<int> updateFish(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Delete fish
  Future<int> deleteFish(int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
