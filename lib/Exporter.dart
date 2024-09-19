import 'package:flutter/material.dart';
import 'database_helper.dart';

class ProductsListScreen extends StatefulWidget {
  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  late Future<List<Map<String, dynamic>>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = DatabaseHelper.instance.getProduits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown, Colors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: Text('Products List', style: TextStyle(color: Colors.white, fontSize: 24)),
                elevation: 0,
                centerTitle: true,
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No products found.', style: TextStyle(color: Colors.white)));
                    } else {
                      final products = snapshot.data!;
                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigation vers un écran de détails ou autre action
                            },
                            child: ProductItem(product: product),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          // Gérer la navigation
        },
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amberAccent,
      margin: EdgeInsets.all(8.0),
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${product['name']}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            SizedBox(height: 4.0),
            Text('Code barre: ${product['barcode']}', style: TextStyle(color: Colors.brown)),
            Text('Bâtiment: ${product['building_id']}', style: TextStyle(color: Colors.brown)),
            Text('Zone: ${product['zone_id']}', style: TextStyle(color: Colors.brown)),
            Text('Étage: ${product['floor_id']}', style: TextStyle(color: Colors.brown)),
            Text('Bureau: ${product['office_id']}', style: TextStyle(color: Colors.brown)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.brown),
                  onPressed: () {
                    // Action pour modifier le produit
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Action pour supprimer le produit
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produit supprimé avec succès')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Exporter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Explorer', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductsListScreen()),
            );
          },
          child: Text('Parcourir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Exporter(),
    theme: ThemeData(
      // Definez votre thème ici
    ),
  ));
}
