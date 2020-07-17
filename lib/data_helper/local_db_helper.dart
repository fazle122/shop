import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {

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


  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'carts.db'),
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE cartTable('
                  'id INTEGER PRIMARY KEY AUTOINCREMENT, productId TEXT, title TEXT,quantity INTEGER,price NUMERIC,isNonInventory INTEGER,discount NUMERIC,discountType TEXT,discountId TEXT)');
        }, version: 1);
  }

  static Future<bool> isProductExist(String id) async {
    final db = await DBHelper.database();
    var result = await db.rawQuery(
        'SELECT * FROM cartTable WHERE productId = $id');

    if (result.length != 0) {
      return true;
    }
    else {
      return false;
    }
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> increaseItemQuantity(String table,
      Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.rawUpdate(
        'UPDATE cartTable SET quantity = quantity+1 WHERE productId = ${data['productId']}');
  }

  static Future<void> decreaseItemQuantity(String productId) async {
    final db = await DBHelper.database();
    db.rawUpdate(
        'UPDATE cartTable SET quantity = quantity-1 WHERE productId = $productId');


//    CartItem item = await getSingleData(data['productId']);
//    int quantity = item.quantity;
//    if(quantity == 1){
//      db.rawDelete('DELETE FROM cartTable WHERE productId = ${data['productId']}');
//    }else {
//      db.rawUpdate('UPDATE cartTable SET quantity = quantity-1 WHERE productId = ${data['productId']}');
//    }

  }

  static Future<void> deleteCartItm(String productId) async {
    final db = await DBHelper.database();
    await db.rawDelete(
        'DELETE FROM cartTable WHERE productId = $productId');
  }


  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return await db.query(table);
  }

  static Future<CartItem> getSingleData(String productId) async {
    final db = await DBHelper.database();
    final result = await db.rawQuery(
        'SELECT * FROM cartTable WHERE productId = $productId');
    if (result.length > 0) {
      return await new CartItem.fromJson(result.first);
    }
    return null;
  }


  static Future<void> clearCart() async {
    final db = await DBHelper.database();
    await db.rawQuery('DELETE  FROM cartTable');
//    db.rawDelete('DELETE * from cartTable ');
  }

}

