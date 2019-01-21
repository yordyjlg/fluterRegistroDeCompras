import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableProductos = 'productos';
  final String idproductos = 'idproductos';
  final String nombre = 'nombre';
  final String descripcion = 'descripcion';
  final String image = 'image';
  final String imageTipe = 'imageTipe';

  final String tableProductPrecio = 'productPrecio';
  final String idprodPrecio = 'idprodPrecio';
  final String productosidproductos = 'productosidproductos';
  final String monto = 'monto';
  final String tasa = 'tasa';
  final String date = 'date';

  final String tableCambios = 'cambios';
  final String idcambios = 'idcambios';
  final String usd = 'usd';
  final String tasacambios = 'tasa';
  final String nota = 'nota';
  final String datecambios = 'date';


  final String tableCompras = 'compras';
  final String idcompras = 'idcompras';
  final String idproductoscompras = 'productosidproductos';
  final String cambiosidcambios = 'cambiosidcambios';
  final String montocompras = 'monto';
  final String cantidad = 'cantidad';
  final String type = 'type';
  final String datecompras = 'date';


  final String tableMonedero = 'monedero';
  final String idmonedero = 'idmonedero';
  final String saldo = 'saldo';
  final String updatedate = 'updatedate';




  final String remoteKey = 'remoteKey';
  final String sync = 'sync';
  final String usersSync = 'usersSync';
  final String operacion = 'operacion';

  static Database _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'precios.db');

    // await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 2, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tableProductos('
            '$idproductos INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$nombre TEXT, '
            '$descripcion TEXT, '
            '$image TEXT, '
            '$remoteKey TEXT, '
            '$sync INTEGER, '
            '$usersSync TEXT, '
            '$operacion TEXT, '
            '$imageTipe INTEGER)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tableProductPrecio('
            '$idprodPrecio INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$productosidproductos INTEGER REFERENCES $tableProductos($idproductos), '
            '$monto REAL, '
            '$tasa REAL, '
            '$date TEXT,'
            '$remoteKey TEXT, '
            '$sync INTEGER, '
            '$usersSync TEXT, '
            '$operacion TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tableCambios('
            '$idcambios INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$usd REAL, '
            '$tasacambios REAL, '
            '$nota TEXTL, '
            '$datecambios TEXT,'
            '$remoteKey TEXT, '
            '$sync INTEGER, '
            '$usersSync TEXT, '
            '$operacion TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tableCompras('
            '$idcompras INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$idproductoscompras INTEGER REFERENCES $tableProductos($idproductos), '
            '$cambiosidcambios INTEGER REFERENCES $tableCambios($idcambios), '
            '$montocompras REAL, '
            '$cantidad INTEGER, '
            '$type TEXT, '
            '$datecompras TEXT,'
            '$remoteKey TEXT, '
            '$sync INTEGER, '
            '$usersSync TEXT, '
            '$operacion TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tableMonedero('
            '$idmonedero INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$saldo REAL, '
            '$updatedate TEXT,'
            '$remoteKey TEXT, '
            '$sync INTEGER, '
            '$usersSync TEXT, '
            '$operacion TEXT)');
  }

  Future<int> save(String table, Map<String, dynamic> values) async {
    var dbClient = await db;
    var result = await dbClient.insert(table, values);
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');

    return result;
  }

  Future<List> getAll(String table) async {
    var dbClient = await db;
    // var result = await dbClient.query(table, columns: columns);
    var result = await dbClient.rawQuery('SELECT * FROM $table');

    return result;
  }

  Future<List> getAllWhere(String table, int id, String columnId) async {
    var dbClient = await db;
    // var result = await dbClient.query(table, columns: columns);
    var result = await dbClient.rawQuery('SELECT * FROM $table WHERE $columnId = $id');

    return result;
  }

  Future<int> getCount(String table) async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<dynamic> getNote(String table, int id, List<String> columns, String columnId) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(table,
        columns: columns,
        where: '$columnId = ?',
        whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote WHERE $columnId = $id');

    if (result.length > 0) {
      return result.first;
    }

    return null;
  }

  Future<int> delete(String table, int id, String columnId) async {
    var dbClient = await db;
    return await dbClient.delete(table, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }

  Future<int> updateNote(String table, int id, String columnId, data) async {
    var dbClient = await db;
    return await dbClient.update(table, data, where: "$columnId = ?", whereArgs: [id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}