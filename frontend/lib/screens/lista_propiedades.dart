// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:buildgreen/widgets/general_buttom.dart';
import 'package:buildgreen/widgets/rounded_expansion_panel.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;

import 'package:shared_preferences/shared_preferences.dart';

class ListaPropiedades extends StatefulWidget {
  const ListaPropiedades({Key? key}) : super(key: key);

  @override
  State<ListaPropiedades> createState() => _ListaPropiedades();
}

//Classe Item Propiedad
class Item {
  Item({
    required this.headerValue,
    this.isExpanded = false,
    this.uuid,
  });

  String headerValue;
  bool isExpanded;
  String? uuid;
}

//Generar propiedades para la Expansion Panel List
Future<List<Item>> generateItems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final response = await http.get(
    Uri.parse(Constants.API_ROUTE + '/properties/'),
    headers: <String, String>{
      HttpHeaders.authorizationHeader:
          "Token " + prefs.getString("_user_token"),
    },
  );

  final responseJson = jsonDecode(response.body);
  debugPrint(response.body);
  return List<Item>.generate(responseJson.length, (int index) {
    final property = responseJson[index];
    return Item(headerValue: property['name'], uuid: property['uuid']

        //expandedValue: 'This is item number $index',
        );
  });
}

class _ListaPropiedades extends State<ListaPropiedades> {
  //Se rellena  la lista de propiedades
  List<Item> _data = [];

  TextEditingController nameController = TextEditingController();

  _ListaPropiedades() {
    generateItems().then((val) => setState(() {
          _data = val;
        }));
  }

  Future<void> moveToAppliances(Item item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('_actual_property', item.uuid);
    Navigator.pushNamed(context, '/sim');
  }

  Future<void> newProperty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      int lastItemIndex = _data.length;
      Item nitem =
          Item(headerValue: "Calle Ejemplo " + _data.length.toString());
      _data.insert(lastItemIndex, nitem);
    });

    await http.post(
      Uri.parse(Constants.API_ROUTE + '/properties/'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader:
            "Token " + prefs.getString("_user_token"),
      },
      body: {
        "address": "Calle Ejemplo " + _data.length.toString(),
        "name": "Mi puta casa",
        "apt": "32, 15",
        "postal_code": "14002",
        "property_type": "apt"
      },
    );

    await Navigator.of(context).pushNamed('/new_property');
    _data = await generateItems();
    setState(() {});
  }

  Future<void> deleteProperty(Item item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _data.remove(item);
    });

    final response = await http.delete(
        Uri.parse(Constants.API_ROUTE + '/properties/'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString("_user_token"),
        },
        body: <String, String>{
          'uuid': item.uuid.toString(),
        });

    debugPrint(response.body);
  }

  Widget _buildPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: CustomExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          for (var foo in _data) {
            if (_data[index] != foo) foo.isExpanded = false;
          }
          setState(() {
            _data[index].isExpanded = !isExpanded;
          });
        },
        children: _data.map<ExpansionPanel>((Item item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                leading: const Image(
                  image: AssetImage("assets/images/propiedadadminverde.png"),
                  height: 100,
                  width: 100,
                ),
                title: Text(item.headerValue??"Null"),
              );

            },
            body: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                      title: const Text("Abrir Propiedad"),
                      onTap: () async {
                        moveToAppliances(item);
                      }),
                  ListTile(
                    title: const Text("Eliminar Propiedad"),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('¡ATENCIÓN!'),
                        content: const Text('¿Quieres borrar esta propiedad?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancelar'),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await deleteProperty(item);
                              setState(() {
                                _data.removeWhere(
                                    (Item currentItem) => item == currentItem);
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
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
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
                'Propiedades',
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
                'Cartera de propiedades',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Container(
              child: _buildPanel(),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            GeneralButton(
                title: "Añadir propiedad",
                textColor: Colors.white,
                action: newProperty),
            const Padding(padding: EdgeInsets.only(bottom: 30))
          ]),
        ],
      ),
    );
  }
}
