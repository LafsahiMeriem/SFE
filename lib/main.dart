import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datawedgeflutter/EncoderPage.dart';
import 'ImportPage.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const LogoMenuPage(),
    );
  }
}

class LogoMenuPage extends StatefulWidget {
  const LogoMenuPage({Key? key});

  @override
  _LogoMenuPageState createState() => _LogoMenuPageState();
}

class _LogoMenuPageState extends State<LogoMenuPage> {
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    // Show the menu after a delay of 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showMenu = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showMenu
          ? null
          : AppBar(
        title: const Text('Scanner Application'),
      ),
      body: Center(
        child: _showMenu
            ? const MenuPage()
            : Image.asset(
          'assets/logo.png', // Replace 'assets/logo.png' with your logo image path
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Page'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuItem(context, 'Ajouter', Icons.add, () {
            // Navigate to the Ajouter page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Ajouter()),
            );
          }),
          _buildMenuItem(context, 'Importer', Icons.file_upload, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImportPage()),
            );
          }),
          _buildMenuItem(context, 'Encoder', Icons.qr_code, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EncodePage()),
            );
          }),
          _buildMenuItem(context, 'Scan', Icons.qr_code_scanner, () {
            // Start barcode or QR code scan
            startScan(context);
          }),
          _buildMenuItem(context, 'Exporter', Icons.file_download, () {}),
          _buildMenuItem(context, 'Paramètre', Icons.settings, () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData iconData,
      Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Ajouter extends StatefulWidget {
  const Ajouter({Key? key}) : super(key: key);

  @override
  _AjouterState createState() => _AjouterState();
}

class _AjouterState extends State<Ajouter> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _productController.dispose();
    _barcodeController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _zoneController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _productController,
                  decoration: const InputDecoration(labelText: 'Produit'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom du produit';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(labelText: 'Code barre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le code barre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _buildingController,
                  decoration: const InputDecoration(labelText: 'Bâtiment'),
                ),
                TextFormField(
                  controller: _floorController,
                  decoration: const InputDecoration(labelText: 'Étage'),
                ),
                TextFormField(
                  controller: _zoneController,
                  decoration: const InputDecoration(labelText: 'Zone'),
                ),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(labelText: 'Référence'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Get the values from the text fields
                      final String product = _productController.text;
                      final String barcode = _barcodeController.text;
                      final String building = _buildingController.text;
                      final String floor = _floorController.text;
                      final String zone = _zoneController.text;
                      final String reference = _referenceController.text;

                      // Insert data into the database
                      DatabaseHelper.instance.insert({
                        'name': product,
                        'barcode': barcode,
                        'building': building,
                        'floor': floor,
                        'zone': zone,
                        'reference': reference,
                      }).then((_) {
                        // Show a snackbar to indicate successful insertion
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data inserted into database.'),
                          ),
                        );

                        // Clear text fields after submission
                        _productController.clear();
                        _barcodeController.clear();
                        _buildingController.clear();
                        _floorController.clear();
                        _zoneController.clear();
                        _referenceController.clear();
                      });
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void startScan(BuildContext context) {
  const MethodChannel methodChannel =
  MethodChannel('com.darryncampbell.datawedgeflutter/command');
  methodChannel
      .invokeMethod(
      'sendDataWedgeCommandStringParameter',
      jsonEncode({
        "command": "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER",
        "parameter": "START_SCANNING"
      }))
      .then((_) {
    // Show a SnackBar to indicate that the scan has started
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan démarré'),
        duration: Duration(seconds: 1),
      ),
    );
  });
}
