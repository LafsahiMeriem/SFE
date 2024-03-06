import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // Afficher le menu après un délai de 5 secondes
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
                'assets/logo.png', // Remplacez 'assets/logo.png' par le chemin de votre image de logo
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
        crossAxisCount: 2, // Nombre de colonnes dans le GridView
        padding: const EdgeInsets.all(16), // Marge autour des éléments
        crossAxisSpacing: 16, // Espace horizontal entre les éléments
        mainAxisSpacing: 16, // Espace vertical entre les éléments
        children: [
          _buildMenuItem(context, 'Ajouter', Icons.add, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPage()),
            );
          }),
          _buildMenuItem(context, 'Importer', Icons.file_upload, () {}),
          _buildMenuItem(context, 'Encoder', Icons.qr_code, () {}),
          _buildMenuItem(context, 'Scan', Icons.qr_code_scanner, () {
            // Lancer le scan du code barre ou du QR code
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
          color: Colors.deepPurple, // Couleur de fond du carré
          borderRadius: BorderRadius.circular(8), // Bord arrondi du carré
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: Colors.white, // Couleur de l'icône
              size: 48, // Taille de l'icône
            ),
            const SizedBox(
                height: 8), // Espace vertical entre l'icône et le texte
            Text(
              title,
              style: const TextStyle(
                color: Colors.white, // Couleur du texte
                fontSize: 18, // Taille du texte
                fontWeight: FontWeight.bold, // Style du texte
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
                  // Ajouter ici la logique pour traiter le formulaire
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
  methodChannel.invokeMethod(
      'sendDataWedgeCommandStringParameter',
      jsonEncode({
        "command": "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER",
        "parameter": "START_SCANNING"
      })).then((_) {
    // Afficher un SnackBar pour indiquer que le scan a été démarré
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scan démarré'),
        duration: Duration(seconds: 1),
      ),
    );
  });
}
