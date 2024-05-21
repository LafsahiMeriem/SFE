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
      appBar: AppBar(
        title: Text('Encoder Page'),
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
      appBar: AppBar(
        title: Text('Produits avec code barre'),
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
                return Card(
                  color: Color(0xFFFF6E40),
                  child: ListTile(
                    title: Text(product['name']),
                    subtitle: Text('Code barre: ${product['barcode']}'),
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

class ProductWithoutCodePage extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    return await dbHelper.selectData(sql: "SELECT * FROM ${DatabaseHelper.ProductsTable} WHERE barcode = '' OR barcode IS NULL");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produits sans code barre'),
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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                return Card(
                  color: Color(0xFFFF6E40),
                  child: ListTile(
                    title: Text(product['name']),
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
