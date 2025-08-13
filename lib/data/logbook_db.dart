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
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
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
        await db.execute('''
            CREATE TABLE settings (
              key TEXT PRIMARY KEY,
              value INTEGER,
              previousFreefall INTEGER
            )
          ''');

        await db.insert('settings', {
          'key': 'startingJumpNumber',
          'value': '0',
          'previousFreefall': 0,
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
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

  // Obtiene de 'jumps 'el número del último salto (o busca en la tabla 'settings')
  static Future<int> getLastJumpNumber() async {
    final db = await database;

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM jumps',
    );
    final count = countResult.first['count'] as int;

    if (count == 0) {
      // Si 'jumps 'está vacía, obtener el valor de startingJumpNumber en 'settings'
      final settingsResult = await db.query(
        'settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['startingJumpNumber'],
      );

      if (settingsResult.isNotEmpty) {
        return int.tryParse(settingsResult.first['value'] as String) ?? 0;
      }
      return 0; // Si no existe en 'settings', devolver 0 por defecto
    }

    //si 'jumps' no esta vacia:

    final result = await db.rawQuery(
      'SELECT MAX(jumpNumber) as maxJump FROM jumps',
    );
    return result.first['maxJump'] as int;
  }

  // Obtiene el totalFreefall del último salto (o de la tabla 'settings')
  static Future<int> getLastTotalFreefall() async {
    final db = await database;

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM jumps',
    );
    final count = countResult.first['count'] as int;

    if (count == 0) {
      // Si 'jumps 'está vacía, obtener el valor de totalFreefall en 'settings'
      final settingsResult = await db.query(
        'settings',
        columns: ['previousFreefall'], //columna de la tabla
        where: 'key = ?',
        whereArgs: ['startingJumpNumber'], // fila de la tabla
      );

      if (settingsResult.isNotEmpty) {
        return settingsResult.first['previousFreefall'] as int;
      }
      return 0; // Si no existe en 'settings', devolver 0 por defecto
    }

    //si 'jumps' no esta vacia:

    final result = await db.query(
      'jumps',
      columns: ['totalFreefall'],
      orderBy: 'id DESC',
      limit: 1,
    );
    return (result.first['totalFreefall'] as int?) ?? 0;
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
  ''', jumpTypeList);

    //LA SIGUIENTE FUNCION TRANSFORMA EL LISTADO DE MAPAS List<Map<String, Object?>> A UN SIMPLE SIMPLE DE <String, int>

    // Inicializamos el mapa con todos los tipos en 0
    Map<String, int> counts = {for (var type in jumpTypeList) type: 0};

    // Actualizamos con los valores de la consulta
    for (final row in result) {
      final type = row['jumpType'] as String;
      final count = row['count'] as int;
      counts[type] = count;
    }

    return counts;
  }
}
