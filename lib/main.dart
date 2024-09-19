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

class _LogoMenuPageState extends State<LogoMenuPage> with SingleTickerProviderStateMixin {
  bool _showMenu = false;
  late AnimationController _controller;
  late Animation<double> _textAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Define animations
    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Show the menu after a delay of 20 seconds
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _showMenu = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeTransition(
              opacity: _textAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bienvenue dans notre application',
                  style: TextStyle(
                    fontFamily: 'Roboto',
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
            ),
            SizedBox(
              height: 20,
            ),
            SlideTransition(
              position: _logoAnimation.drive(
                Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, 0.1),
                ),
              ),
              child: Image.asset('assets/logo.png'),
            ),
          ],
        ),
      ),
    );
  }
}



class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(begin: Colors.white, end: Colors.amber).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 25), // Adjust this value to lower or raise the title
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Text(
                  'Menu Page',
                  style: TextStyle(
                    color: _colorAnimation.value,
                    fontFamily: 'Roboto', // Change to your preferred font
                    fontSize: 29, // Increased font size
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        offset: const Offset(2.0, 2.0),
                        blurRadius: 6.0, // Increased blur radius
                        color: Color(0x80000000), // Semi-transparent black
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0, // Remove shadow under the AppBar
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0), // Add padding to move buttons down
        child: GridView.count(
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
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData iconData, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber, Colors.brown],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(1.05),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    offset: const Offset(1.0, 1.0),
                    blurRadius: 2.0,
                    color: Color(0x80000000), // Semi-transparent black
                  ),
                ],
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
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  String? _selectedBuildingId;
  String? _selectedZoneId;
  String? _selectedFloorId;
  String? _selectedOfficeId;

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(color: Colors.white24),
          ),
          filled: true,
          fillColor: Colors.black,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          prefixIcon: Icon(Icons.text_fields, color: Colors.white70),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDropdownField(String labelText, Future<List<Map<String, dynamic>>> items, String? selectedValue, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                  child: Text(name, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                filled: true,
                fillColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              dropdownColor: Colors.black,
              style: TextStyle(color: Colors.white),
            );
          }
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
          SnackBar(
            content: Text('Le code barre existe déjà pour un produit, veuillez entrer un autre code barre.'),
            backgroundColor: Colors.red[600],
          ),
        );
      } else {
        await DatabaseHelper.instance.insertProduct(
            product, barcode, selectedBuildingId, selectedZoneId, selectedFloorId, selectedOfficeId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit ajouté avec succès.'),
            backgroundColor: Colors.green[600],
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
        SnackBar(
          content: Text('Certaines informations manquent. Le produit sera quand même ajouté.'),
          backgroundColor: Colors.yellow[600],
        ),
      );

      await DatabaseHelper.instance.insertProduct(
          product, barcode, selectedBuildingId ?? '', selectedZoneId ?? '', selectedFloorId ?? '', selectedOfficeId ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit ajouté avec succès.'),
          backgroundColor: Colors.green[600],
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),  // Ajustez ce padding pour déplacer le titre
          child: Text(
            'Ajouter',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(child: Image.asset('assets/building_image.png')),
            SizedBox(height: 16.0),
            Text('Ajouter un produit', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 16.0),
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
            SizedBox(height: 24.0),
            _buildButton(context, 'Ajouter', _ajouterProduit),
          ],
        ),
      ),
    );
  }
}