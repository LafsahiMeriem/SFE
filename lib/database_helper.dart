import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  static const String buildingsTable = 'buildings';
  static const String zonesTable = 'zones';
  static const String floorsTable = 'floors';
  static const String officesTable = 'offices';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'your_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create buildings table
    await db.execute('''
      CREATE TABLE $buildingsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    // Create zones table
    await db.execute('''
      CREATE TABLE $zonesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        building_id INTEGER,
        name TEXT,
        FOREIGN KEY (building_id) REFERENCES $buildingsTable(id)
      )
    ''');

    // Create floors table
    await db.execute('''
      CREATE TABLE $floorsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        zone_id INTEGER,
        name TEXT,
        FOREIGN KEY (zone_id) REFERENCES $zonesTable(id)
      )
    ''');

    // Create offices table
    await db.execute('''
      CREATE TABLE $officesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        floor_id INTEGER,
        name TEXT,
        FOREIGN KEY (floor_id) REFERENCES $floorsTable(id)
      )
    ''');
  }

  // Building CRUD operations

  Future<void> insertBuilding(String name) async {
    final db = await instance.database;
    await db.insert(buildingsTable, {'name': name});
    print('Building inserted successfully: $name');

  }

  Future<List<Map<String, dynamic>>> getAllBuildings() async {
    final db = await instance.database;
    return await db.query(buildingsTable);
  }

  // Zone CRUD operations

  Future<void> insertZone(int buildingId, String name) async {
    final db = await instance.database;
    await db.insert(zonesTable, {'building_id': buildingId, 'name': name});
    print('Zone inserted successfully: $name');

  }

  Future<List<Map<String, dynamic>>> getZonesForBuilding(int buildingId) async {
    final db = await instance.database;
    return await db.query(zonesTable, where: 'building_id = ?', whereArgs: [buildingId]);
  }

  // Floor CRUD operations

  Future<void> insertFloor(int zoneId, String name) async {
    final db = await instance.database;
    await db.insert(floorsTable, {'zone_id': zoneId, 'name': name});
    print('Floor inserted successfully: $name');

  }

  Future<List<Map<String, dynamic>>> getFloorsForZone(int zoneId) async {
    final db = await instance.database;
    return await db.query(floorsTable, where: 'zone_id = ?', whereArgs: [zoneId]);
  }

  // Office CRUD operations

  Future<void> insertOffice(int floorId, String name) async {
    final db = await instance.database;
    await db.insert(officesTable, {'floor_id': floorId, 'name': name});
    print('Office inserted successfully: $name');

  }

  Future<List<Map<String, dynamic>>> getOfficesForFloor(int floorId) async {
    final db = await instance.database;
    return await db.query(officesTable, where: 'floor_id = ?', whereArgs: [floorId]);
  }
}
