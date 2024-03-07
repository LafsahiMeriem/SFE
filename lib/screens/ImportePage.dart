import 'package:flutter/material.dart';
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
              onPressed: () {
                // Action à exécuter lors du clic sur le bouton d'importation
                importDataFromDatabase(context);
              },
              icon: Icon(Icons.file_upload),
              label: Text('Importer un fichier'),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour importer les données à partir de la base de données
  void importDataFromDatabase(BuildContext context) async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.queryAll();

    // Assurez-vous qu'il y a des données dans la base de données
    if (data.isNotEmpty) {
      // Traitement des données ici, par exemple, enregistrer dans un fichier
      // Exemple : Enregistrer les données dans un fichier texte
      String dataAsString = '';
      data.forEach((row) {
        dataAsString += row.toString() + '\n';
      });

      // Vous pouvez maintenant utiliser les donnéesAsString comme vous le souhaitez
      // Par exemple, vous pouvez enregistrer les données dans un fichier texte
      // ou les afficher dans une fenêtre de dialogue
      print(dataAsString);

      // Exemple d'affichage des données dans une fenêtre de dialogue
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Données importées'),
            content: Text('Les données ont été importées avec succès.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Si la base de données est vide
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Aucune donnée'),
            content: Text('La base de données est vide.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
