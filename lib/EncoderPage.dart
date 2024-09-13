import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encoder Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EncoderPage(),
    );
  }
}

class EncoderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Encoder Page', style: TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductWithCodePage()),
                );
              },
              child: Text('Produits avec code barre'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductWithoutCodePage()),
                );
              },
              child: Text('Produits sans code barre'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductWithCodePage extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    return await dbHelper.selectData(sql: "SELECT * FROM ${DatabaseHelper.ProductsTable} WHERE barcode != '' AND barcode IS NOT NULL");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Produits avec code barre', style: TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit avec code barre trouvé.', style: TextStyle(color: Colors.white),));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                return Dismissible(
                  key: Key(product['name']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirmer la suppression"),
                          content: Text("Voulez-vous supprimer ce produit ?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text("Supprimer"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    dbHelper.deleteProduct(product['name']);
                  },
                  child: Card(
                    color: Color(0xFFFF6E40),
                    child: ListTile(
                      title: Text(product['name']),
                      subtitle: Text('Code barre: ${product['barcode']}'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
class ProductWithoutCodePage extends StatefulWidget {
  @override
  _ProductWithoutCodePageState createState() => _ProductWithoutCodePageState();
}

class _ProductWithoutCodePageState extends State<ProductWithoutCodePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    return await dbHelper.selectData(sql: "SELECT * FROM ${DatabaseHelper.ProductsTable} WHERE barcode = '' OR barcode IS NULL");
  }

  Future<void> _showBarcodeInputDialog(BuildContext context, String productName) async {
    String barcode = '';
    bool barcodeExists = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un code-barres pour $productName'),
          content: TextField(
            onChanged: (value) => barcode = value,
            decoration: InputDecoration(hintText: 'Entrez le code-barres'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                barcodeExists = await dbHelper.barcodeExists(barcode);
                if (barcodeExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Le code-barres existe déjà.'),
                    ),
                  );
                } else {
                  await dbHelper.moveProductToWithCodePage(productName, barcode);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Produits sans code barre', style: TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit sans code barre trouvé.', style: TextStyle(color: Colors.white),));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var product = snapshot.data![index];
                      String productName = product['name'];
                      return ListTile(
                        title: Text(productName),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _showBarcodeInputDialog(context, productName);
                          },
                          child: Text('Ajouter code-barres'),
                        ),
                      );
                    },
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    // Recharger la liste des produits
                    setState(() {}); // Actualiser la page
                  },
                  child: Icon(Icons.refresh),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}