

import 'package:buildgreen/screens/mapa_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter/material.dart';

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
    return MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/',
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
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('ca', 'CAT'),
        ],
        home: MapaScreen(),
        builder: EasyLoading.init(),
        
    );
  }
}
