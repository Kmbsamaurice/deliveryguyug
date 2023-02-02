import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thedeliveryguyug/models/cart.dart';
 
class DatabaseHelper {
  static final _databaseName = "cart.db";
  static final _databaseVersion = 1;
 
  static final table = 'items';
 
  static final columnId = 'id';
  static final columnItemid = 'product_id';
  static final columnVendorid = 'vendor_id';
  static final columnItem = 'product';
  static final columnImage = 'image';
  static final columnItemprice = 'price';
  static final columnQuantity = 'sold_quantity';

 
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
 
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }
 
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }
 
  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnItemid TEXT,
            $columnVendorid TEXT,
            $columnItem TEXT,
            $columnImage TEXT,
            $columnItemprice TEXT,
            $columnQuantity INTEGER
          )
          ''');
  }

  Future<int> insert(Cart cart) async {
    Database db = await instance.database;
    var res = await db.insert(table, cart.toMap());
    return res;
  }
 
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(table, orderBy: "$columnId DESC");
    return res;
  }
 
 Future<List<Map<String, dynamic>>> oneRow(String item) async {
    Database db = await instance.database;
    var res = await db.query("$columnQuantity FROM $table", where: '$columnItem = ?', whereArgs: [item]);
    return res;
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> clearTable() async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table");
  }
  
Future<int> getCount() async {
    //database connection
    Database db = await this.database;
    var x = await db.rawQuery('SELECT COUNT (*) from $table');
    int count = Sqflite.firstIntValue(x);
    return count;
}

Future<int> productExist(String item) async {
    Database db = await instance.database;
    var count = await db.query(table, where: '$columnItem = ?', whereArgs: [item]);
    int result = count.length;
    return result;
  }

Future updateItemQuantity(newQty, item) async {
    Database db = await instance.database;
    var res = await db.rawQuery(""" UPDATE $table SET $columnQuantity = $newQty WHERE $columnItem = '$item'; """);
    return res;
}

Future getTotal() async {
  Database db = await instance.database;
  var grandTotal = await db.rawQuery("SELECT SUM($columnQuantity * $columnItemprice) FROM $table");
  int value = grandTotal[0]["SUM($columnQuantity * $columnItemprice)"];
  return value.toString();
}

}