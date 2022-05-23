

import 'dart:async';
import 'dart:convert';

import 'package:buildgreen/screens/map_style.dart';
import 'package:buildgreen/screens/request_permission/request_permission_controller.dart';
import 'package:buildgreen/widgets/expandable_action_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;
import 'package:buildgreen/models/place.dart';

List<Marker> markersFromPlaces(List<Place> places) {
  List<Marker> markers = [];
  for (Place place in places) {
    markers.add(Marker(
      markerId: MarkerId(place.name),
      position: LatLng(place.latitude, place.longitude),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: place.number,

      ),
    ));
  }
  return markers;
}

class MapaScreen extends StatefulWidget {
  static const route = "/mapa";
  
  const MapaScreen({Key? key}) : super(key: key);

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}
class _MapaScreenState extends State<MapaScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final _lController = RequestPermissionController();
  GoogleMapController? _Gcontroller;
  Location currentLocation = Location();

  List<Place> allMarkers = [];

  List<Marker> allMarkersReal = [];// = markersFromPlaces(allMarkers);
  List<Marker> allChargers = [];// = markersFromPlaces(allMarkers);

  bool showChargers = false;


  static const CameraPosition _kBarcelona = CameraPosition(
    target: LatLng(41.4026556, 2.1587003),
    zoom: 17,
    tilt: 45,
  );

  final Set<Heatmap> _heatmaps = {};

  TextEditingController filterController = TextEditingController();
  
  Future<void> getHeatMap(String endpoint) async{
    EasyLoading.show(status: 'Loading map...', maskType: EasyLoadingMaskType.clear);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
        Uri.parse(Constants.API_ROUTE+endpoint),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: "Token " + prefs.getString("_user_token"),
        },
    );

    List<LatLng> locations = [];
    List<int> weights = [];

    final responseJson = jsonDecode(response.body);
    for (var result in responseJson){
      final latitude = double.parse(result['latitud']);
      final longitude = double.parse(result['longitud']);
      final emissions = result["value"];
      locations.add(LatLng(latitude, longitude));
      weights.add(double.parse(emissions).round());
    }

    setState(() {
      _heatmaps.clear();
      _heatmaps.add(
        Heatmap(
          heatmapId: HeatmapId("0"),
          points: _createPointsList(locations, weights),
          radius: 50,
          visible: true,
          gradient:  HeatmapGradient(
            colors: const <Color>[Colors.green, Colors.red], startPoints: const <double>[0.1, 1]
          )
        )
      );
    },
  );
    EasyLoading.dismiss();    
  }

  Future<List<Place>> generateItems(String endpoint) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse(Constants.API_ROUTE + endpoint),
      headers: <String, String>{
        HttpHeaders.authorizationHeader:
            "Token " + prefs.getString("_user_token"),
      },
    );

    final responseJson = jsonDecode(response.body);
    List<Place> resultado = [];
    for (var current in responseJson) {
      final String route = current['address'] + current['apt'] + ',' +current['postal_code'];
      Place result =  Place(
        name: current['name'],
        number: current['number'],
        latitude: double.parse(current['latitud']),
        longitude: double.parse(current['longitud']),
        postalCode: ""
      );
      resultado.add(result);
    }
    return resultado;
  } //end generateItems

  Future<List<Marker>> generateCargadores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("http://electrike.ddns.net:3784/near_chargers?lat=41.390205&lon=2.154007&dist=2"),
      headers: <String, String>{
        HttpHeaders.authorizationHeader:
            "Token " + prefs.getString("_user_token"),
      },
    );

    final responseJson = jsonDecode(response.body);
    List<Marker> resultado = [];
    List<dynamic> markers = responseJson['items'];
    //return resultado;
    for (var current in markers) {
      Marker result =  Marker(
        markerId: MarkerId(current['Station_address']),
        icon: BitmapDescriptor.fromAsset('assets/images/charger.png'),

        position: LatLng(current["Station_lat"] ?? 0.0, current['Station_lng'] ?? 0.0),
        infoWindow: InfoWindow(
          title: current['Station_address'],
          snippet: current['Station_address'],
        ),
      );
      resultado.add(result);
    }
    return resultado;
  } //end generateItems
 
  @override
  Widget build(BuildContext context) {
    _lController.request();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(

          children: [
            Container(
              decoration: const BoxDecoration(
                 gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromARGB(255, 56, 22, 65),
                    Color.fromARGB(255, 0, 0, 0),
                  ],)
              ),
            ),
            Column(
            children: [
              /// MAPS
              Expanded(    
                flex: 1,          
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: const[
                        BoxShadow(
                          color: Colors.green,
                          blurRadius: 10,
                          spreadRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GoogleMap(
                        initialCameraPosition: _kBarcelona,
                        heatmaps: _heatmaps,
                        compassEnabled: true,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        zoomGesturesEnabled: true,
                        buildingsEnabled: false,
                        markers:  (allMarkersReal +  ((showChargers)? allChargers : [])).toSet(),
                        indoorViewEnabled: false,
                        onMapCreated: (GoogleMapController controller) async {
                          _controller.complete(controller);
                          final location = await currentLocation.getLocation();
                          _Gcontroller = controller;
                          controller.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(location.latitude??0.0, location.longitude??0.0),
                              zoom: 17,
                              tilt: 45,
                            ),
                          ));
                          setState(() {
                            controller.setMapStyle(mapStyle);  
                          });
                          
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                    onPressed: (){
                      
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      shadowColor: Colors.white,
                      primary: Colors.yellowAccent,
                      side: BorderSide(color: Color.fromARGB(255, 60, 33, 105), width: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Container(
                        padding: EdgeInsets.fromLTRB(0,0,0,20),
                        child: const Text("ADD CRAP",style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Mustasurma',
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),),
                      ),
                      ]
                    )),
              ),
                  )
              ,Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: (){
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightGreenAccent,
                      shadowColor: Colors.white,
                      elevation: 10,
                      side: BorderSide(color: Colors.pinkAccent, width: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Container(
                        padding: EdgeInsets.fromLTRB(0,0,0,20),
                        child: const Text("I'M STUCK",style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Mustasurma',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 69, 42, 142),
                        ),),
                      ),
                      ]
                    )),
                ),
              )
                ],
              ),
              
            
            ],
          ),
          ]
        ),
      ),
    );
  }

  List<WeightedLatLng> _createPointsList(List<LatLng> locationList, List<int> wheights) {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    var index = 0;
    while (index < locationList.length){
      final location = locationList[index];
      final wheight = wheights[index];
      points.add(WeightedLatLng(point: location, intensity: wheight) );
      index += 1;
    }
    return points;
  }
}
