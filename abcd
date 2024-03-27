// import 'package:flutter/material.dart';
// import 'database_helper.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
//
// class EncodePage extends StatefulWidget {
//   const EncodePage({Key? key}) : super(key: key);
//
//   @override
//   _EncodePageState createState() => _EncodePageState();
// }
//
// class _EncodePageState extends State<EncodePage> {
//   late TextEditingController _searchController;
//   late TextEditingController _barcodeController;
//   List<String> buildings = ['building tech', 'building marjan', 'building Marjane'];
//   List<String> floors = ['floor 1', 'floor 2', 'floor 3'];
//   List<String> zones = ['zone droit', 'zone gauche', 'zone 1', 'zone 2', 'zone 3'];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
//     _barcodeController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _barcodeController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Encoder'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Chercher un produit...',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//                 onSubmitted: (value) {
//                   _searchProduct(context, value);
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(''),
//             // Ajouter un espace en bas pour laisser de la place à la barre de navigation inférieure
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//
//       bottomNavigationBar: BottomAppBar(
//         child: SizedBox(
//           height: 60,
//           child: EncoderBottomBar(
//             onEncodePressed: () {
//               _searchProductWithBarcode(context);
//             },
//             onNonEncodePressed: () {
//               _showProductsListWithEmptyBarcode(context);
//             },
//           ),
//         ),
//       ),
//
//     );
//   }
//
//   void _searchProduct(BuildContext context, String productName) async {
//     final DatabaseHelper dbHelper = DatabaseHelper.instance;
//     final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();
//
//     List<Map<String, dynamic>> filteredProducts = products.where((product) =>
//         product[DatabaseHelper.columnName].toString().toLowerCase().contains(
//             productName.toLowerCase())
//     ).toList();
//
//     _showProductsList(context, filteredProducts);
//   }
//
//   void _searchProductWithBarcode(BuildContext context) async {
//     final DatabaseHelper dbHelper = DatabaseHelper.instance;
//     final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();
//
//     List<Map<String, dynamic>> filteredProducts = products.where((product) =>
//     product[DatabaseHelper.columnBarcode]
//         .toString()
//         .isNotEmpty
//     ).toList();
//
//     _showProductsList(context, filteredProducts);
//   }
//
//   void _showProductsList(BuildContext context, List<Map<String, dynamic>> products) {
//     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Product Information'),
//           actions: [
//
//           ],
//         ),
//         body: ListView(
//           children: products.map((product) {
//             return ListTile(
//               title: Text('Name: ${product[DatabaseHelper.columnName]}'),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Barcode: ${product[DatabaseHelper.columnBarcode]}'),
//                   Text('Building: ${product[DatabaseHelper.columnBuilding]}'),
//                   Text('Floor: ${product[DatabaseHelper.columnFloor]}'),
//                   Text('Zone: ${product[DatabaseHelper.columnZone]}'),
//                   Text('Reference: ${product[DatabaseHelper.columnReference]}'),
//                 ],
//               ),
//               trailing: product[DatabaseHelper.columnBarcode].toString().isNotEmpty
//                   ? Icon(Icons.check, color: Colors.green)
//                   : Icon(Icons.close, color: Colors.red),
//               onTap: () {
//                 // Action when tapping on a product
//               },
//             );
//           }).toList(),
//         ),
//       );
//     }));
//   }
//
//
//   void _showProductsListWithEmptyBarcode(BuildContext context) async {
//     final DatabaseHelper dbHelper = DatabaseHelper.instance;
//     final List<Map<String, dynamic>> products = await dbHelper.queryAllRows();
//
//     List<Map<String, dynamic>> filteredProducts = products.where((product) =>
//     product[DatabaseHelper.columnBarcode] == null ||
//         product[DatabaseHelper.columnBarcode].toString().isEmpty
//     ).toList();
//
//     if (filteredProducts.isNotEmpty) {
//       // S'il y a des produits sans code-barres, afficher la liste des produits avec un bouton pour ajouter le code-barres
//       Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Product Information with Empty Barcode'),
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.refresh),
//                 onPressed: () {
//                   _refreshProductList(context);
//                 },
//               ),
//             ],
//           ),
//           body: ListView.builder(
//             itemCount: filteredProducts.length,
//             itemBuilder: (context, index) {
//               final product = filteredProducts[index];
//               return ListTile(
//                 title: Text('Name: ${product[DatabaseHelper.columnName]}'),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Building: ${product[DatabaseHelper.columnBuilding]}'),
//                     Text('Floor: ${product[DatabaseHelper.columnFloor]}'),
//                     Text('Zone: ${product[DatabaseHelper.columnZone]}'),
//                     Text('Reference: ${product[DatabaseHelper.columnReference]}'),
//                   ],
//                 ),
//                 trailing: IconButton(
//                   icon: Icon(Icons.qr_code_outlined),
//                   onPressed: () {
//                     _showBarcodeInputDialog(context, product); // Afficher l'AlertDialog avec le produit actuel
//                   },
//                 ),
//                 onTap: () {
//                   // Action when tapping on a product
//                 },
//               );
//             },
//           ),
//         );
//       }));
//     } else {
//       // S'il n'y a pas de produit sans code-barres, afficher simplement la liste des produits sans code-barres
//       _showProductsList(context, filteredProducts);
//     }
//   }
//
//
//   void _showBarcodeInputDialog(BuildContext context, Map<String, dynamic> product) {
//     TextEditingController _barcodeController = TextEditingController(); // Déplacer cette ligne ici pour éviter l'erreur
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Saisir le code-barres'),
//           content: TextField(
//             controller: _barcodeController,
//             keyboardType: TextInputType.number, // Changer le type de clavier pour numérique
//             decoration: InputDecoration(hintText: 'Entrez le code-barres'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Valider'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Fermer la boîte de dialogue
//                 _saveProductWithBarcode(context, product, _barcodeController.text);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _saveProductWithBarcode(BuildContext context, Map<String, dynamic> product, String barcode) async {
//     final DatabaseHelper dbHelper = DatabaseHelper.instance;
//     List<Map<String, dynamic>> products = await dbHelper.queryProductByBarcode(barcode);
//
//     if (products.isEmpty) {
//       // Aucun produit trouvé avec ce code-barres, vous pouvez maintenant insérer le produit
//       await dbHelper.insert({
//         DatabaseHelper.columnName: product[DatabaseHelper.columnName],
//         DatabaseHelper.columnBarcode: barcode,
//         DatabaseHelper.columnBuilding: product[DatabaseHelper.columnBuilding],
//         DatabaseHelper.columnFloor: product[DatabaseHelper.columnFloor],
//         DatabaseHelper.columnZone: product[DatabaseHelper.columnZone],
//         DatabaseHelper.columnReference: product[DatabaseHelper.columnReference],
//       });
//
//       // Maintenant, vous pouvez mettre à jour l'interface utilisateur en rafraîchissant la liste des produits
//       _refreshProductList(context);
//
//       // Afficher un message de confirmation
//       print('Produit avec code-barres $barcode inséré avec succès dans la base de données.');
//     } else {
//       // Un produit avec ce code-barres existe déjà, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
//       print('Un produit avec le code-barres $barcode existe déjà dans la base de données.');
//     }
//   }
//
//   void _refreshProductList(BuildContext context) {
//     // Rafraîchir l'interface en reconstruisant l'État de la page avec setState
//     setState(() {});
//   }
//
//
//
//
// }
//
//
//
// class EncoderBottomBar extends StatelessWidget {
//   final VoidCallback onEncodePressed;
//   final VoidCallback onNonEncodePressed;
//
//   const EncoderBottomBar({Key? key, required this.onEncodePressed, required this.onNonEncodePressed}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildBottomBarItem(
//             icon: Icons.search,
//             label: 'Chercher',
//             onPressed: () {
//               // Add logic for search action
//             },
//           ),
//           _buildBottomBarItem(
//             icon: Icons.qr_code,
//             label: 'Encoder',
//             onPressed: onEncodePressed,
//           ),
//           _buildBottomBarItem(
//             icon: Icons.qr_code_outlined,
//             label: 'Non-Encoder',
//             onPressed: onNonEncodePressed,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomBarItem({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       height: 60,
//       child: Column(
//         children: [
//           IconButton(
//             icon: Icon(icon),
//             onPressed: onPressed,
//           ),
//
//           Text(
//             label,
//             style: TextStyle(fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(const MaterialApp(
//     home: EncodePage(),
//   ));
// }
