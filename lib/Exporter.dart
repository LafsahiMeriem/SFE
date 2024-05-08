import 'package:flutter/material.dart';

class Exporter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exporter'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {

          },
          child: Text('Exporter'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Exporter(),
  ));
}
