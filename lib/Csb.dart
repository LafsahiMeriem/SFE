import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Formulaire',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Csb(),
    );
  }
}

class Csb extends StatefulWidget {
  @override
  _CsbState createState() => _CsbState();
}

class _CsbState extends State<Csb> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _adresseController = TextEditingController();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(

                controller: _adresseController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer adresse';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Login',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre nom nom d utilisateur';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le mot de passe ';
                  }
                  return null;
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('connexion soumis avec succès')),
                      );
                    }
                  },
                  child: Text(''),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
