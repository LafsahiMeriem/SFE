import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'database_helper.dart'; // Importez votre fichier database_helper.dart
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  List<String> _filePaths = [];

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
            ElevatedButton(
              onPressed: () async {
                await _requestPermissionAndPickFiles();
              },
              child: Text('Importer un fichier'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filePaths.length,
                itemBuilder: (context, index) {
                  final filePath = _filePaths[index];
                  return ListTile(
                    title: Text(filePath.split('/').last),
                    onTap: () {
                      _openFile(filePath);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermissionAndPickFiles() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      List<String>? filePaths = await pickFiles();
      if (filePaths != null) {
        setState(() {
          _filePaths = filePaths;
        });
      }
    } else {
      // L'utilisateur a refusé la permission, affichez un message ou effectuez une action appropriée
      print('Permission refusée');
    }
  }

  Future<List<String>?> pickFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );

      if (result != null) {
        List<String> filePaths = result.paths.map((path) => path!).toList();
        return filePaths;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la sélection des fichiers: $e');
      return null;
    }
  }

  void _openFile(String filePath) {
    // Ici, vous pouvez implémenter la logique pour ouvrir le fichier
    // Par exemple, vous pouvez utiliser la bibliothèque native pour ouvrir le fichier
    // Ou vous pouvez utiliser une bibliothèque Flutter tierce si disponible
    print('Ouverture du fichier: $filePath');
  }
}