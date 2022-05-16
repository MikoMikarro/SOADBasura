
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:buildgreen/arguments/advice_detail_argument.dart';
import 'package:buildgreen/classes/advice.dart';
import 'package:buildgreen/screens/forms/consejo_dia_view.dart';
import 'package:buildgreen/widgets/back_button.dart';
import 'package:buildgreen/widgets/rounded_expansion_panel.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;

class ConsejosList extends StatefulWidget {

  static const route = "/my_advices";
  
  const ConsejosList({Key? key}) : super(key: key);

  @override
  State<ConsejosList> createState() => _ConsejosList();
}

//Generar propiedades para la Expansion Panel List
Future<List<Advice>> generateItems(String param) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();

  EasyLoading.show(status: 'Carg',maskType: EasyLoadingMaskType.black);
  String uri = Constants.API_ROUTE+'/advices_user/?'+param;//Constants.API_ROUTE + '/advices_all/'; //
  final response = await http.get(
      Uri.parse(uri),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: "Token " + prefs.getString("_user_token"),
      },
  );
  EasyLoading.dismiss();
  final responseJson = jsonDecode(response.body);
  
  debugPrint(response.body);

  return List<Advice>.generate(responseJson.length, (int index) {
    var property = responseJson[index];

    if (property['advice'] != null) {
      property = property['advice'];
    }

    final timeSlots = property['time_options'].split(" ");
    final timeOptions = List<int>.generate(timeSlots.length, (int index) {
      return int.parse(timeSlots[index]);
    });
    return Advice(
        title: property['title'],
        id: property['uuid'],
        description: property['description'],
        xps: property['xps'],
        timeOptions: timeOptions,
    );
  });
}
class _ConsejosList extends State<ConsejosList> {
  //Se rellena  la lista de propiedades
  List<Advice> _unCompletedAdvices =  [];
  List<Advice> _completedAdvices =  [];
  List<Advice> _neverCompletedAdvices =  [];
  
  // ignore: prefer_final_fields
  List<bool> _expanded = [false, false, false];
  
  TextEditingController nameController = TextEditingController();

  _ConsejosList() {
    generateItems('to_complete_again').then((val) => setState(() {
          _unCompletedAdvices = val;
        },
      ),
    );

    generateItems('completed').then((val) => setState(() {
          _completedAdvices = val;
        },
      ),
    );

    generateItems('never_completed').then((val) => setState(() {
          _neverCompletedAdvices = val;
        },
      ),
    );
  }
  
  Future<void> allAdvices() async {
    setState(() {
      Navigator.pushNamed(context, '/all_advices');  
    });
  }

  Widget _buildPanel()  {
    return CustomExpansionPanelList(

          expansionCallback: (int index, bool isExpanded) {
            var list = List<int>.generate(_expanded.length-1, (i) => i + 1);
            for (var indice in list ) {
              if (indice != index) {
                _expanded[indice] = false;
              }
              
            }
            setState(() {
              _expanded[index] = !_expanded[index];
            });
          },
          children: [
            ExpansionPanel(
              isExpanded: _expanded[0],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return const ListTile(
                  title: Text("Uncompleted advices"),
                );
              },
              body: Column(
                children: [
                  for (var item in _unCompletedAdvices)
                    Row (
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Marca: '+item.title, textAlign: TextAlign.left),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pushNamed(context, ConsejoDetalle.route, arguments: AdviceDetailArgument(item));
                          });
                        }, 
                        icon: const Icon(Icons.arrow_forward_ios),
                      )
                    ],
                  )
                ],
              )
            ),
            
            ExpansionPanel(
              isExpanded: _expanded[1],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return const ListTile(
                  title: Text("Completed advices"),
                );
              },
              body: Column(
                children: [
                  for (var item in _completedAdvices)
                    Row (
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Marca: '+item.title, textAlign: TextAlign.left),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pushNamed(context, ConsejoDetalle.route, arguments: AdviceDetailArgument(item));
                          });
                        }, 
                        icon: const Icon(Icons.arrow_forward_ios),
                      )
                    ],
                  )
                ],
              )
            ),

            ExpansionPanel(
              isExpanded: _expanded[2],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return const ListTile(
                  title: Text("Completed advices"),
                );
              },
              body: Column(
                children: [
                  for (var item in _neverCompletedAdvices)
                    Row (
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Marca: '+item.title, textAlign: TextAlign.left),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pushNamed(context, ConsejoDetalle.route, arguments: AdviceDetailArgument(item));
                          });
                        }, 
                        icon: const Icon(Icons.arrow_forward_ios),
                      )
                    ],
                  )
                ],
              )
            ),
          
          ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: ListView(
            children: [
              Column(children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(
                    left: 50,
                    top: 30,
                  ),
                  child: const CustomBackButton(buttonColor: Colors.black),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(
                    left: 50,
                    top: 10,
                  ),
                  child: const Text(
                    'Consejos de sostenibilidad',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                ),
                Container(
                  child: _buildPanel(),
                ),
              ]),
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
            )
          ),
        ),
    );
  }
}