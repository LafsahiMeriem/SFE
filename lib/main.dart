import 'dart:convert';

import 'package:datawedgeflutter/Csb.dart';
import 'package:datawedgeflutter/Exporter.dart';
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
        hintColor: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
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
    // Show the menu after a delay of 20 seconds
    Future.delayed(const Duration(seconds: 20), () {
      setState(() {
        _showMenu = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showMenu
          ? null
          : AppBar(
        title: const Text(''),
        backgroundColor: Colors.black,
      ),
      body: _showMenu
          ? const MenuPage()
          : Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo.png'),
            fit: BoxFit.contain, // Adjust fit as needed
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Bienvenue dans notre application',
                style: TextStyle(
                  fontFamily: 'Roboto', // Change to your preferred font
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: <Color>[Colors.amber, Colors.brown],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(3.0, 3.0),
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Image.asset('assets/logo.png'),
              ),
            ),
          ],
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Menu Page', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,

      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(15),
        crossAxisSpacing: 18,
        mainAxisSpacing: 40,
        children: [

          _buildMenuItem(context, 'Emplacement', Icons.location_on, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ParamPage()),
            );
          }),
          _buildMenuItem(context, 'Ajouter', Icons.add_box, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Ajouter()),
            );
          }),
          _buildMenuItem(context, 'Importer', Icons.archive, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImporterPage()),
            );
          }),
          _buildMenuItem(context, 'Encoder', Icons.qr_code, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EncoderPage()),
            );
          }),
          _buildMenuItem(context, 'InvChat', Icons.question_answer, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatBot()),
            );
          }),
          _buildMenuItem(context, 'Explorer', Icons.storage, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Exporter()),
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
            color: Colors.brown,
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
  String? _selectedBuildingId;
  String? _selectedZoneId;
  String? _selectedFloorId;
  String? _selectedOfficeId;

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
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  void _ajouterProduit() async {
    final String product = _productController.text;
    final String barcode = _barcodeController.text;
    final String? selectedBuildingId = _selectedBuildingId;
    final String? selectedZoneId = _selectedZoneId;
    final String? selectedFloorId = _selectedFloorId;
    final String? selectedOfficeId = _selectedOfficeId;

    if (product.isNotEmpty && barcode.isNotEmpty && selectedBuildingId != null &&
        selectedZoneId != null && selectedFloorId != null && selectedOfficeId != null) {

      bool exists = await DatabaseHelper.instance.barcodeExists(barcode);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le code barre existe déjà pour un produit, veuillez entrer un autre code barre.'),
          ),
        );
      } else {
        // Insérer les données du produit dans la base de données
        await DatabaseHelper.instance.insertProduct(
            product, barcode, selectedBuildingId, selectedZoneId, selectedFloorId, selectedOfficeId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit ajouté avec succès.'),
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
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certaines informations manquent. Le produit sera quand même ajouté.'),
        ),
      );

      // Insérer les données du produit dans la base de données même si certains champs sont vides
      await DatabaseHelper.instance.insertProduct(
          product, barcode, selectedBuildingId ?? '', selectedZoneId ?? '', selectedFloorId ?? '', selectedOfficeId ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit ajouté avec succès.'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ajouter', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/building_image.png'),
                _buildTextField('Produit', _productController),
                _buildTextField('Code barre', _barcodeController),
                _buildDropdownField('Bâtiment', DatabaseHelper.instance.getAllBuildings(), _selectedBuildingId, (value) {
                  setState(() {
                    _selectedBuildingId = value;
                    _selectedZoneId = null; // Reset dependent dropdown
                    _selectedFloorId = null; // Reset dependent dropdown
                    _selectedOfficeId = null; // Reset dependent dropdown
                  });
                }),
                _buildDropdownField('Zone', DatabaseHelper.instance.getZonesForBuilding(int.tryParse(_selectedBuildingId ?? '') ?? 0), _selectedZoneId, (value) {
                  setState(() {
                    _selectedZoneId = value;
                    _selectedFloorId = null; // Reset dependent dropdown
                    _selectedOfficeId = null; // Reset dependent dropdown
                  });
                }),
                _buildDropdownField('Étage', DatabaseHelper.instance.getFloorsForZone(int.tryParse(_selectedZoneId ?? '') ?? 0), _selectedFloorId, (value) {
                  setState(() {
                    _selectedFloorId = value;
                    _selectedOfficeId = null; // Reset dependent dropdown
                  });
                }),
                _buildDropdownField('Bureau', DatabaseHelper.instance.getOfficesForFloor(int.tryParse(_selectedFloorId ?? '') ?? 1), _selectedOfficeId, (value) {
                  setState(() {
                    _selectedOfficeId = value;
                  });
                }),
                const SizedBox(height: 17),
                _buildButton(context, 'Ajouter', _ajouterProduit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

