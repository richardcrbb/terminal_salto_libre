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
              previousJumps INTEGER,
              previousFreefall INTEGER,
              previousTandems INTEGER,
              previousAffs INTEGER,
              previousCameras INTEGER,
              previousCoaches INTEGER,
              previousFunJumps INTEGER
            )
          ''');

        await db.insert('settings', {
          'key': 'previousInfo',
          'previousJumps': 0,
          'previousFreefall': 0,
          'previousTandems': 0,
          'previousAffs':0,
          'previousCameras':0,
          'previousCoaches':0,
          'previousFunJumps':0,
        });

        await db.execute('''
            CREATE TABLE unitsystem (
              key TEXT PRIMARY KEY,
              boolValue INTEGER
            )
          ''');
        
        await db.insert('unitsystem', {
          'key': 'imperialSystem',
          'boolValue': 1,
        });

        await db.execute('''
            CREATE TABLE dzaltitude(
              key TEXT PRIMARY KEY,
              altitude INTEGER
            )''');
        
        await db.insert('dzaltitude',{
          'key': 'dz',
          'altitude': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
              },
    );
  }
                                                      //!CRUD -> CUDR

  //. INSERTAR
  //  Funcion para insertar un salto
  static Future<int> insertJump(JumpLog log) async {
    final db = await database;
    return await db.insert(
      'jumps',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //. ACTUALIZAR en jumps
  // Funcion para actualizar un salto y recalcular datos de freefall posteriores
  static Future<void> updateJumpAndRecalculate(JumpLog updatedJump) async {
  final db = await database;

  // Paso 1: Actualizar el salto editado
  await db.update(
    'jumps',
    updatedJump.toMap(),
    where: 'id = ?',
    whereArgs: [updatedJump.id],
  );

  // Paso 2: Obtener todos los saltos posteriores
  final posteriores = await db.query(
    'jumps',
    where: 'jumpNumber > ?',
    whereArgs: [updatedJump.jumpNumber],
    orderBy: 'jumpNumber ASC',
  );

  // Paso 3: Recalcular totalFreefall en cascada
  int totalAcumulado = updatedJump.totalFreefall!;

  for (var salto in posteriores) {
    final delay = salto['freefallDelay'] as int;
    totalAcumulado += delay;

    await db.update(
      'jumps',
      {'totalFreefall': totalAcumulado},
      where: 'id = ?',
      whereArgs: [salto['id']],
    );
  }
  }

  //. ACTUALIZAR en settings
  // Funcion que actualiza saltos previos y caida libre previa en la tabla settigns que por defecto esta en 0
  // tambien puede actualizar los datos que se le ingresan a settings, eso si antes de insertar un nuevo salto en jumps.

  static Future<void> savePreviousSettings(SettingsLog settingsLog )async {
  
  final db = await database;

  // Verificar si la tabla jumps está vacía
  final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM jumps');
  final count = countResult.first['count'] as int;

  if (count > 0) {
    // Si hay registros en jumps, no permitir guardar
    throw Exception('❌ Ya hay saltos registrados en esta bitacora digital.');
  }

  // Actualizar los valores en settings
  await db.update(
    'settings',
    settingsLog.toMap(),
    where: 'key = ?',
    whereArgs: ['previousInfo'],
  );
  }

  //. ELIMINAR
  //Funcion para eliminar un registro y actualizar el jumpNumber
  // ✅ Elimina un salto y recalcula jumpNumber y totalFreefall de los posteriores
static Future<void> deleteJumpByNumber(int jumpNumber) async {
  final db = await database;

  // Paso 1: obtener el salto anterior (para saber el totalFreefall base)
  final anteriorRes = await db.query(
    'jumps',
    where: 'jumpNumber = ?',
    whereArgs: [jumpNumber - 1],
  );

  int totalAcumulado;
  if (anteriorRes.isNotEmpty) {
    totalAcumulado = anteriorRes.first['totalFreefall'] as int;
  } else {
    // Si no hay salto anterior[es porque anteriorRes devolvio una lista vacia al no encontrar salto anterior], tomar de settings
    final settings = await db.query(
      'settings',
      columns: ['previousFreefall'],
      where: 'key = ?',
      whereArgs: ['previousInfo'],
    );
    totalAcumulado = (settings.first['previousFreefall'] as int?) ?? 0;
  }

  // Paso 2: eliminar el salto
  await db.delete('jumps', where: 'jumpNumber = ?', whereArgs: [jumpNumber]);

  // Paso 3: bajar en 1 el número de los posteriores
  await db.rawUpdate(
    '''
    UPDATE jumps
    SET jumpNumber = jumpNumber - 1
    WHERE jumpNumber > ?
    ''',
    [jumpNumber],
  );

  // Paso 4: obtener todos los saltos posteriores y recalcular totalFreefall
  final posteriores = await db.query(
    'jumps',
    where: 'jumpNumber >= ?',
    whereArgs: [jumpNumber],
    orderBy: 'jumpNumber ASC',
  );

  for (var salto in posteriores) {
    final delay = salto['freefallDelay'] as int;
    totalAcumulado += delay;

    await db.update(
      'jumps',
      {'totalFreefall': totalAcumulado},
      where: 'id = ?',
      whereArgs: [salto['id']],
    );
  }
  }

  //. TODOS LOS SALTOS
  //  Funcion para obtener una lista de todos los saltos
  static Future<List<JumpLog>> getJumps() async {
    final db = await database;
    final result = await db.query('jumps', orderBy: 'id DESC');
    return result.map((map) => JumpLog.fromMap(map)).toList();
  }

  //. NUMERO DEL ULTIMO salto
  // Funcion que optiene de 'jumps' el NUMERO DEL ULTIMO salto (o busca en la tabla 'settings')
  static Future<int> getLastJumpNumber() async {
    final db = await database;
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM jumps',
    );
    final count = countResult.first['count'] as int;

    if (count == 0) {
      // Si 'jumps 'está vacía, obtener el valor de previousInfo en 'settings'
      final settingsResult = await db.query(
        'settings',
        columns: ['previousJumps'],
        where: 'key = ?',
        whereArgs: ['previousInfo'],
      );

      if (settingsResult.isNotEmpty) {
        return settingsResult.first['previousJumps'] as int; 
      }
      return 0; // Si no existe en 'settings', devolver 0 por defecto
    }

    //si 'jumps' no esta vacia:

    final result = await db.rawQuery(
      'SELECT MAX(jumpNumber) as maxJump FROM jumps',
    );
    return result.first['maxJump'] as int;
  }

  //. TOTALFREEFALL
  // Funcion que obtiene el TOTALFREEFALL del último salto (o de la tabla 'settings')
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
        whereArgs: ['previousInfo'], // fila de la tabla
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

  //. Lista de saltos del ultimo dia.
  // Funcion que busca los saltos del ultimo dia que salte....
  // Busca todos los saltos del último día (ignorando la hora)
static Future<List<JumpLog>> getJumpsWithLastDate() async {
  final db = await database;

  // Primero obtenemos solo la parte de la fecha (YYYY-MM-DD) de la última fecha registrada
  final lastDateResult = await db.rawQuery(
    "SELECT substr(MAX(date), 1, 10) as lastDate FROM jumps",
  );

  final lastDate = lastDateResult.first['lastDate'] as String?;
  if (lastDate == null) return [];

  // Luego obtenemos todos los registros de ese día (ignorando la hora)
  final result = await db.query(
    'jumps',
    where: "substr(date, 1, 10) = ?",
    whereArgs: [lastDate],
    orderBy: 'id DESC',
  );

  return result.map((map) => JumpLog.fromMap(map)).toList();
  }

  //. Lista resumen por categoria.
  // Funcion que busca cuantos saltos tengo de cada tipo <tandem,cam, aff ....>
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

  //.Objeto SettingsLog

  static Future<SettingsLog> getSettingsLog ()async{
    final Database db = await database;
    List<Map<String,dynamic>> log = await db.query('settings',
    where: 'key=?',
    whereArgs: ['previousInfo']);
    
    SettingsLog slog = SettingsLog.fromMap(log.first);

    return slog;

  }

  //. set FAVORITO
  // Funcion para marcar un salto como favorito

  static Future<void> favorite(int? id) async {
      final db = await database;
      await db.rawUpdate('''
        UPDATE jumps 
        SET favorites = CASE favorites WHEN 0 THEN 1 ELSE 0 END
        WHERE id = ?
      ''', [id]);
    }

  //. LISTA de favoritos
  // Funcion para extraer una lista de saltos favoritos de mi base de datos
  static Future<List<JumpLog>> favList()async{
    final db = await database;
    final result = await db.query('jumps', orderBy: 'id DESC', where: 'favorites = ?', whereArgs: [1]);
      return result.map((map) => JumpLog.fromMap(map)).toList();
  }

  //. Imperial System

  static Future<int> isImperialSystem()async{
    
    final Database db = await database;
    
    final List<Map<String,dynamic>> isImperialSystemQuery = await db.query('unitsystem', 
    columns: ['boolValue'],
    where: 'key=?',
    whereArgs: ['imperialSystem'],
    );

    if(isImperialSystemQuery.isNotEmpty){
    return isImperialSystemQuery.first['boolValue'] as int;}

    return 0;
  }

  //. update Imperial System

  static Future<void> updateImperialSystem (int bool) async {
    final Database db = await database;
    db.update('unitsystem',
    {'boolValue':bool},
    where: 'key=?',
    whereArgs: ['imperialSystem'],
    conflictAlgorithm: ConflictAlgorithm.replace,);
  }

  //. update dzaltitude

  static Future<int> setDzAltitude (int altitude) async{
    final Database db = await database;
    return await db.update('dzaltitude', {
      'altitude': altitude},
      where: 'key = ?',
      whereArgs: ['dz'],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //. get dzaltitude

  static Future<int> getDzAltitude () async{
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('dzaltitude',where: 'key = ?',whereArgs: ['dz']);
    if(result.isNotEmpty){
      return result.first['altitude'] as int;
    }
    return 0;
  }


  //!
  // ? Metodos que no son necesarios 
  /*  
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
    
  */

}
