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
            "CREATE TABLE receipts(id INTEGER PRIMARY KEY AUTOINCREMENT, store TEXT, price TEXT, image TEXT, date TEXT, key TEXT)");
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
      String table, String store, String datePicked) async {
    final db = await DBHelper.database();
    if (store == '') {
      return db.query(table,
          distinct: true, columns: ['store'], orderBy: 'store');
    } else if (datePicked != null) {
      return db.query(
        table,
        where: 'store = ? and date = ?',
        whereArgs: [store, datePicked],
        orderBy: 'date desc, id desc',
      );
    } else {
      return db.query(
        table,
        where: 'store = ?',
        whereArgs: [store],
        orderBy: 'date desc, id desc',
      );
    }
  }

  static Future<void> updateData(
      String table, Map<String, Object> data, String itemID) async {
    final db = await DBHelper.database();
    db.update(
      table,
      data,
      where: 'key = ?',
      whereArgs: [itemID],
    );
  }

  static Future<List<Map<String, dynamic>>> receiptCount(String table) async {
    final db = await DBHelper.database();

    return db.query(
      table,
    );
  }

  static Future<void> deleteItem(String table, int id) async {
    final db = await DBHelper.database();

    db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getDataPie(
    String table,
  ) async {
    final db = await DBHelper.database();

    return db.query(table, orderBy: 'store');
  }

  // Add Friend to Database-------------------------------------

  static Future<Database> databaseFriend() async {
    final dbPath = await sqlite.getDatabasesPath();
    return sqlite.openDatabase(
      path.join(
        dbPath,
        'friend.db',
      ),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE friend(id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT, name TEXT)");
      },
      version: 1,
    );
  }

  static Future<void> insertFriend(
      String table, Map<String, Object> data) async {
    final db = await DBHelper.databaseFriend();
    db.insert(
      table,
      data,
    );
  }

  static Future<List<Map<String, dynamic>>> getDataFriend(String table) async {
    final db = await DBHelper.databaseFriend();

    return db.query(
      table,
      orderBy: 'id desc',
    );
  }

  static Future<void> deleteFriend(String table, int id) async {
    final db = await DBHelper.databaseFriend();

    db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
