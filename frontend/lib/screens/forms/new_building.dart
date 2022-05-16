
import 'package:buildgreen/service_subscriber.dart';
import 'package:flutter/material.dart';
import 'package:buildgreen/widgets/input_form.dart';
import 'package:buildgreen/widgets/build_green_form_background.dart';
import 'package:buildgreen/widgets/back_button.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

import 'package:buildgreen/widgets/general_buttom.dart';

class NewBuilding extends StatefulWidget {
  static const route = "/new_building";

  const NewBuilding({Key? key}) : super(key: key);

  @override
  State<NewBuilding> createState() => _NewBuildingState();
}

class _NewBuildingState extends State<NewBuilding> {
  TextEditingController cPostalController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController autocompleteController = TextEditingController();

  bool _autoValidator = false;

  bool formCorrect() {
    if (direccionController.text.isNotEmpty &&
        cPostalController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> createBuilding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await http.post(Uri.parse('https://buildgreen.herokuapp.com/buildings/'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString('_user_token'),
        },
        body: <String, String>{
          "address": direccionController.text,
          "postal_code": cPostalController.text,
        });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          BackgroundForm(
            screenHeight: screenHeight,
            backColor: const Color.fromARGB(255, 71, 146, 96),
          ),
          Container(
              padding: const EdgeInsets.all(40),
              child: Column(children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.topLeft,
                  child: const CustomBackButton(),
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: InputForm(
                          controller: autocompleteController,
                          onChanged: (value) {
                            if (value.toString().isNotEmpty) {
                              applicationBloc.searchPlaces(value!);
                            }
                          },
                          hintLabel: 'Buscar dirección',
                      ),
                    ),
                    if (applicationBloc.searchResults.isNotEmpty)
                      IconButton(
                          onPressed: () {
                            applicationBloc.setNoResults();
                            autocompleteController.clear();
                          },
                          icon: const Icon(Icons.close))
                  ],
                ),
                if (applicationBloc.searchResults.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.6),
                          backgroundBlendMode: BlendMode.darken),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: applicationBloc.searchResults.length,
                          itemBuilder: (context, index) => ListTile(
                                  title: ListTile(
                                title: Text(
                                    applicationBloc
                                        .searchResults[index].description
                                        .toString(),
                                    style:
                                        const TextStyle(color: Colors.white)),
                                onTap: () async {
                                  await applicationBloc.setSelectedLocation(
                                      applicationBloc
                                          .searchResults[index].placeId);
                                  autocompleteController.text =
                                      applicationBloc.getSelectedLocation();
                                  direccionController.text =
                                      autocompleteController.text;
                                  cPostalController.text = applicationBloc
                                      .getSelectedLocationPCode();
                                  _autoValidator = true;
                                },
                              ))),
                    ),
                  ),
                if (_autoValidator)
                  InputForm(
                      controller: direccionController, hintLabel: 'Dirección'),
                InputForm(
                    controller: cPostalController, hintLabel: 'Codigo postal'),
                GeneralButton(
                  title: "Agregar nuevo",
                  action: (formCorrect()) ? createBuilding : () {},
                  textColor: (formCorrect()) ? Colors.white : Colors.white24,
                ),
              ]))
        ],
      ),
    );
  }
}
