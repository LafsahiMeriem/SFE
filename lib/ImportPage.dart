import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
    if (await Permission.storage.request().isGranted) {
      try {
        List<Map<String, dynamic>> produits = await _databaseHelper.getProduits();

        // Debugging: Print the retrieved products
        print("Retrieved products: $produits");

        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Produits'];

        // Ajouter les en-têtes de colonnes (facultatif, mais recommandé)
        sheetObject.appendRow(['Nom du produit', 'Code barre', 'Etage', 'Zone', 'Batiment', 'Bureau']);

        // Ajouter les produits
        for (var produit in produits) {
          sheetObject.appendRow([
            produit['name'] ?? '',
            produit['barcode'] ?? '',
            produit['floor_id']?.toString() ?? '',
            produit['zone_id']?.toString() ?? '',
            produit['building_id']?.toString() ?? '',
            produit['office_id']?.toString() ?? ''
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Importer Produits', style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => exportToFile(context),
          child: Text('Importer le fichier Excel'),
        ),
      ),
    );
  }
}