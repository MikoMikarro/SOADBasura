import 'package:buildgreen/screens/area_personal_cliente.dart';
import 'package:buildgreen/screens/arguments/user_type_argument.dart';
import 'package:buildgreen/screens/lista_edificios.dart';
import 'package:buildgreen/screens/lista_propiedades.dart';
import 'package:buildgreen/screens/mapa_screen.dart';
import 'package:flutter/material.dart';
class MainScreen extends StatefulWidget {

  static const route = '/index';

  const MainScreen({ Key? key ,}) : super(key: key);
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _selectedIndex = 0;
  PageController pageController = PageController();
  
  void onTapNavBar(int index){
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isAdmin = ModalRoute.of(context)!.settings.arguments as UserTypeArgument;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      
      backgroundColor: Colors.transparent,
      body: Container(
          child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                     _selectedIndex = value;
                  });
                },
                controller: pageController,
                children: <Widget>[
                  const AreaPersonalCliente(),
                  (isAdmin.isAdmin == "true")? const ListaEdificios(): const ListaPropiedades(),
                  MapaScreen(isAdmin: isAdmin.isAdmin),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: ""),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: onTapNavBar,
      ),
    );
  }
}