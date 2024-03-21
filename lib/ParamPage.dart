import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParamPage extends StatefulWidget {
  const ParamPage({Key? key}) : super(key: key);

  @override
  _ParamPageState createState() => _ParamPageState();
}

class _ParamPageState extends State<ParamPage> {
  late TextEditingController _buildingController;
  bool _isAddingBuilding = false;
  List<String> buildings = [];

  @override
  void initState() {
    super.initState();
    _buildingController = TextEditingController();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      buildings = prefs.getStringList('buildings') ?? [];
    });
  }

  Future<void> _saveBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('buildings', buildings);
  }

  @override
  void dispose() {
    _buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des bâtiments '),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: buildings.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(buildings[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ZonePage(buildings[index])),
                      );
                    },
                  );
                },
              ),
            ),
            _buildAddBuildingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBuildingButton() {
    return _isAddingBuilding
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _buildingController,
          decoration: InputDecoration(
            hintText: 'Nom du bâtiment',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String buildingName = _buildingController.text.trim();
            if (buildingName.isNotEmpty) {
              setState(() {
                buildings.add(buildingName);
                _saveBuildings(); // Sauvegarde des bâtiments
                _buildingController.clear();
                _isAddingBuilding = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bâtiment ajouté avec succès: $buildingName'),
                ),
              );
            }
          },
          child: Text('Ajouter'),
        ),
      ],
    )
        : ElevatedButton(
      onPressed: () {
        setState(() {
          _isAddingBuilding = true;
        });
      },
      child: Text('Ajouter un bâtiment'),
    );
  }
}

class ZonePage extends StatefulWidget {
  final String buildingName;

  const ZonePage(this.buildingName);

  @override
  _ZonePageState createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage> {
  late TextEditingController _zoneController;
  bool _isAddingZone = false;
  List<String> zones = [];


  @override
  void initState() {
    super.initState();
    _zoneController = TextEditingController();
    _loadZones();

  }
  Future<void> _loadZones() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      zones = prefs.getStringList('zones') ?? [];
    });
  }

  Future<void> _saveZones() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('zones', zones);
  }


  @override
  void dispose() {
    _zoneController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des zones'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: zones.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(zones[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ZonePage(zones[index])),
                      );
                    },
                  );
                },
              ),
            ),
            _buildAddZoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddZoneButton() {
    return _isAddingZone
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller:_zoneController,
          decoration: InputDecoration(
            hintText: 'Nom du zone',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String zoneName = _zoneController.text.trim();
            if (zoneName.isNotEmpty) {
              setState(() {
                zones.add(zoneName);
                _saveZones(); // Sauvegarde des bâtiments
                _zoneController.clear();
                _isAddingZone  = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Zone ajouté avec succès: $zoneName'),
                ),
              );
            }
          },
          child: Text('Ajouter'),
        ),
      ],
    )
        : ElevatedButton(
      onPressed: () {
        setState(() {
          _isAddingZone  = true;
        });
      },
      child: Text('Ajouter un bâtiment'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ParamPage(),
  ));
}
