import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:terminal_salto_libre/data/models.dart';

class JumpLogDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jump_logs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE jumps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jumpNumber INTEGER,
            date TEXT,
            location TEXT,
            aircraft TEXT,
            equipment TEXT,
            altitude INTEGER,
            freefallDelay INTEGER,
            totalFreefall INTEGER,
            description TEXT,
            signature TEXT,
          )
        ''');
      },
    );
  }

  static Future<int> insertJump(JumpLog log) async {
    final db = await database;
    return await db.insert('jumps', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<JumpLog>> getJumps() async {
    final db = await database;
    final result = await db.query('jumps');
    return result.map((map) => JumpLog.fromMap(map)).toList();
  }

  static Future<int> updateJump(JumpLog log) async {
    final db = await database;
    return await db.update('jumps', log.toMap(), where: 'id = ?', whereArgs: [log.id]);
  }

  static Future<int> deleteJump(int id) async {
    final db = await database;
    return await db.delete('jumps', where: 'id = ?', whereArgs: [id]);
  }
  static Future<int> getLastJumpNumber() async {
  final db = await database;
  final result = await db.rawQuery('SELECT MAX(jumpNumber) as maxJump FROM jumps');
  final maxJump = result.first['maxJump'];
  return maxJump != null ? maxJump as int : 0;
  }
}
