import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'EncoderPage.dart';
import 'ImportPage.dart';
import 'database_helper.dart';
import 'ParamPage.dart';
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
        padding: const EdgeInsets.all(15),
        crossAxisSpacing: 16,
        mainAxisSpacing: 17,
        children: [
          _buildMenuItem(context, 'Ajouter', Icons.add, () {
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
              MaterialPageRoute(builder: (context) => EncoderPage()),
            );
          }),
          _buildMenuItem(context, 'Scan', Icons.qr_code_scanner, () {
            // Start barcode or QR code scan
            startScan(context);
          }),
          _buildMenuItem(context, 'Exporter', Icons.file_download, () {}),
          _buildMenuItem(context, 'Paramètre', Icons.settings, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ParamPage()),
            );
          }),
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
          borderRadius: BorderRadius.circular(25),
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
              height: 10,
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
  int? _selectedBuildingId;
  int? _selectedZoneId;
  int? _selectedFloorId;
  int? _selectedOfficeId;

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String labelText, Future<List<Map<String, dynamic>>> items, String? selectedValue, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> data = snapshot.data ?? [];
            List<String> names = data.map((e) => e['name'].toString()).toList();
            return DropdownButtonFormField<String>(
              value: selectedValue,
              onChanged: onChanged,
              items: names.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: labelText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  void _ajouter() async {
    final String product = _productController.text;
    final String barcode = _barcodeController.text;

    final int? selectedBuildingId = _selectedBuildingId as int?;
    final int? selectedZoneId = _selectedZoneId as int?;
    final int? selectedFloorId = _selectedFloorId as int?;
    final int? selectedOfficeId = _selectedOfficeId as int?;

    if (selectedBuildingId != null &&
        selectedZoneId != null &&
        selectedFloorId != null &&
        selectedOfficeId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données insérées dans la base de données.'),
        ),
      );

      _productController.clear();
      _barcodeController.clear();
      setState(() {
        _selectedBuildingId = null;
        _selectedZoneId = null;
        _selectedFloorId = null;
        _selectedOfficeId = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une valeur pour chaque champ.'),
        ),
      );
    }
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
              _buildTextField('Code barre', _barcodeController),
              _buildDropdownField('Bâtiment', DatabaseHelper.instance.getAllBuildings(), _selectedBuildingId as String?, (value) {
                setState(() {
                  _selectedBuildingId = (value as int);
                });
              }),
              _buildDropdownField('Zone', DatabaseHelper.instance.getZonesForBuilding(_selectedBuildingId ?? 0), _selectedZoneId as String?, (value) {
                setState(() {
                  _selectedZoneId = (value as int);
                });
              }),
              _buildDropdownField('Étage', DatabaseHelper.instance.getFloorsForZone(_selectedZoneId ?? 0), _selectedFloorId as String?, (value) {
                setState(() {
                  _selectedFloorId = (value as int);
                });
              }),
              _buildDropdownField('Bureau', DatabaseHelper.instance.getOfficesForFloor(_selectedFloorId ?? 0), _selectedOfficeId as String?, (value) {
                setState(() {
                  _selectedOfficeId = (value as int);
                });
              }),
              const SizedBox(height: 32),
              _buildButton(context, 'Ajouter', _ajouter),
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