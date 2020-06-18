import 'dart:async';
import 'package:shoptempdb/providers/cart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableCart = 'cartTable';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnProductId = 'productId';
  final String columnQuantity = 'quantity';
  final String columnPrice = 'price';
  final String columnIsNonInventory = 'isNonInventory';
  final String columnDiscount = 'discount';
  final String columnDiscountType = 'discountType';
  final String columnDiscountId = 'discountId';

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
    String path = join(databasesPath, 'carts.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }


  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableCart('
            '$columnId INTEGER PRIMARY KEY, $columnProductId TEXT, $columnTitle TEXT,$columnQuantity INTEGER,$columnPrice NUMERIC,$columnIsNonInventory INTEGER,$columnDiscount NUMERIC,$columnDiscountType TEXT,$columnDiscountId TEXT)');
  }

  Future<int> addCartItem(CartItem cart) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableCart, cart.toMap());
    return result;
  }

  Future<List> getAllCartItems() async {
    var dbClient = await db;
//    var result = await dbClient.query(tableCart, columns: [columnId, columnTitle, columnDescription]);
    var result = await dbClient.rawQuery('SELECT * FROM $tableCart');

    return result.toList();
  }

  Future<int> updateCartItem(CartItem cart) async {
    var dbClient = await db;
    return await dbClient.update(tableCart, cart.toMap(), where: "$columnId = ?", whereArgs: [cart.id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
  }


  Future<int> deleteCartItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableCart, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }

  Future<bool> isProductExist(String id) async{
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery("SELECT * FROM $tableCart WHERE id=" + id + ";"));
      var result = dbClient.rawQuery("SELECT * FROM $tableCart WHERE id=" + id + ";");

      if (count != 0)
      {
//        dbClient.close();
        return true;
      }
      else
      {
//        dbClient.close();
        return false;
      }
  }


  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $tableCart'));
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

//  Future<CartItem> getNote(int id) async {
//    var dbClient = await db;
//    List<Map> result = await dbClient.query(tableCart,
//        columns: [columnId, columnTitle, columnDescription],
//        where: '$columnId = ?',
//        whereArgs: [id]);
////    var result = await dbClient.rawQuery('SELECT * FROM $tableNote WHERE $columnId = $id');
//
//    if (result.length > 0) {
//      return new Note.fromMap(result.first);
//    }
//
//    return null;
//  }
}
