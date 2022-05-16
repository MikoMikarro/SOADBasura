class Place {
  String name;
  String number;
  String postalCode;
  double latitude;
  double longitude;
  

  Place({required this.name, required this.number, required this.postalCode, required this.latitude, required this.longitude});

  factory Place.fromSearch(Map<String, dynamic> json){
    final String formattedAddress = json['formatted_address'];
    List<String> address = formattedAddress.split(',');
    String cp = address[2].split(' ')[1];
    final latLang = json['geometry']['location'];
    return Place(name: address[0], number: address[1], postalCode: cp,  latitude: latLang['lat'], longitude: latLang['lng']);
  }

  factory Place.fromJSON(Map<String, dynamic> parsedJson) {
    String numberAddress = "";
    String nameAddress = "";
    String pCode = "";

    List<dynamic> addressComponents = parsedJson['address_components'];

    double latitude = parsedJson['geometry']['location']['lat'];	
    double longitude = parsedJson['geometry']['location']['lng'];

    for (var i = 0; i < addressComponents.length; i++) {
      for (var j = 0; j < addressComponents[i]['types'].length; j++) {
        if (addressComponents[i]['types'][j] == "postal_code") {
          pCode = addressComponents[i]['long_name'];
        }
        else if (addressComponents[i]['types'][j] == "street_number") {
          numberAddress = addressComponents[i]['long_name'];
        }
        else if (addressComponents[i]['types'][j] == "route") {
          nameAddress = addressComponents[i]['long_name'];
        }
      }
    }

    return Place(name: nameAddress, number: numberAddress, postalCode: pCode, latitude: latitude, longitude: longitude);
  }
}
