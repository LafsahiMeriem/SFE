import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class DatabaseHelper {
  static final _databaseName = "my_database.db";
  static final _databaseVersion = 1;

  static final table = 'my_table';
  static final columnName = 'name';
  static final columnBarcode = 'barcode';
  static final columnBuilding = 'building';
  static final columnFloor = 'floor';
  static final columnZone = 'zone';
  static final columnReference = 'reference';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnName TEXT NOT NULL,
            $columnBarcode TEXT NOT NULL,
            $columnBuilding TEXT NOT NULL,
            $columnFloor TEXT NOT NULL,
            $columnZone TEXT NOT NULL,
            $columnReference TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Insert a row in the database
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Query all rows in the database
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Export data to Excel
  Future<String?> exportDataToExcel() async {
    List<Map<String, dynamic>> data = await queryAllRows();
    if (data.isNotEmpty) {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];
      sheet.appendRow([
        'Name', 'Barcode', 'Building', 'Floor', 'Zone', 'Reference'
      ]);
      data.forEach((row) {
        sheet.appendRow([
          row[columnName],
          row[columnBarcode],
          row[columnBuilding],
          row[columnFloor],
          row[columnZone],
          row[columnReference]
        ]);
      });
      final excelFileName = 'scann_data.xlsx';
      final excelFilePath = await _getFilePath(excelFileName);
      // Write the Excel file
      final excelBytes = await excel.encode();
      if (excelBytes != null) {
        final file = File(excelFilePath);
        await file.writeAsBytes(excelBytes);
        print('Fichier Excel généré avec succès dans : $excelFilePath');
        return excelFilePath;
      } else {
        print('Error exporting Excel data: excelBytes is null');
        return null;
      }


    } else {
      print('No data to export');
      return null;
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, fileName);
  }
}
