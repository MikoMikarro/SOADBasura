// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:buildgreen/screens/forms/edit_profile_page.dart';
import 'package:buildgreen/screens/lista_consejos_personal.dart';
import 'package:buildgreen/screens/welcome_screen.dart';
import 'package:buildgreen/widgets/general_buttom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

import 'package:syncfusion_flutter_charts/charts.dart';


import 'package:buildgreen/constants.dart' as Constants;


class AreaPersonalCliente extends StatefulWidget {
  const AreaPersonalCliente({Key? key}) : super(key: key);
  @override
  State<AreaPersonalCliente> createState() => _AreaPersonalCliente();
}

Future<List<PriceTags>> getPriceTags() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token');
  final response = await http.get(Uri.parse(
      Constants.API_ROUTE + '/price_tags/'),
    headers: {HttpHeaders.authorizationHeader: "Token $token"}
  );
  
  debugPrint(response.body);

  final responseJson = jsonDecode(response.body);
  if (responseJson['user_info'] != null) {
    EasyLoading.show(status: 'Logging in...');
    final response =
        await http.post(Uri.parse(Constants.API_ROUTE + '/login/'), body: {
      'username': nameController.text,
      'password': passwordController.text,
    });
    debugPrint(response.body);

    final responseJson = jsonDecode(response.body);
    var isAdmin =responseJson['user_info']['is_admin'].toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_user_token', responseJson['token']);
    EasyLoading.dismiss();
    Navigator.pushNamed(
        context, MainScreen.route, arguments: UserTypeArgument(isAdmin));
  } else {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('¡Error!'),
        content: const Text('Algunas credenciales eran incorrectas'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
    if (responseJson['username'] != null) {
      setState(() {
        _usernameCorrect = false;
      });
    }

    if (responseJson['email'] != null) {
      setState(() {
        _emailCorrect = false;
      });
    }
  }
}
class _AreaPersonalCliente extends State<AreaPersonalCliente> {
  bool processing = false;
  // ignore: prefer_final_fields
  List<PriceTags> _priceTags = [
    PriceTags(30,20),
    PriceTags(40,30),
    PriceTags(50,40),
    PriceTags(60,50),
  ];

  Future<void> onPressedLogOut() async {
    if (processing) return;
    processing = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse('https://buildgreen.herokuapp.com/logout/'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader:
            "Token " + prefs.getString("_user_token"),
      },
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> onPressedProfile() async {
    Navigator.pushNamed(context, EditProfilePage.route);
  }

  Future<void> onPressedConsejos() async {
    Navigator.pushNamed(context, ConsejosList.route);
  }

  Widget createbox() {
    return Flexible(
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(10.0),
        child: const Align(
          alignment: Alignment.topRight,
          child: Icon(Icons.arrow_forward_ios,
              color: Color.fromARGB(255, 94, 95, 94)),
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(

        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(
              left: 50,
              top: 10,
            ),
            child: Text(
              AppLocalizations.of(context)!.areapersonal,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  left: 50,
                  top: 100,
                ),
              ),
              createbox(),
              const Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
              ),
              createbox(),
              const Padding(
                padding: EdgeInsets.only(
                  right: 50,
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(
              left: 50,
              top: 10,
            ),
            child: Text(
              AppLocalizations.of(context)!.preciosatiemporeal,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 50,
                    top: 40,
                    right: 50,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .verpreciosatiemporeal,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const Image(
                        image: AssetImage("assets/images/euro.png"),
                        height: 50,
                        width: 50,
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.green,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(
              left: 50,
              top: 40,
            ),
            child: Text(
              AppLocalizations.of(context)!.consumoenergetico,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Container(
            height: 200.0,
            margin: const EdgeInsets.only(
              left: 50,
              top: 40,
              right: 50,
            ),
            padding: const EdgeInsets.all(10.0),
            child: const Image(
              fit: BoxFit.fill,
              image: AssetImage(
                  "assets/images/cual_es_el_gasto_en_electricidad2.png"),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Container(
            padding: const  EdgeInsets.all(10),
            child: GeneralButton(
              title: "Vida sostenible",
              action: onPressedConsejos,
              textColor: Colors.black,
            ),
          ),
          Container(
            padding: const  EdgeInsets.all(10),
            child: GeneralButton(
              title: "Acceder al Perfil",
              action: onPressedProfile,
              textColor: Colors.black,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: GeneralButton(
              title: "Cerrar Session",
              action: onPressedLogOut,
              textColor: Colors.black,
            ),
          ),

          Container(
            padding: EdgeInsets.all(10),
            child: SfCartesianChart(
              backgroundColor: Colors.white,
              series: <ChartSeries> [
                LineSeries<PriceTags, double>
                  (
                    dataSource: _priceTags,
                    xValueMapper: (PriceTags prices, _) => prices.x,
                    yValueMapper: (PriceTags prices, _) => prices.y,)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PriceTags {
  PriceTags(this.x, this.y);

  final double x;
  final double y;

}