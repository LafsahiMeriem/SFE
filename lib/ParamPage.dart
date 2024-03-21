import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParamPage extends StatefulWidget {
  const ParamPage({Key? key}) : super(key: key);

  @override
  _ParamPageState createState() => _ParamPageState();
}

class _ParamPageState extends State<ParamPage> {
  late TextEditingController _buildingController;
  late TextEditingController _searchController; // Ajout du contrôleur de recherche
  bool _isAddingBuilding = false;
  List<String> buildings = [];
  List<String> filteredBuildings = [];

  @override
  void initState() {
    super.initState();
    _buildingController = TextEditingController();
    _searchController = TextEditingController(); // Initialisation du contrôleur de recherche
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      buildings = prefs.getStringList('buildings') ?? [];
      filteredBuildings = List.from(buildings);
    });
  }

  Future<void> _saveBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('buildings', buildings);
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _searchController.dispose(); // Disposer du contrôleur de recherche
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bâtiments'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController, // Utilisation du contrôleur de recherche pour le champ de recherche
              decoration: InputDecoration(
                hintText: 'Rechercher un bâtiment',
              ),
              onChanged: _filterBuildings,
            ),
            _buildAddBuildingButton(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBuildings.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(filteredBuildings[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeBuilding(index);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ZonePage(filteredBuildings[index])),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterBuildings(String query) {
    setState(() {
      filteredBuildings = buildings.where((building) => building.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Widget _buildAddBuildingButton() {
    return _isAddingBuilding
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _buildingController, // Utilisation du contrôleur de bâtiment pour le champ d'ajout de bâtiment
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
                filteredBuildings = List.from(buildings);
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

  void _removeBuilding(int index) async {
    setState(() {
      buildings.removeAt(index);
      _saveBuildings();
      filteredBuildings = List.from(buildings);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bâtiment supprimé avec succès'),
      ),
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
      zones = prefs.getStringList('${widget.buildingName}_zones') ?? [];
    });
  }

  Future<void> _saveZones() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.buildingName}_zones', zones);
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
        title: Text('Les zones de ${widget.buildingName}'),
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
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(zones[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeZone(index);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FloorPage(zones[index])),
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
          controller: _zoneController,
          decoration: InputDecoration(
            hintText: 'Nom de la zone',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String zoneName = _zoneController.text.trim();
            if (zoneName.isNotEmpty) {
              setState(() {
                zones.add(zoneName);
                _saveZones();
                _zoneController.clear();
                _isAddingZone = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Zone ajoutée avec succès: $zoneName'),
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
          _isAddingZone = true;
        });
      },
      child: Text('Ajouter une zone'),
    );
  }

  void _removeZone(int index) {
    setState(() {
      zones.removeAt(index);
      _saveZones();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zone supprimée avec succès'),
      ),
    );
  }
}

class FloorPage extends StatefulWidget {
  final String zoneName;

  const FloorPage(this.zoneName);

  @override
  _FloorPageState createState() => _FloorPageState();
}

class _FloorPageState extends State<FloorPage> {
  late TextEditingController _floorController;
  List<String> floors = [];

  @override
  void initState() {
    super.initState();
    _floorController = TextEditingController();
    _loadFloors();
  }

  Future<void> _loadFloors() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      floors = prefs.getStringList('${widget.zoneName}_floors') ?? [];
    });
  }

  Future<void> _saveFloors() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.zoneName}_floors', floors);
  }

  @override
  void dispose() {
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Les étages de ${widget.zoneName}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(floors[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeFloor(index);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OfficePage(floors[index])),
                      );
                    },
                  );
                },
              ),
            ),
            _buildAddFloorButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFloorButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _floorController,
          decoration: InputDecoration(
            hintText: 'Numéro de l\'étage',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String floorName = _floorController.text.trim();
            if (floorName.isNotEmpty) {
              setState(() {
                floors.add(floorName);
                _saveFloors();
                _floorController.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Étage ajouté avec succès: $floorName'),
                ),
              );
            }
          },
          child: Text('Ajouter un étage'),
        ),
      ],
    );
  }

  void _removeFloor(int index) {
    setState(() {
      floors.removeAt(index);
      _saveFloors();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Étage supprimé avec succès'),
      ),
    );
  }
}


class OfficePage extends StatefulWidget {
  final String floorName;

  const OfficePage(this.floorName);

  @override
  _OfficePageState createState() => _OfficePageState();
}

class _OfficePageState extends State<OfficePage> {
  late TextEditingController _officeController;
  List<String> offices = [];

  @override
  void initState() {
    super.initState();
    _officeController = TextEditingController();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      offices = prefs.getStringList('${widget.floorName}_offices') ?? [];
    });
  }

  Future<void> _saveOffices() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.floorName}_offices', offices);
  }

  @override
  void dispose() {
    _officeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bureaux de l\'étage ${widget.floorName}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: offices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(offices[index]),
                  );
                },
              ),
            ),
            _buildAddOfficeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOfficeButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _officeController,
          decoration: InputDecoration(
            hintText: 'Nom ou numéro du bureau',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String officeName = _officeController.text.trim();
            if (officeName.isNotEmpty) {
              setState(() {
                offices.add(officeName);
                _saveOffices();
                _officeController.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bureau ajouté avec succès: $officeName'),
                ),
              );
            }
          },
          child: Text('Ajouter un bureau'),
        ),
      ],
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: ParamPage(),
  ));
}
