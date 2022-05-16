import 'package:buildgreen/screens/building_view.dart';
import 'package:buildgreen/screens/forms/new_admin_property.dart';
import 'package:buildgreen/screens/forms/consejo_dia_view.dart';
import 'package:buildgreen/screens/forms/edit_profile_page.dart';
import 'package:buildgreen/screens/forms/new_appliance.dart';
import 'package:buildgreen/screens/forms/new_building.dart';
import 'package:buildgreen/screens/forms/new_property.dart';
import 'package:buildgreen/screens/forms/signup_screen.dart';
import 'package:buildgreen/screens/lista_consejos_personal.dart';
import 'package:buildgreen/screens/lista_electrodomesticos.dart';
import 'package:buildgreen/screens/forms/login_screen.dart';
import 'package:buildgreen/screens/main_screen.dart';
import 'package:buildgreen/screens/resultados_simulacion.dart';
import 'package:buildgreen/service_subscriber.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:buildgreen/screens/sim_lista.dart';

import 'package:buildgreen/screens/welcome_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/forms/new_appliance.dart';
import 'screens/forms/signup_screen.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

late Locale _locale = const Locale('es', 'ES');

class _MyAppState extends State<MyApp> {
  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplicationBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/',
        routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        // When navigating to the "/second" route, build the SecondScreen widget.
        LogInScreen.route           :(context) => const LogInScreen(),
        SignUpScreen.route          :(context) => const SignUpScreen(),
        MainScreen.route            :(context) => const MainScreen(),
        ListaSimulacion.route       :(context) => const ListaSimulacion(),
        ElectrodomesticoList.route  :(context) => const ElectrodomesticoList(),
        NewAppliance.route          :(context) => const NewAppliance(),
        ResultadosSimulacion.route  :(context) => const ResultadosSimulacion(), 
        WelcomeScreen.route         :(context) => const WelcomeScreen(),
        NewProperty.route           :(context) => const NewProperty(),
        NewBuilding.route           :(context) => const NewBuilding(),
        BuildingView.route          :(context) => const BuildingView(),
        NewAdminProperty.route      :(context) => const NewAdminProperty(),
        EditProfilePage.route       :(context) => const EditProfilePage(),
        ConsejosList.route          :(context) => const ConsejosList(),
        ConsejoDetalle.route        :(context) => const ConsejoDetalle(),
        },
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Arial',
          textTheme: const TextTheme(
            headline1: TextStyle(
                fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, color: Colors.black),
            bodyText1: TextStyle(fontSize: 14.0, color: Colors.white),
            headline2: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            headline5: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black,
            ),
          ),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _locale,
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('ca', 'CAT'),
        ],
        home: const WelcomeScreen(),
        builder: EasyLoading.init(),
        
      ),
    );
  }
}
