import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

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
            TextField(
              controller: _searchController,
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
                        MaterialPageRoute(builder: (context) => ZonePage(filteredBuildings[index], index)),
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
          controller: _buildingController,
          decoration: InputDecoration(
            hintText: 'Nom du bâtiment',
          ),
        ),
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
                        MaterialPageRoute(
                          builder: (context) => FloorPage(zones[index], zoneId: index),
                        ),
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
          onPressed: () async {
            String zoneName = _zoneController.text.trim();
            if (zoneName.isNotEmpty) {
              await databaseHelper.insertZone(widget.buildingId, zoneName);
              setState(() {
                _isAddingZone = false;
                zones.add(zoneName);
                _saveZones();
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

  void _removeZone(int index) async {
    if (index >= 0 && index < zones.length) {
      String zoneName = zones[index];
      await databaseHelper.deleteZone(widget.buildingId, index);
      setState(() {
        zones.removeAt(index);
        _saveZones();
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
  int? selectedFloorId;
  int? selectedZoneId;

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
                    onTap: () async {
                      setState(() {
                        selectedFloorId = index + 1;
                        selectedZoneId = widget.zoneId;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OfficePage(
                            floors[index],
                            widget.zoneId,
                            selectedFloorId: selectedFloorId,
                            selectedZoneId: selectedZoneId,
                          ),
                        ),
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
          onPressed: () async {
            print('Bouton d\'ajout d\'étage appuyé'); // Vérifier si le bouton est appuyé
            String floorName = _floorController.text.trim();
            if (floorName.isNotEmpty) {
              if (widget.zoneId != null) {
                int nextFloorId = floors.length + 1; // Assigner l'ID du prochain étage disponible
                await databaseHelper.insertFloor(widget.zoneId, floorName, nextFloorId);
                setState(() {
                  floors.add(floorName);
                  _floorController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Étage ajouté avec succès: $floorName'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la sélection de la zone.'),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Veuillez saisir un numéro d\'étage valide'),
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
    if (index >= 0 && index < floors.length) {
      setState(() {
        String removedFloorName = floors.removeAt(index);
        databaseHelper.deleteFloor(widget.zoneId, removedFloorName);
      });
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
  final int? selectedZoneId;

  const OfficePage(this.floorName, this.zoneId, {this.selectedFloorId, this.selectedZoneId});

  @override
  _OfficePageState createState() => _OfficePageState();
}

class _OfficePageState extends State<OfficePage> {
  late TextEditingController _officeController;
  List<String> offices = [];
  late DatabaseHelper databaseHelper;

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
    print('Loaded offices: $loadedOffices');
    setState(() {
      offices = loadedOffices ?? [];
    });
  }
  Future<void> _saveOffice() async {
    final officeName = _officeController.text.trim();
    print('Office name to save: $officeName');
    print('Selected floor ID: ${widget.selectedFloorId}');
    print('Selected zone ID: ${widget.selectedZoneId}');

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.floorName}_offices', offices);
    print('Saved offices: $offices');
    print('Inserting office: $officeName');
    await databaseHelper.insertOffice(widget.selectedFloorId!, officeName, widget.selectedZoneId!);
    print('Office inserted successfully: $officeName');
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _removeOffice(index);
                      },
                    ),
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
          onPressed: () async {
            String officeName = _officeController.text.trim();
            if (officeName.isNotEmpty) {
              // Vérifiez si les valeurs selectedFloorId et selectedZoneId sont valides
              if (widget.selectedFloorId != null && widget.selectedZoneId != null) {
                setState(() {
                  offices.add(officeName); // Ajoutez le bureau à la liste avant de l'enregistrer
                  _officeController.clear();
                });
                await _saveOffice(); // Enregistrer le bureau après l'avoir ajouté à la liste
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bureau ajouté avec succès: $officeName'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Veuillez sélectionner un étage et une zone valides'),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Veuillez saisir un nom de bureau valide'),
                ),
              );
            }
          },
          child: Text('Ajouter un bureau'),
        ),
      ],
    );
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


void main() {
  runApp(MaterialApp(
    home: ParamPage(),
  ));
}
