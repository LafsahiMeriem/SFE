import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'EncoderPage.dart';

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPage()),
            );
          }),
          _buildMenuItem(context, 'Importer', Icons.file_upload, () {}),
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

class AddPage extends StatefulWidget {
  const AddPage({Key? key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController _productController = TextEditingController();
  TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _productController.dispose();
    _barcodeController.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _productController,
                decoration: InputDecoration(labelText: 'Produit'),
              ),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(labelText: 'Code barre'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bâtiment'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Étage'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Zone'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Référence'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add logic here to handle the form
                },
                child: Text('Ajouter'),
              ),
            ],
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
      SnackBar(
        content: Text('Scan démarré'),
        duration: Duration(seconds: 1),
      ),
    );
  });
}