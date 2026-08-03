import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pharma_stock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const numType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE medicines (
        id $idType,
        name $textType,
        genericName TEXT,
        category $textType,
        quantity $intType,
        minStockAlert $intType,
        batchNumber $textType,
        expiryDate $textType,
        purchasePrice $numType,
        mrp $numType,
        sellingPrice $numType,
        gstRate $numType,
        supplier $textType,
        rackLocation $textType,
        lastUpdated $textType,
        notes TEXT,
        billPhotoUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_history (
        id $idType,
        medicineId $textType,
        medicineName $textType,
        type $textType,
        quantityChange $intType,
        previousQuantity $intType,
        newQuantity $intType,
        batchNumber TEXT,
        expiryDate TEXT,
        purchasePrice REAL,
        gstAmount REAL,
        supplier TEXT,
        billPhotoUrl TEXT,
        timestamp $textType,
        user $textType,
        notes TEXT
      )
    ''');
  }

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await instance.database;
    return await db.insert('medicines', medicine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Medicine>> getAllMedicines() async {
    final db = await instance.database;
    final result = await db.query('medicines', orderBy: 'name ASC');
    return result.map((json) => Medicine.fromMap(json)).toList();
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await instance.database;
    return db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<int> deleteMedicine(String id) async {
    final db = await instance.database;
    return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertStockHistory(Map<String, dynamic> historyMap) async {
    final db = await instance.database;
    return await db.insert('stock_history', historyMap);
  }

  Future<List<Map<String, dynamic>>> getStockHistory() async {
    final db = await instance.database;
    return await db.query('stock_history', orderBy: 'timestamp DESC');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
