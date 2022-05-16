// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:buildgreen/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

class ResultadosSimulacion extends StatefulWidget {
  static const route = "/sim_result";

  const ResultadosSimulacion({Key? key}) : super(key: key);

  @override
  State<ResultadosSimulacion> createState() => _ResultadosSimulacion();
}

Future<List<double>> updateConsumption() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final response = await http.get(
    Uri.parse(Constants.API_ROUTE + '/appliances?property=' +
        prefs.getString('_actual_property') +
        '&sim'),
    headers: <String, String>{
      HttpHeaders.authorizationHeader:
          "Token " + prefs.getString("_user_token"),
    },
  );

  final responseJson = jsonDecode(response.body);

  double mC = responseJson["morning cons"].toDouble();
  double nC = responseJson["noon cons"].toDouble();
  double n2C = responseJson["night cons"].toDouble();

  return [mC, nC, n2C];
}

class _ResultadosSimulacion extends State<ResultadosSimulacion> {
  double morningConsume = 0;
  double noonConsume = 0;
  double nightConsume = 0;

  _ResultadosSimulacion() {
    updateConsumption().then(
      (val) => setState(
        () {
          morningConsume += val[0];
          noonConsume += val[1];
          nightConsume += val[2];
        },
      ),
    );
  }

  double getMax() {
    if (morningConsume > noonConsume && morningConsume > nightConsume) {
      return morningConsume;
    }
    if (noonConsume > nightConsume) return noonConsume;

    return nightConsume;
  }

  double getMin() {
    if (morningConsume < noonConsume && morningConsume < nightConsume) {
      return morningConsume;
    }
    if (noonConsume < nightConsume) return noonConsume;

    return nightConsume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(
              top: 30,
            ),
            child: Text(
              AppLocalizations.of(context)!.resultadossimulacion,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
          //
          /// Espacio
          Expanded(child: Container()),

          /// Espacio
          //

          ////// MORNING
          Container(
            padding: const EdgeInsets.all(20),
            child: Icon(Icons.wb_sunny,
                size: 50,
                color: morningConsume == getMax() ? Colors.red : Colors.black),
          ),
          AnimatedFlipCounter(
            duration: const Duration(milliseconds: 1500),
            value: morningConsume,
            suffix: AppLocalizations.of(context)!.kw,
            thousandSeparator: '.',
            decimalSeparator: ',',
            fractionDigits: 2,
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: morningConsume == getMax() ? Colors.red : Colors.black,
                shadows: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                  ),
                ]),
          ),

          ////// NOON
          Container(
            padding: const EdgeInsets.all(20),
            child: Icon(Icons.brightness_4,
                size: 50,
                color: noonConsume == getMax() ? Colors.red : Colors.black),
          ),
          AnimatedFlipCounter(
            duration: const Duration(milliseconds: 500),
            value: noonConsume,
            suffix: AppLocalizations.of(context)!.kw,
            thousandSeparator: '.',
            decimalSeparator: ',',
            fractionDigits: 2,
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: noonConsume == getMax() ? Colors.red : Colors.black,
                shadows: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                  ),
                ]),
          ),

          ///// NIGHT
          Container(
            padding: const EdgeInsets.all(20),
            child: Icon(
              Icons.brightness_2,
              size: 50,
              color: nightConsume == getMax() ? Colors.red : Colors.black,
            ),
          ),
          AnimatedFlipCounter(
            duration: const Duration(milliseconds: 1000),
            value: nightConsume,
            suffix: AppLocalizations.of(context)!.kw,
            fractionDigits: 2,
            thousandSeparator: '.',
            decimalSeparator: ',',
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: nightConsume == getMax() ? Colors.red : Colors.black,
                shadows: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                  ),
                ]),
          ),

          /// Espacio
          Expanded(child: Container()),

          /// Espacio

          const CustomBackButton(),
          const Padding(padding: EdgeInsets.all(20)),
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
    ));
  }
}
