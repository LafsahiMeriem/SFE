import 'package:datawedgeflutter/database_helper.dart';
import 'package:flutter/material.dart';



class EncoderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encoder Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Action à effectuer lorsque le bouton est pressé
            print('Bouton pressé !');
            DatabaseHelper.instance.deleteDatabaseFile();
          },
          child: Text('Appuyez ici'),
        ),
      ),
    );
  }
}
