import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

void main() {
  runApp(MaterialApp(
    home: ParamPage(),
    theme: ThemeData(
      primaryColor: Colors.deepPurple,
      hintColor: Colors.deepPurpleAccent,
      fontFamily: 'Roboto',
    ),
  ));
}

class ParamPage extends StatefulWidget {
  const ParamPage({Key? key}) : super(key: key);

  @override
  _ParamPageState createState() => _ParamPageState();
}
class _ParamPageState extends State<ParamPage> {
  late TextEditingController _buildingController;
  late TextEditingController _searchController;
  bool _isAddingBuilding = false;
  List<String> buildings = [];
  List<String> filteredBuildings = [];

  @override
  void initState() {
    super.initState();
    _buildingController = TextEditingController();
    _searchController = TextEditingController();
    _loadBuildings(); // Charger les bâtiments lorsque la page est initialement construite
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBuildings(); // Charger les bâtiments chaque fois que la dépendance de la page change
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
    _searchController.dispose();
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
            SizedBox(height: 16),
            _buildAddBuildingButton(), // Placer la carte d'ajout en haut de la colonne
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredBuildings.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              filteredBuildings[index],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _removeBuilding(index);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ZonePage(filteredBuildings[index], index),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
        ? Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true, // Pour s'adapter à la taille du contenu
          padding: EdgeInsets.only(bottom: 10), // Ajoute un padding supplémentaire en bas
          children: [
            TextField(
              controller: _buildingController,
              decoration: InputDecoration(
                hintText: 'Nom du bâtiment',
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                String buildingName = _buildingController.text.trim();
                if (buildingName.isNotEmpty) {
                  await DatabaseHelper.instance.insertBuilding(buildingName);
                  setState(() {
                    _buildingController.clear();
                    _isAddingBuilding = false;
                    buildings.add(buildingName);
                    filteredBuildings = List.from(buildings);
                  });
                  _saveBuildings();
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
        ),
      ),
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
    if (index >= 0 && index < buildings.length) {
      String buildingName = buildings[index];

      // Supprimer le bâtiment de la base de données
      await DatabaseHelper.instance.deleteBuilding(buildingName);

      setState(() {
        // Supprimer le bâtiment de la liste des bâtiments
        buildings.removeAt(index);
        // Mettre à jour la liste des bâtiments filtrés
        filteredBuildings = List.from(buildings);
      });

      // Enregistrer les modifications dans le stockage local
      await _saveBuildings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bâtiment supprimé avec succès'),
        ),
      );
    } else {
      print('Index out of bounds.');
    }
  }
}


class ZonePage extends StatefulWidget {
  final String buildingName;
  final int buildingId;

  const ZonePage(this.buildingName, this.buildingId);

  @override
  _ZonePageState createState() => _ZonePageState();
}
class _ZonePageState extends State<ZonePage> {
  late TextEditingController _zoneController;
  late DatabaseHelper databaseHelper;

  bool _isAddingZone = false;
  List<String> zones = [];

  @override
  void initState() {
    super.initState();
    _zoneController = TextEditingController();
    databaseHelper = DatabaseHelper.instance;

    _loadZones();
  }

  Future<void> _loadZones() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      zones = prefs.getStringList('${widget.buildingName}_zones') ?? [];
    });
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
        title: Text('Zones de ${widget.buildingName}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAddZoneButton(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: zones.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        zones[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeZone(index);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FloorPage(zones[index], zoneId: index),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddZoneButton() {
    return _isAddingZone
        ? Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _zoneController,
              decoration: InputDecoration(
                hintText: 'Nom de la zone',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String zoneName = _zoneController.text.trim();
                if (zoneName.isNotEmpty) {
                  await databaseHelper.insertZone(widget.buildingId, zoneName);
                  setState(() {
                    _isAddingZone = false;
                    zones.add(zoneName);
                  });
                  _zoneController.clear();
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
        ),
      ),
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

  void _removeZone(int index) async {
    if (index >= 0 && index < zones.length) {
      String zoneName = zones[index];
      await databaseHelper.deleteZone(widget.buildingId, index);
      setState(() {
        zones.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zone supprimée avec succès'),
        ),
      );
    } else {
      print('Index out of bounds.');
    }
  }
}



