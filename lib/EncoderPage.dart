import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Hauteur de l'AppBar personnalisée
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown, Colors.amber],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Rendre le fond transparent
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FadeIn( // Animation du titre
                duration: Duration(seconds: 2),
                child: Text(
                  'Sélection de Produits',
                  style: GoogleFonts.poppins( // Utilisation de la police Poppins
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ],
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0, // Supprimer l'ombre
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown, Colors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductWithCodePage()),
                  );
                },
                child: Text('Produits avec code barre', style: TextStyle(color: Colors.brown[900], fontSize: 18)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductWithoutCodePage()),
                  );
                },
                child: Text('Produits sans code barre', style: TextStyle(color: Colors.brown[900], fontSize: 18)),
              ),
            ],
          ),
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
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Padding( // Ajout de padding ici
          padding: const EdgeInsets.only(top: 20), // Ajustez la valeur selon vos besoins
          child: Text(
            'Produits avec code barre',
            style: TextStyle(
              color: Colors.white, // Changer la couleur du texte en blanc
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit avec code barre trouvé.'));
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
                    child: Icon(Icons.delete, color: Colors.white),
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
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 8,
                    child: ListTile(
                      title: Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
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
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Padding( // Ajout de padding ici
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Produits sans code barre',
            style: TextStyle(
              color: Colors.white, // Changer la couleur du texte en blanc
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit sans code barre trouvé.'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var product = snapshot.data![index];
                      String productName = product['name'];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        color: Color(0xFFFF6E40),
                        elevation: 8,
                        child: ListTile(
                          title: Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              _showBarcodeInputDialog(context, productName);
                            },
                            child: Text('Ajouter code-barres'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.amber,
                  onPressed: () {
                    setState(() {}); // Actualiser la page
                  },
                  child: Icon(Icons.refresh, color: Colors.brown[900]),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

