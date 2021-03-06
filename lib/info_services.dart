import 'package:acciaware/secrets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:osm_nominatim/osm_nominatim.dart';

const apiKey = Secrets.API_KEY;

class Services {
  Future<Map> getDirectionsinfo(double startLatitude, double startLongitude,
      double destinationLatitude, double destinationLongitude) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startLatitude},${startLongitude}&destination=${destinationLatitude},${destinationLongitude}&alternatives=true&key=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    var values = jsonDecode(response.body);
    // print(values);
    // print(values["status"]);
    return values;
  }

  Future<Map<String, dynamic>> getPrediction(
      Map<String, dynamic>? input) async {
    String url = "http://acciaware-api.herokuapp.com/predict/";
    http.Response response = await http.post(
      Uri.parse(url),
      body: jsonEncode(input),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var values = jsonDecode(response.body);
    return values;
  }

  // Future<String> getnearbyPoliceStation(
  //     double Latitude, double Longitude) async {
  //   String url =
  //       "https://maps.googleapis.com/maps/api/place/search/json?location=${Latitude},${Longitude}&rankby=distance&types=police&sensor=false&key=$apiKey";
  //   http.Response response = await http.get(Uri.parse(url));
  //   var values = jsonDecode(response.body);
  //   // print(values["results"][0]["name"]);
  //   var police_station = values["results"][0]["name"];
  //   return police_station;
  // }

  Future<String> getZone(double latitude, double longitude) async {
    final reverseSearchResult = await Nominatim.reverseSearch(
      lat: latitude,
      lon: longitude,
      addressDetails: true,
      extraTags: true,
      nameDetails: true,
    );

    String zone = reverseSearchResult.address?['city_district'];
    if (!['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4', 'Zone 5', 'Zone 6']
        .contains(zone)) {
      zone = 'Unknown';
    }
    return zone;
  }

  Map<String, dynamic> getTimeVariables() {
    DateTime now = DateTime.now();
    Map<String, dynamic> map = {};
    map['hour'] = (now.hour).toDouble();
    map['year'] = (now.year).toDouble();
    map['month'] = (now.month).toDouble();
    map['date'] = (now.day).toDouble();
    map['day'] = (now.weekday - 1).toDouble();
    return map;
  }

  List<PointLatLng> decodeEncodedPolyline(String encoded) {
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      PointLatLng p =
          new PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