class FloorPage extends StatefulWidget {
  final String zoneName;
  final int zoneId;

  const FloorPage(this.zoneName, {required this.zoneId});

  @override
  _FloorPageState createState() => _FloorPageState();
}
class _FloorPageState extends State<FloorPage> {
  late TextEditingController _floorController;
  List<String> floors = [];
  late DatabaseHelper databaseHelper;
  bool _isAddingFloor = false;

  @override
  void initState() {
    super.initState();
    _floorController = TextEditingController();
    databaseHelper = DatabaseHelper.instance;
    _loadFloors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFloors();
  }

  Future<void> _loadFloors() async {
    List<Map<String, dynamic>> floorsMap = await databaseHelper.getFloorsForZone(widget.zoneId);
    setState(() {
      floors = floorsMap.map((floor) => floor['name'] as String).toList();
    });
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
        title: Text('Étages de la zone ${widget.zoneName}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAddFloorButton(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(floors[index], style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeFloor(index);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfficePage(
                              floors[index],
                              widget.zoneId,
                              selectedFloorId: index + 1,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFloorButton() {
    return _isAddingFloor
        ? Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _floorController,
              decoration: InputDecoration(
                hintText: 'Nom de l\'étage',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String floorName = _floorController.text.trim();
                if (floorName.isNotEmpty) {
                  await databaseHelper.insertFloor(widget.zoneId, floorName, floors.length + 1);
                  setState(() {
                    floors.add(floorName);
                    _floorController.clear();
                    _isAddingFloor = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Étage ajouté avec succès: $floorName'),
                    ),
                  );
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    )
        : ElevatedButton(
      onPressed: () {
        setState(() {
          _isAddingFloor = true;
        });
      },
      child: Text('Ajouter un étage'),
    );
  }

  void _removeFloor(int index) async {
    if (index >= 0 && index < floors.length) {
      String removedFloorName = floors.removeAt(index);
      await databaseHelper.deleteFloor(widget.zoneId, removedFloorName);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Étage supprimé avec succès'),
        ),
      );
    } else {
      print('Index out of bounds.');
    }
  }
}



class OfficePage extends StatefulWidget {
  final String floorName;
  final int zoneId;
  final int? selectedFloorId;

  const OfficePage(this.floorName, this.zoneId, {this.selectedFloorId});

  @override
  _OfficePageState createState() => _OfficePageState();
}
class _OfficePageState extends State<OfficePage> {
  late TextEditingController _officeController;
  List<String> offices = [];
  late DatabaseHelper databaseHelper;
  bool _isAddingOffice = false;

  @override
  void initState() {
    super.initState();
    _officeController = TextEditingController();
    databaseHelper = DatabaseHelper.instance;
    _loadOffices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? loadedOffices = prefs.getStringList('${widget.floorName}_offices');
    setState(() {
      offices = loadedOffices ?? [];
    });
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
            _buildAddOfficeButton(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: offices.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(offices[index], style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeOffice(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOfficeButton() {
    return _isAddingOffice
        ? Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _officeController,
              decoration: InputDecoration(
                hintText: 'Nom ou numéro du bureau',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String officeName = _officeController.text.trim();
                if (officeName.isNotEmpty) {
                  setState(() {
                    offices.add(officeName);
                    _officeController.clear();
                    _isAddingOffice = false;
                  });
                  await _saveOffice();
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
        ),
      ),
    )
        : ElevatedButton(
      onPressed: () {
        setState(() {
          _isAddingOffice = true;
        });
      },
      child: Text('Ajouter un bureau'),
    );
  }

  Future<void> _saveOffice() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.floorName}_offices', offices);
  }

  void _removeOffice(int index) async {
    if (index >= 0 && index < offices.length) {
      String removedOfficeName = offices.removeAt(index);
      await databaseHelper.deleteOffice(widget.floorName, removedOfficeName);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bureau supprimé avec succès'),
        ),
      );
    } else {
      print('Index out of bounds.');
    }
  }
}




