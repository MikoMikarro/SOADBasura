import 'package:flutter/material.dart';
import 'package:buildgreen/widgets/input_form.dart';
import 'package:buildgreen/widgets/build_green_form_background.dart';
import 'package:buildgreen/widgets/back_button.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

import 'package:buildgreen/widgets/general_buttom.dart';

class NewAdminProperty extends StatefulWidget {
  static const route = "/new_admin_property";

  const NewAdminProperty({Key? key}) : super(key: key);

  @override
  State<NewAdminProperty> createState() => _NewAdminPropertyState();
}

class _NewAdminPropertyState extends State<NewAdminProperty> {

  TextEditingController apartamentoController = TextEditingController();
  TextEditingController sizeController = TextEditingController();

  Future<void> createProperty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await http.post(Uri.parse('https://buildgreen.herokuapp.com/properties/'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString('_user_token'),
        },
        body: <String, String>{
          "apt": apartamentoController.text,
          "property_size": sizeController.text,
          "building": prefs.getString('current_building')
        });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
                InputForm(
                    controller: apartamentoController, hintLabel: 'Numero ex: 3.1'),
                InputForm(
                    controller: sizeController, hintLabel: 'Tamaño'),
                GeneralButton(
                  title: "Agregar nuevo",
                  action: createProperty,
                  textColor: Colors.white,
                ),
              ]))
        ],
      ),
    );
  }
}