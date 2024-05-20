import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart'; // Assurez-vous que ce chemin est correct

class ImporterPage extends StatefulWidget {
  @override
  _ImporterPageState createState() => _ImporterPageState();
}

class _ImporterPageState extends State<ImporterPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> exportToFile(BuildContext context) async {
    // Demander la permission de lire/écrire les fichiers
    if (await Permission.storage.request().isGranted) {
      try {
        List<Map<String, dynamic>> produits = await _databaseHelper.getProduits();

        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Produits'];

        // Ajouter les en-têtes
        sheetObject.appendRow([
          'Name', 'Barcode', 'Building ID', 'Zone ID', 'Floor ID', 'Office ID'
        ]);

        // Ajouter les produits
        for (var produit in produits) {
          sheetObject.appendRow([
            produit['name'],
            produit['barcode'],
            produit['building_id'],
            produit['zone_id'],
            produit['floor_id'],
            produit['office_id']
          ]);
        }

        // Enregistrer le fichier Excel
        final directory = await getExternalStorageDirectory();
        String filePath = '${directory!.path}/produits.xlsx';
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.encode()!);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Produits exportés avec succès vers $filePath'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de l\'exportation des produits: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Permission de stockage refusée'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exporter Produits'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => exportToFile(context),
          child: Text('Exporter vers fichier Excel'),
        ),
      ),
    );
  }
}
