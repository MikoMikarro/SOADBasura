import 'package:buildgreen/widgets/places_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/place.dart';

class PlacesService {
  final kGoogleApiKey = "AIzaSyCLFW_y78tJfYic8xMrzTxGbZVxnVgyCBs";

  Future<List<PlacesSearch>> getAutocomplete(String search) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&strictbounds=true&location=41.3879,2.16992&radius=8000&types=address&language=es&key=$kGoogleApiKey";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['predictions'] as List;

    return jsonResult.map((place) => PlacesSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey"; //revisar url
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJSON(jsonResult); 
  }

  Future<Place> getPlaceByName(String placeName) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$placeName&inputtype=textquery&fields=formatted_address,geometry&key=$kGoogleApiKey"; //revisar url
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = (json['candidates'])[0] as Map<String, dynamic>;
    return Place.fromSearch(jsonResult);
  }
}
