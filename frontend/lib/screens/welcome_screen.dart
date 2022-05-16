// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:buildgreen/screens/arguments/user_type_argument.dart';
import 'package:buildgreen/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "../widgets/general_buttom.dart";

// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class WelcomeScreen extends StatelessWidget {
  static const route = '/welcome_screen';

  const WelcomeScreen({Key? key}) : super(key: key);

  Future<void> logInReqAccount(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("_user_token") != null) {
      EasyLoading.show(status: 'Detected account\nLogging in');
      final http.Response response = await http.get(
        Uri.parse(Constants.API_ROUTE + '/user/'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString("_user_token"),
        },
      );

      final responseJson = jsonDecode(response.body);
      EasyLoading.dismiss();
      if (responseJson['user_info'] != null) {
        final userType = responseJson['user_info']['is_admin'].toString();
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.route, ((route) => false), arguments: UserTypeArgument(userType));
      } else {
        await prefs.remove("_user_token");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    logInReqAccount(context);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(children: [
                // background profilePic start
                Container(
                  padding: const EdgeInsets.only(top: 100, left: 50, right: 50),
                  child: const Image(
                    image: AssetImage("assets/images/build_green_logo.png"),
                  ),
                ),

                Expanded(child: Container()),

                Container(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  alignment: Alignment.bottomCenter,
                  child: GeneralButton(
                      title: 'Entrar',
                      textColor: Colors.white,
                      action: () => {Navigator.pushNamed(context, '/login')}),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 25, 25, 50),
                  alignment: Alignment.bottomCenter,
                  child: GeneralButton(
                      title: 'Registrarse',
                      textColor: Colors.white,
                      action: () =>
                          {Navigator.pushNamed(context, '/register')}),
                ),
                // background profilePic end
              ]),
            )
          ],
        ),
      ],
    ));
  }
}
