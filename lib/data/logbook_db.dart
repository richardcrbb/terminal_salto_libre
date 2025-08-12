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
      version: 3,
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
              jumpType TEXT,
              weight INTEGER,
              age INTEGER,
              description TEXT,
              signature TEXT,
              favorites INTEGER DEFAULT 0
            )
          ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE jumps ADD COLUMN age INTEGER');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE jumps ADD COLUMN favorites INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  static Future<int> insertJump(JumpLog log) async {
    final db = await database;
    return await db.insert(
      'jumps',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<JumpLog>> getJumps() async {
    final db = await database;
    final result = await db.query('jumps', orderBy: 'id DESC');
    return result.map((map) => JumpLog.fromMap(map)).toList();
  }

  static Future<int> updateJump(JumpLog log) async {
    final db = await database;
    return await db.update(
      'jumps',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  static Future<int> deleteJump(int id) async {
    final db = await database;
    return await db.delete('jumps', where: 'id = ?', whereArgs: [id]);
  }

  // Obtiene el número del último salto (o 0 si no hay registros)
  static Future<int> getLastJumpNumber() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(jumpNumber) as maxJump FROM jumps',
    );

    final maxJump = result.first['maxJump'];
    return maxJump != null ? maxJump as int : 0;
  }

  // Obtiene el totalFreefall del último salto (o 0 si no hay registros)
  static Future<int> getLastTotalFreefall() async {
    final db = await database;
    final result = await db.query(
      'jumps',
      columns: ['totalFreefall'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty && result.first['totalFreefall'] != null) {
      return result.first['totalFreefall'] as int;
    }

    return 0;
  }

  //funcion para eliminar un registro y actualizar el jumpnumber
  static Future<void> deleteJumpByNumber(int jumpNumber) async {
    final db = await database;

    // Paso 1: eliminar el salto con jumpNumber = X
    await db.delete('jumps', where: 'jumpNumber = ?', whereArgs: [jumpNumber]);

    // Paso 2: restar 1 a todos los jumpNumber mayores que X
    await db.rawUpdate(
      '''
    UPDATE jumps
    SET jumpNumber = jumpNumber - 1
    WHERE jumpNumber > ?
  ''',
      [jumpNumber],
    );
  }

  static Future<List<JumpLog>> getJumpsWithLastDate() async {
    final db = await database;

    // Primero obtenemos la última fecha registrada
    final lastDateResult = await db.rawQuery(
      'SELECT MAX(date) as lastDate FROM jumps',
    );

    final lastDate = lastDateResult.first['lastDate'];
    if (lastDate == null) return [];

    // Luego obtenemos todos los registros con esa fecha
    final result = await db.query(
      'jumps',
      where: 'date = ?',
      whereArgs: [lastDate],
      orderBy: 'id DESC',
    );

    return result.map((map) => JumpLog.fromMap(map)).toList();
  }

  static Future<Map<String, int>> getJumpTypeCounts() async {
  final db = await database;

  // Ejecutamos consulta para contar por tipo 
    /*
  List<Map<String, Object?>> result
  [
    {'jumpType': 'Tandem', 'count': 10},
    {'jumpType': 'Camera', 'count': 5},
    {'jumpType': 'Fun Jump', 'count': 8},
  ]
    */
  
  // SELECT devuelve las claves del mapa que serian jumpType y count1204, porque <COUNT(*) as count1204> deja esa columan como count1204

  // los ? son placeholders de parametros que asignaremos en una lista que se llama bind parameters o positional bind parameters.

  // lo que va en db.rawQuery('''PRIMER PARAMETRO ''' <COMA> , SEGUNDO PARAMETRO ) el segundo parametro en este caso es la lista jumpTypeList

  final result = await db.rawQuery('''
    SELECT jumpType, COUNT(*) as count 
    FROM jumps
    WHERE jumpType IN (?, ?, ?, ?, ?)
    GROUP BY jumpType
  ''', jumpTypeList );

  //LA SIGUIENTE FUNCION TRANSFORMA EL LISTADO DE MAPAS List<Map<String, Object?>> A UN SIMPLE SIMPLE DE <String, int>

  // Inicializamos el mapa con todos los tipos en 0
  Map<String, int> counts = {
    for (var type in jumpTypeList) type: 0,
  };

  // Actualizamos con los valores de la consulta
  for (final row in result) {
    final type = row['jumpType'] as String;
    final count = row['count'] as int;
    counts[type] = count;
  }

  return counts;
}
}
