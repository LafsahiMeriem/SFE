
import 'dart:async';
import 'dart:developer';
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
  static const String ProductsTable ="produit";

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

  selectData({required String sql}) async {
    Database? db = await database;
    List<Map> response = await db.rawQuery(sql);
    return response;
  }


  Future<void> _createDatabase(Database db, int version) async {
    // Create buildings table
// Create buildings table
    await db.execute("""
  CREATE TABLE $buildingsTable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    building_id INTEGER
  )
""");


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
           floor_id INTEGER,
           name TEXT UNIQUE,
           FOREIGN KEY (zone_id) REFERENCES $zonesTable(id)
      )
    ''');

    // Create offices table
    await db.execute('''
    CREATE TABLE $officesTable (      
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    floor_id INTEGER,
    zone_id INTEGER, 
    name TEXT UNIQUE,
    FOREIGN KEY (floor_id) REFERENCES $floorsTable(id),
    FOREIGN KEY (zone_id) REFERENCES $zonesTable(id) 
    )
''');

    // Create products table
    await db.execute('''
CREATE TABLE $ProductsTable (
  name TEXT,
  barcode TEXT UNIQUE,
  floor_id INTEGER,
  zone_id INTEGER,
  building_id INTEGER,
  office_id INTEGER,
  FOREIGN KEY (office_id) REFERENCES $officesTable(id),
  FOREIGN KEY (floor_id) REFERENCES $floorsTable(id),
  FOREIGN KEY (zone_id) REFERENCES $zonesTable(id),
  FOREIGN KEY (building_id) REFERENCES $buildingsTable(id)
)
''');




    print("database on created ==============================");
  }
  //Product CRUD operations

  Future<void> insertProduct(String name, String barcode, String buildingId, String zoneId, String floorId, String officeId) async {
    final db = await instance.database;
    await db.insert(ProductsTable, {
      'name': name,
      'barcode': barcode,
      'building_id': buildingId,
      'zone_id': zoneId,
      'floor_id': floorId,
      'office_id': officeId,
    });
    print('Product inserted successfully: $name');
  }


  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query(ProductsTable);
  }

  Future<bool> barcodeExists(String barcode) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      ProductsTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    return result.isNotEmpty;
  }

  Future<void> insertProductWithBarcode(String name, String barcode) async {
    final db = await instance.database;
    await db.insert(ProductsTable, {
      'name': name,
      'barcode': barcode,
    });
    print('Produit inséré avec succès : $name, Barcode: $barcode');
  }

  Future<void> moveProductToWithCodePage(String productName, String barcode) async {
    final db = await instance.database;

    // Retrieve the product details before moving
    final List<Map<String, dynamic>> product = await db.query(
      ProductsTable,
      where: 'name = ? AND (barcode = "" OR barcode IS NULL)',
      whereArgs: [productName],
    );

    if (product.isNotEmpty) {
      // Get the first product (there should only be one match)
      final productDetails = product.first;

      // Insert the product into the page of products with barcode, retaining the other attributes
      await db.insert(ProductsTable, {
        'name': productName,
        'barcode': barcode,
        'building_id': productDetails['building_id'],
        'zone_id': productDetails['zone_id'],
        'floor_id': productDetails['floor_id'],
        'office_id': productDetails['office_id'],
      });

      // Delete the product from the page of products without barcode
      await db.delete(
        ProductsTable,
        where: 'name = ? AND (barcode = "" OR barcode IS NULL)',
        whereArgs: [productName],
      );
    }
  }

  Future<void> deleteProduct(String productName) async {
    final db = await instance.database;
    await db.delete(
      ProductsTable,
      where: 'name = ?',
      whereArgs: [productName],
    );
    print('Product deleted successfully: $productName');
  }




  // Building CRUD operations
  Future<void> deleteDatabaseFile() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'your_database.db');
    await deleteDatabase(path);
    _database = null;
    log("Database deleted");
  }

  Future<String?> insertBuilding(String name) async {
    final db = await instance.database;

    // Check if the building already exists
    List<Map<String, dynamic>> existingBuildings = await db.query(
      buildingsTable,
      where: 'name = ?',
      whereArgs: [name],
    );

    if (existingBuildings.isEmpty) {
      // Insert the building if it doesn't exist
      int id = await db.insert(buildingsTable, {'name': name});
      print('Building inserted successfully with ID: $id');
      return name;  // Return the building name or ID if needed
    } else {
      print('Building already exists: $name');
      return null;  // Return null if the building already exists
    }
  }

  Future<List<Map<String, dynamic>>> getAllBuildings() async {
    final db = await instance.database;
    return await db.query(buildingsTable);
  }

  Future<void> deleteBuilding(String buildingName) async {
    final db = await instance.database;
    await db.delete(buildingsTable, where: 'name = ?', whereArgs: [buildingName]);
    print('Building deleted successfully: $buildingName');
  }



  // Zone CRUD operations

  Future<int> insertZone(int buildingId, String name) async {
    final db = await instance.database;
    int zoneId = await db.insert(zonesTable, {'building_id': buildingId, 'name': name});
    print('Zone inserted successfully: $name with ID: $zoneId');
    return zoneId;
  }



  Future<bool> zoneExistsForBuilding(int buildingId, String zoneName) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> zones = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM zones WHERE name = ? AND building_id = ?',
      [zoneName, buildingId],
    );
    final int count = zones.first['count'] as int;
    return count > 0;
  }



  Future<List<Map<String, dynamic>>> getZonesForBuilding(int buildingId) async {
    final db = await instance.database;
    return await db.query(zonesTable, where: 'building_id = ?', whereArgs: [buildingId]);
  }


  Future<void> deleteZone(int buildingId, int zoneId) async {
    final db = await instance.database;
    await db.delete(zonesTable, where: 'building_id = ? AND id = ?', whereArgs: [buildingId, zoneId]);
    print('Zone deleted successfully: $zoneId');
  }

  // Floor CRUD operations

  Future<void> insertFloor(int zoneId, String floorName, int floorId) async {
    final db = await instance.database;
    await db.insert(floorsTable, {'zone_id': zoneId, 'name': floorName, 'floor_id': floorId});
    print('Floor inserted successfully: $floorName');
  }



  Future<void> deleteFloor(int zoneId, String floorName) async {
    final db = await instance.database;
    await db.delete(floorsTable, where: 'zone_id = ? AND name = ?', whereArgs: [zoneId, floorName]);
    print('Floor deleted successfully: $floorName');
  }


  Future<int> getFloorId(int zoneId, String floorName) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      floorsTable,
      columns: ['id'],
      where: 'zone_id = ? AND name = ?',
      whereArgs: [zoneId, floorName],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return -1;
    }
  }
  Future<List<Map<String, dynamic>>> getFloorsForZone(int zoneId) async {
    final db = await instance.database;
    return await db.query(floorsTable, where: 'zone_id = ?', whereArgs: [zoneId]);
  }





  // Office CRUD operations

  Future<void> insertOffice(int floorId, String name, int zoneId) async {
    final db = await instance.database;
    await db.insert(officesTable, {'floor_id': floorId, 'zone_id': zoneId, 'name': name});
    print('Office inserted successfully: $name');
  }






  Future<List<Map<String, dynamic>>> getOfficesForFloor(int floorId) async {
    final db = await instance.database;

    try {
      // Debugging output to see the floorId being used
      print('Fetching offices for floorId: $floorId');

      List<Map<String, dynamic>> result = await db.query(officesTable, where: 'floor_id = ?', whereArgs: [floorId]);

      // Log how many offices were found
      print('Offices found: ${result.length}');

      return result;
    } catch (e) {
      print('Error fetching offices for floorId $floorId: $e');
      return [];
    }
  }
  Future<void> deleteOffice(String floorName, String officeName) async {
    final db = await instance.database;
    await db.delete(
      officesTable,
      where: 'floor_id = (SELECT id FROM $floorsTable WHERE name = ?) AND name = ?',
      whereArgs: [floorName, officeName],
    );
    print('Office deleted successfully: $officeName');
  }

  Future<void> deleteAllOfficesForFloor(int zoneId, String floorName) async {
    final db = await instance.database;
    await db.delete(
      'offices',
      where: 'zone_id = ? AND floor_name = ?',
      whereArgs: [zoneId, floorName],
    );
  }

  Future<bool> officeExists(int floorId, String officeName) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      officesTable,
      where: 'floor_id = ? AND name = ?',
      whereArgs: [floorId, officeName],
    );
    return result.isNotEmpty;
  }



}