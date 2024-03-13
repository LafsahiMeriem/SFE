import 'package:flutter/material.dart';
import 'database_helper.dart';

class EncodePage extends StatefulWidget {
  const EncodePage({Key? key}) : super(key: key);

  @override
  _EncodePageState createState() => _EncodePageState();
}

class _EncodePageState extends State<EncodePage> {
  late TextEditingController _searchController;

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
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Add some spacing
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
            const SizedBox(height: 20), // Add some spacing
            const Text('Encoder Page'),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          child: Container(
            height: 60, // Set the height of the BottomAppBar
            child: EncoderBottomBar(
              onEncodePressed: () {
                _searchProductWithBarcode(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _searchProduct(BuildContext context, String productName) async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();

    // Filter products based on the productName
    List<Map<String, dynamic>> filteredProducts = products.where((product) =>
        product[DatabaseHelper.columnName].toString().toLowerCase().contains(productName.toLowerCase())
    ).toList();

    _showProductsDialog(context, filteredProducts);
  }

  void _searchProductWithBarcode(BuildContext context) async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();

    // Filter products with non-empty barcode
    List<Map<String, dynamic>> filteredProducts = products.where((product) =>
    product[DatabaseHelper.columnBarcode].toString().isNotEmpty
    ).toList();

    _showProductsDialog(context, filteredProducts);
  }

  void _showProductsDialog(BuildContext context, List<Map<String, dynamic>> products) {
    if (products.isNotEmpty) {
      // Display information of the products
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Product Information'),
            content: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: products.map((product) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Name: ${product[DatabaseHelper.columnName]}'),
                      Text('Barcode: ${product[DatabaseHelper.columnBarcode]}'),
                      Text('Building: ${product[DatabaseHelper.columnBuilding]}'),
                      Text('Floor: ${product[DatabaseHelper.columnFloor]}'),
                      Text('Zone: ${product[DatabaseHelper.columnZone]}'),
                      Text('Reference: ${product[DatabaseHelper.columnReference]}'),
                      const Divider(), // Add a divider between products
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
      // Display a message if no product found
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Product Not Found'),
            content: const Text('No product found with the specified condition.'),
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
}

class EncoderBottomBar extends StatelessWidget {
  final VoidCallback onEncodePressed;

  const EncoderBottomBar({Key? key, required this.onEncodePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
          onPressed: () {
            // Add logic for non-encoding action
          },
        ),
      ],
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12), // Adjust the font size as needed
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: EncodePage(),
  ));
}