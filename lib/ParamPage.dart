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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

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
                  // Insérer le bâtiment dans la base de données
                  String? insertedBuilding = await DatabaseHelper.instance.insertBuilding(buildingName);
                  if (insertedBuilding != null) {
                    setState(() {
                      _buildingController.clear();
                      _isAddingBuilding = false;
                      buildings.add(insertedBuilding);
                      filteredBuildings = List.from(buildings);
                    });
                    _saveBuildings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bâtiment ajouté avec succès: $insertedBuilding'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Le bâtiment existe déjà: $buildingName'),
                      ),
                    );
                  }
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
  late SharedPreferences _prefs;
  bool _isAddingZone = false;
  List<String> zones = [];

  @override
  void initState() {
    super.initState();
    _zoneController = TextEditingController();
    _loadZones();
  }

  Future<void> _loadZones() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      zones = _prefs.getStringList('${widget.buildingName}_zones') ?? [];
    });
  }

  @override
  void dispose() {
    _zoneController.dispose();
    super.dispose();
  }


  Future<void> _saveZones() async {
    await _prefs.setStringList('${widget.buildingName}_zones', zones);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                            builder: (context) => FloorPage(
                              zones[index],
                              zoneId: index,
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
                  // Vérifier si la zone existe déjà pour ce bâtiment
                  bool zoneExists = await DatabaseHelper.instance.zoneExistsForBuilding(widget.buildingId, zoneName);
                  if (zoneExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('La zone existe déjà pour ce bâtiment: $zoneName'),
                      ),
                    );
                  } else {
                    setState(() {
                      zones.add(zoneName);
                      _zoneController.clear();
                      _isAddingZone = false;
                    });
                    await _saveZones();
                    // Insérer la zone dans la base de données
                    await  DatabaseHelper.instance.insertZone(widget.buildingId, zoneName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Zone ajoutée avec succès: $zoneName'),
                      ),
                    );
                  }
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
      setState(() {
        zones.removeAt(index);
      });
      await _saveZones();
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

  Future<bool> _floorExists(String floorName) async {
    int floorId = await databaseHelper.getFloorId(widget.zoneId, floorName);
    return floorId != -1;
  }


  @override
  void dispose() {
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

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
                  bool exists = await _floorExists(floorName);
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Étage déjà existant dans cette zone: $floorName'),
                      ),
                    );
                  } else {
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
  late SharedPreferences _prefs;
  List<String> offices = [];
  bool _isAddingOffice = false;

  @override
  void initState() {
    super.initState();
    _officeController = TextEditingController();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      offices = _prefs.getStringList('${widget.floorName}_offices') ?? [];
    });
  }

  @override
  void dispose() {
    _officeController.dispose();
    super.dispose();
  }

  Future<void> _saveOffices() async {
    await _prefs.setStringList('${widget.floorName}_offices', offices);
  }

  Future<bool> _officeExists(String officeName) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'offices',
      where: 'floor_id = ? AND name = ?',
      whereArgs: [widget.selectedFloorId, officeName],
    );
    return result.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Bureaux de ${widget.floorName}'),
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
                      title: Text(
                        offices[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                  bool exists = await _officeExists(officeName);
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bureau déjà existant dans cet étage: $officeName'),
                      ),
                    );
                  } else {
                    setState(() {
                      offices.add(officeName);
                      _officeController.clear();
                      _isAddingOffice = false;
                    });
                    await _saveOffices();
                    await DatabaseHelper.instance.insertOffice(widget.selectedFloorId!, officeName, widget.zoneId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bureau ajouté avec succès: $officeName'),
                      ),
                    );
                  }
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
          _isAddingOffice = true;
        });
      },
      child: Text('Ajouter un bureau'),
    );
  }

  void _removeOffice(int index) async {
    if (index >= 0 && index < offices.length) {
      String removedOfficeName = offices.removeAt(index);
      await _saveOffices();
      // You should also remove the office from the database if necessary
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




