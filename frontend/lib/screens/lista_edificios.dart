import 'dart:convert';

import 'package:buildgreen/widgets/general_buttom.dart';
import 'package:buildgreen/widgets/rounded_expansion_panel.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;

// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class ListaEdificios extends StatefulWidget {
  const ListaEdificios({Key? key}) : super(key: key);

  @override
  State<ListaEdificios> createState() => _ListaEdificios();
}

class Edificio {
  Edificio(
      {required this.address,
      this.isExpanded = false,
      required this.postalCode,
      required this.uuid});

  String address;
  bool isExpanded;
  String postalCode;
  String uuid;
}

Future<List<Edificio>> generateItems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final response = await http.get(
    Uri.parse(Constants.API_ROUTE + '/buildings/'),
    headers: <String, String>{
      HttpHeaders.authorizationHeader:
          "Token " + prefs.getString("_user_token"),
    },
  );

  debugPrint(prefs.getString("_user_token").toString());

  final responseJson = jsonDecode(response.body);
  debugPrint(response.body);
  return List<Edificio>.generate(responseJson.length, (int index) {
    final building = responseJson[index];
    return Edificio(
        uuid: building['uuid'],
        address: building['address'],
        postalCode: building['postal_code']);
  });
}

class _ListaEdificios extends State<ListaEdificios> {
  List<Edificio> _data = [];

  _ListaEdificios() {
    generateItems().then((val) => setState(() {
          _data = val;
        }));
  }

  openBuilding(Edificio edificio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("current_building", edificio.uuid);

    await Navigator.of(context).pushNamed('/building_view').then((_) async{
      _data = await generateItems(); // UPDATING List after comming back
      setState(() {});
    });
  }

  Future<void> deleteBuilding(Edificio edificio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _data.remove(edificio);
    });

    final response = await http.delete(
        Uri.parse(Constants.API_ROUTE + '/buildings/'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString("_user_token")
        },
        body: <String, String>{
          'uuid': edificio.uuid.toString(),
        });

    debugPrint(response.body);
  }

  Future<void> newBuilding() async {
    await Navigator.of(context).pushNamed('/new_building');
    _data = await generateItems();
    setState(() {});
  }

  Widget _buildPanel() {
    return CustomExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        for (var foo in _data) {
          if (_data[index] != foo) foo.isExpanded = false;
        }
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Edificio edificio) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: const Image(
                image: AssetImage("assets/images/propiedadadminverde.png"),
                height: 100,
                width: 100,
              ),
              title: Text(edificio.address),
            );
          },
          body: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                  title: const Text("Abrir Edificio"),
                  onTap: () async {
                    openBuilding(edificio);
                  }),
              ListTile(
                title: const Text("Eliminar Edificio"),
                onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('¡ATENCIÓN!'),
                    content: const Text('¿Quieres borrar este edificio?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancelar'),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await deleteBuilding(edificio);
                          setState(() {
                            _data.removeWhere((Edificio currentItem) =>
                                edificio == currentItem);
                          });
                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          isExpanded: edificio.isExpanded,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        children: [
          Column(children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(
                left: 50,
                top: 10,
              ),
              child: const Text(
                'Edificios',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(
                left: 50,
                bottom: 50,
              ),
              child: const Text(
                'Cartera de edificios',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Container(
              child: _buildPanel(),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            GeneralButton(
                title: "Añadir edificio",
                textColor: Colors.white,
                action: newBuilding),
            const Padding(padding: EdgeInsets.only(bottom: 30))
          ]),
        ],
      ),
    );
  }
}
