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

import '../widgets/back_button.dart';

class BuildingView extends StatefulWidget {
  static const route = "/building_view";

  const BuildingView({Key? key}) : super(key: key);

  @override
  State<BuildingView> createState() => _BuildingView();
}

class Item {
  Item({
    required this.name,
    required this.address,
    required this.user,
    required this.apt,
    required this.postalCode,
    required this.propertyType,
    required this.size,
    this.isExpanded = false,
    required this.uuid,
  });

  String name;
  String address;
  String user;
  String apt;
  String postalCode;
  String propertyType;
  String size;
  bool isExpanded;
  String uuid;
}

Future<List<Item>> generateItems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final response = await http.get(
    Uri.parse(Constants.API_ROUTE +
        '/buildings/' +
        prefs.getString("current_building")),
    headers: <String, String>{
      HttpHeaders.authorizationHeader:
          "Token " + prefs.getString("_user_token"),
    },
  );

  final responseJson = jsonDecode(response.body);
  debugPrint(response.body);

  return List<Item>.generate(responseJson['properties'].length, (int index) {
    final property = responseJson['properties'];
    return Item(
      name: property[index]['name'],
      address: property[index]['address'],
      user: property[index]['user'],
      apt: property[index]['apt'],
      postalCode: property[index]['postal_code'],
      propertyType: property[index]['property_type'],
      uuid: property[index]['uuid'],
      size: property[index]['property_size'],
    );
  });
}

class _BuildingView extends State<BuildingView> {
  List<Item> _data = [];

  Future<void>vincularPropiedad() async {
    await Navigator.of(context).pushNamed('/new_admin_property').then((_) async{
      _data = await generateItems(); // UPDATING List after comming back
      setState(() {});
    });
  }


  Future<void> desvincularPropiedad(Item item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _data.remove(item);
    });

    await http.patch(
        Uri.parse(Constants.API_ROUTE + '/properties/' + item.uuid + '/?remove_from_building'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString("_user_token")
        });
  }

  _BuildingView() {
    generateItems().then((val) => setState(() {
          _data = val;
        }));
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
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: const Image(
                image: AssetImage("assets/images/propiedadadminverde.png"),
                height: 100,
                width: 100,
              ),
              title: Text(item.address),
            );
          },
          body: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: SizedBox(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan> [
                              const TextSpan(
                                text: 'Número: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                              TextSpan(text: item.apt)
                            ]
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan> [
                              const TextSpan(
                                text: 'C. Postal: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                              TextSpan(text: item.postalCode)
                            ]
                          ),
                        ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan> [
                              const TextSpan(
                                text: 'Tipo: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                              TextSpan(text: item.propertyType)
                            ]
                          ),
                        ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan> [
                              const TextSpan(
                                text: 'Tamaño: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                              TextSpan(text: item.size)
                            ]
                          ),
                        ),
                    )
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text("Desvincular Propiedad"),
                onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('¡ATENCIÓN!'),
                    content: const Text(
                        '¿Quieres desvincular la propiedad de tu edificio?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancelar'),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await desvincularPropiedad(item);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            /// BACK BUTTON
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(
                left: 50,
                top: 30,
              ),
              child: const CustomBackButton(
                buttonColor: Colors.black,
              ),
            ),

            /// TITLE
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
              height: MediaQuery.of(context).size.height - 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: <Color>[Colors.green, Colors.lightGreen]),
                boxShadow: [
                  BoxShadow(blurRadius: 3, blurStyle: BlurStyle.normal),
                ],
              ),
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  _buildPanel(),
                  const Padding(padding: EdgeInsets.all(5)),
                  GeneralButton(
                    title: 'Vincular Propiedad',
                    textColor: Colors.white,
                    action: vincularPropiedad,
                  ),
                  const Padding(padding: EdgeInsets.all(15))
                ],
              ),
            ),
          ],
        ),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white,
            Colors.lightGreen,
          ],
        )),
      ),
    );
  }
}
