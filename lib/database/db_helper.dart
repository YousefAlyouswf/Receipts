import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sqlite.getDatabasesPath();
    return sqlite.openDatabase(
      path.join(
        dbPath,
        'receipts.db',
      ),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE receipts(id INTEGER PRIMARY KEY AUTOINCREMENT, store TEXT, price TEXT, image TEXT, date TEXT)");
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(
      String table, String store) async {
    final db = await DBHelper.database();
    if (store == '') {
      return db.rawQuery('SELECT DISTINCT store FROM $table');
    } else {
      return db.query(
        table,
        where: 'store = ?',
        whereArgs: [store],
        orderBy: 'date desc',
      );
    }
  }

  static Future<void> deleteItem(String table, int id) async {
    final db = await DBHelper.database();

    db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getDataPie(
    String table,
  ) async {
    final db = await DBHelper.database();

    return db.query(
      table,
      orderBy: 'store'
    );
  }
}
