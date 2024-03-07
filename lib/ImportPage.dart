import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'database_helper.dart'; // Importez votre fichier database_helper.dart

class ImportPage extends StatelessWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sélectionnez un fichier à importer :',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                String? filePath = await exportDataToExcel();
                if (filePath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fichier Excel créé : $filePath'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la création du fichier Excel'),
                    ),
                  );
                }
              },
              icon: Icon(Icons.file_upload),
              label: Text('Importer un fichier'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> exportDataToExcel() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.instance.queryAll();

      // Créer un nouveau fichier Excel
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Ajouter les en-têtes de colonne
      sheet.appendRow(['ID', 'Name', 'Barcode', 'Building', 'Floor', 'Zone', 'Reference']);

      // Ajouter les données de la base de données au fichier Excel
      data.forEach((row) {
        sheet.appendRow([
          row['_id'],
          row['name'],
          row['barcode'],
          row['building'],
          row['floor'],
          row['zone'],
          row['reference'],
        ]);
      });

      // Enregistrer le fichier Excel dans le répertoire de téléchargement de l'application
      final String excelFileName = 'exported_data.xlsx';
      final String excelFilePath = await _getFilePath(excelFileName);
      await File(excelFilePath).writeAsBytes(await excel.encode() as List<int>);

      // Retourner le chemin du fichier Excel généré
      return excelFilePath;
    } catch (e) {
      print('Erreur lors de la création du fichier Excel: $e');
      return null;
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }
}
