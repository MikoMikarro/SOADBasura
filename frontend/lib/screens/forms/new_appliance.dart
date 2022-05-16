// ignore_for_file: import_of_legacy_library_into_null_safe, library_prefixes

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:buildgreen/widgets/back_button.dart';
import 'package:buildgreen/widgets/build_green_form_background.dart';
import 'package:buildgreen/widgets/general_buttom.dart';
import 'package:buildgreen/widgets/input_form.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:buildgreen/constants.dart' as Constants;

class NewAppliance extends StatefulWidget {
  static const route = "/new_appliance";

  const NewAppliance({Key? key}) : super(key: key);

  @override
  State<NewAppliance> createState() => _NewApplianceState();
}

class _NewApplianceState extends State<NewAppliance> {
  TextEditingController modeloController = TextEditingController();
  TextEditingController marcaController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController consumoController = TextEditingController();

  final backendtranslate = <String, String>{
    "TV": "tv",
    "Nevera": "fridge",
    "Horno": "oven",
  };
  String dropdownValue = 'TV';

  Future<void> moveToPropiedades() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await http.post(Uri.parse(Constants.API_ROUTE + '/appliances/'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString('_user_token'),
        },
        body: <String, String>{
          "property": prefs.getString('_actual_property'),
          "appliance_type": backendtranslate[dropdownValue].toString(),
          "model": modeloController.text,
          "brand": marcaController.text,
          "cons": consumoController.text,
          "price": precioController.text,
        });
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.green;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: Stack(
        children: [
          // background colors start
          BackgroundForm(
            screenHeight: screenHeight,
            backColor: const Color.fromARGB(255, 71, 146, 96),
          ),
          // background colors end
          // form start
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.topLeft,
                  child: const CustomBackButton(),
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: InputForm(
                          controller: modeloController, hintLabel: 'Modelo'),
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                    Transform.translate(
                      offset: const Offset(0, 12),
                      child: DropdownButton<String>(
                        alignment: Alignment.topCenter,
                        value: dropdownValue,
                        icon: const Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                        underline: Container(
                          height: 3,
                          color: Colors.white,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>['TV', 'Horno', 'Nevera']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        dropdownColor: Colors.green,
                      ),
                    ),
                    //InputForm(controller: apellidoController, hintLabel: "Apellidos"),
                  ],
                ),
                Flexible(
                  child: InputForm(
                      controller: marcaController, hintLabel: "Marca"),
                ),
                Flexible(
                  child: InputForm(
                      controller: precioController, hintLabel: "Precio [€]"),
                ),
                Flexible(
                  child: InputForm(
                      controller: consumoController, hintLabel: "Consumo [kW]"),
                ),
                GeneralButton(
                  title: "Agregar nuevo",
                  action: moveToPropiedades,
                  textColor: Colors.white,
                ),
              ],
            ),
          )
          // form end
        ],
      ),
    );
  }
}
