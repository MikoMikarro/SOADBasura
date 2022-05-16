
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';

class Place {
  String placeName;
  String placeAddress;
  String description;
  LatLng locationCords;

  Place(
    {
      required this.placeName,
      required this.placeAddress,
      required this.description,
      required this.locationCords,
    }
  );
}


final List<Place> placeList = [
  Place(
    description: "prueba 1 desc",
    placeName: "Prueba 1 name",
    placeAddress: "Prueba 1 address",
    locationCords: const LatLng(41.4026556, 2.1587003),
  ),
  Place(
    description: "prueba 2 desc",
    placeName: "Prueba 2 name",
    placeAddress: "Prueba 2 address",
    locationCords: const LatLng(41.7026556, 2.1),
  )
];