import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'EncoderPage.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        hintColor: Colors.deepOrangeAccent,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
          ),
        ),
        textTheme: const TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
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
    // Show the menu after a delay of 3 seconds
    Future.delayed(const Duration(seconds: 8), () {
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
      body: _showMenu
          ? const MenuPage()
          : Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo.png'), // Replace 'assets/logo.png' with your logo image path
            fit: BoxFit.cover, // Cover the whole area
          ),
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
          color: Theme.of(context).primaryColor,
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
              style: Theme.of(context).textTheme.headline6,
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Produit', _productController),
              const SizedBox(height: 16),
              _buildTextField('Code barre', _barcodeController),
              const SizedBox(height: 16),
              _buildTextField('Bâtiment', _buildingController),
              const SizedBox(height: 16),
              _buildTextField('Étage', _floorController),
              const SizedBox(height: 16),
              _buildTextField('Zone', _zoneController),
              const SizedBox(height: 16),
              _buildTextField('Référence', _referenceController),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _ajouter,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }

  void _ajouter() async {
    final String product = _productController.text;
    final String barcode = _barcodeController.text;
    final String building = _buildingController.text;
    final String floor = _floorController.text;
    final String zone = _zoneController.text;
    final String reference = _referenceController.text;

    await DatabaseHelper.instance.insert({
      'name': product,
      'barcode': barcode,
      'building': building,
      'floor': floor,
      'zone': zone,
      'reference': reference,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Données insérées dans la base de données.'),
      ),
    );

    _productController.clear();
    _barcodeController.clear();
    _buildingController.clear();
    _floorController.clear();
    _zoneController.clear();
    _referenceController.clear();
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
    }),
  )
      .then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan démarré'),
        duration: Duration(seconds: 1),
      ),
    );
  });
}
