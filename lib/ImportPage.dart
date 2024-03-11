import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'database_helper.dart'; // Importez votre fichier database_helper.dart
import 'package:csv/csv.dart';

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
                String? filePath = await exportDataToCSV();
                if (filePath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fichier CSV créé : $filePath'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la création du fichier CSV'),
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

  Future<String?> exportDataToCSV() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.instance.queryAll();

      // Convertir la liste de maps en une liste de listes de données dynamiques
      List<List<dynamic>> csvData = data.map((e) => e.values.toList()).toList();

      // Créer un nouveau fichier CSV
      final String csvFileName = 'exported_data.csv';
      final String csvFilePath = await _getFilePath(csvFileName);
      File csvFile = File(csvFilePath);
      String csvString = const ListToCsvConverter().convert(csvData);

      // Écrire les données dans le fichier CSV
      await csvFile.writeAsString(csvString);

      // Retourner le chemin du fichier CSV généré
      return csvFilePath;
    } catch (e) {
      print('Erreur lors de la création du fichier CSV: $e');
      return null;
    }
  }
  Future<String> _getFilePath(String fileName) async {
    final Directory? directory = await getExternalStorageDirectory();
    return '${directory!.path}/$fileName';
  }
}
