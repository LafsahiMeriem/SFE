import 'package:flutter/material.dart';
import 'database_helper.dart';

class EncodePage extends StatefulWidget {
  const EncodePage({Key? key}) : super(key: key);

  @override
  _EncodePageState createState() => _EncodePageState();
}

class _EncodePageState extends State<EncodePage> {
  late TextEditingController _searchController;
  List<String> buildings = ['building tech', 'building marjan', 'building Marjane'];
  List<String> floors = ['floor 1', 'floor 2', 'floor 3'];
  List<String> zones = ['zone droit', 'zone gauche', 'zone 1', 'zone 2', 'zone 3'];
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encoder'),
      ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Chercher un produit...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    _searchProduct(context, value);
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(''),
              // Ajouter un espace en bas pour laisser de la place à la barre de navigation inférieure
              const SizedBox(height: 80),
            ],
          ),
        ),

      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60, // Ajustez cette valeur selon vos besoins
          child: EncoderBottomBar(
            onEncodePressed: () {
              _searchProductWithBarcode(context);
            },
            onNonEncodePressed: () {
              _showFilterDialog(context);
            },
          ),
        ),
      ),

    );
  }

  void _searchProduct(BuildContext context, String productName) async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();

    List<Map<String, dynamic>> filteredProducts = products.where((product) =>
        product[DatabaseHelper.columnName].toString().toLowerCase().contains(
            productName.toLowerCase())
    ).toList();

    _showProductsDialog(context, filteredProducts);
  }

  void _searchProductWithBarcode(BuildContext context) async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();

    List<Map<String, dynamic>> filteredProducts = products.where((product) =>
    product[DatabaseHelper.columnBarcode]
        .toString()
        .isNotEmpty
    ).toList();

    _showProductsDialog(context, filteredProducts);
  }

  void _showProductsDialog(BuildContext context,
      List<Map<String, dynamic>> products) {
    if (products.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Product Information'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: products.map((product) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Name: ${product[DatabaseHelper
                          .columnName]}'),
                      Text('Barcode: ${product[DatabaseHelper.columnBarcode]}'),
                      Text('Building: ${product[DatabaseHelper
                          .columnBuilding]}'),
                      Text('Floor: ${product[DatabaseHelper.columnFloor]}'),
                      Text('Zone: ${product[DatabaseHelper.columnZone]}'),
                      Text('Reference: ${product[DatabaseHelper
                          .columnReference]}'),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Product Not Found'),
            content: const Text(
                'No product found with the specified condition.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showFilterDialog(BuildContext context) {
    String selectedBuilding = buildings.first;
    String selectedFloor = floors.first;
    String selectedZone = zones.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBuilding,
                items: buildings.map((String building) {
                  return DropdownMenuItem<String>(
                    value: building,
                    child: Text(building),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBuilding = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedFloor,
                items: floors.map((String floor) {
                  return DropdownMenuItem<String>(
                    value: floor,
                    child: Text(floor),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFloor = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedZone,
                items: zones.map((String zone) {
                  return DropdownMenuItem<String>(
                    value: zone,
                    child: Text(zone),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedZone = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _filterProducts(selectedBuilding, selectedFloor, selectedZone);
                Navigator.pop(context);
              },
              child: Text('Filter'),
            ),
          ],
        );
      },
    );
  }

  void _filterProducts(String building, String floor, String zone) async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();

    List<Map<String, dynamic>> filteredProducts = products.where((product) =>
    product[DatabaseHelper.columnBuilding] == building &&
        product[DatabaseHelper.columnFloor] == floor &&
        product[DatabaseHelper.columnZone] == zone &&
        (product[DatabaseHelper.columnBarcode] == null ||
            product[DatabaseHelper.columnBarcode]
                .toString()
                .isEmpty)
    ).toList();

    if (filteredProducts.isEmpty) {
      // Si aucun produit n'est trouvé, incluez également ceux avec des valeurs nulles ou vides dans la colonne du code-barres
      filteredProducts = products.where((product) =>
      product[DatabaseHelper.columnBuilding] == building &&
          product[DatabaseHelper.columnFloor] == floor &&
          product[DatabaseHelper.columnZone] == zone &&
          (product[DatabaseHelper.columnBarcode] == null ||
              product[DatabaseHelper.columnBarcode]
                  .toString()
                  .isEmpty) &&
          (product[DatabaseHelper.columnName] == null ||
              product[DatabaseHelper.columnName]
                  .toString()
                  .isEmpty) &&
          (product[DatabaseHelper.columnReference] == null ||
              product[DatabaseHelper.columnReference]
                  .toString()
                  .isEmpty)
      ).toList();
    }

    _showProductsDialog(context, filteredProducts);
  }
}


class EncoderBottomBar extends StatelessWidget {
  final VoidCallback onEncodePressed;
  final VoidCallback onNonEncodePressed;

  const EncoderBottomBar({Key? key, required this.onEncodePressed, required this.onNonEncodePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomBarItem(
            icon: Icons.search,
            label: 'Chercher',
            onPressed: () {
              // Add logic for search action
            },
          ),
          _buildBottomBarItem(
            icon: Icons.qr_code,
            label: 'Encoder',
            onPressed: onEncodePressed,
          ),
          _buildBottomBarItem(
            icon: Icons.qr_code_outlined,
            label: 'Non-Encoder',
            onPressed: onNonEncodePressed,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60,
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
          ),

          Text(
            label,
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: EncodePage(),
  ));
}
