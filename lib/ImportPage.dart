import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart'; // Pour importer des polices Google
import 'package:animate_do/animate_do.dart'; // Pour les animations
import 'database_helper.dart';

class ImporterPage extends StatefulWidget {
  @override
  _ImporterPageState createState() => _ImporterPageState();
}

class _ImporterPageState extends State<ImporterPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = false;

  Future<void> exportToFile(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<Map<String, dynamic>> produits = await _databaseHelper.getProduits();
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Produits'];

        sheetObject.appendRow(['Nom du produit', 'Code barre', 'Etage', 'Zone', 'Batiment', 'Bureau']);

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

        final directory = await getExternalStorageDirectory();
        String filePath = '${directory!.path}/produits.xlsx';
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.encode()!);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 10),
              Text('Produits exportés avec succès vers $filePath'),
            ],
          ),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Erreur lors de l\'exportation des produits: $e'),
            ],
          ),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Permission de stockage refusée'),
          ],
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown, Colors.amber],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Padding( // Ajout de padding ici
          padding: const EdgeInsets.only(top: 20),
          child: FadeIn( // Animation du titre
            duration: Duration(seconds: 2),
            child: Text(
              'Importer Produits',
              style: GoogleFonts.poppins( // Utilisation d'une police plus moderne
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ],
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 10,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown, Colors.amber[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: _isLoading
                ? SpinKitFadingCircle(
              color: Colors.amber,
              size: 50.0,
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_upload,
                  color: Colors.amber[300],
                  size: 100,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                  ),
                  onPressed: () => exportToFile(context),
                  child: Text(
                    'Importer le fichier Excel',
                    style: TextStyle(
                      color: Colors.brown[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}