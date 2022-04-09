import 'package:acciaware/secrets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


const apiKey = Secrets.API_KEY;

class Services {
   Future<String> getRoads( double startLatitude,double startLongitude,double destinationLatitude,double destinationLongitude)
   async{
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${startLatitude},${startLongitude}&destination=${destinationLatitude},${destinationLongitude}&key=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    return values["routes"][0]["html_instructions"];
  }
}