import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

// singleton database helper class
class DBHelper {
  // create a single instance of dbhelper to reuse across the app
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  // reference to the database object
  Database? _db;

  // getter to initialize or return existing database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // open or create the sqlite database
  Future<Database> _initDB() async {
    // get the default path for databases on device
    final dbPath = await getDatabasesPath();
    // create the full path to our finance.db file
    final path = join(dbPath, 'finance.db');

    // open the database and create the transactions table if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            category TEXT,
            date TEXT,
            note TEXT,
            isBill INTEGER
          )
        ''');
      },
    );
  }

  // insert a new transaction record into the database
  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // retrieve all transaction records from the database
  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    // convert each map back into a transactionmodel object
    return List.generate(
      maps.length,
          (i) => TransactionModel.fromMap(maps[i]),
    );
  }

  // update an existing transaction record based on its id
  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  // delete a transaction record by id
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}