import 'dart:convert';
import "dart:math";
import "dart:core";

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Utility function for getWeatherData
dynamic _check(Map feature, String subFeature) {
  if (feature.keys.contains(subFeature)) {
    return feature[subFeature];
  }
  return 0;
}

// Get address from latitude and longitude
Future<String> _getAddressFromLatLong(Position position) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark place = placemarks[0];
  String address =
      '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  return address;
}

// Get latitude and longitude of user
Future<Position> _getGeoLocationPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    await Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

// Get weather data of user
void getWeatherData() async {
  const endPointUrl = 'https://api.openweathermap.org/data/2.5';
  const apiKey = "4aaa7189955f46d461aebab4a2b86f5f";

  Position currentCoordinates = await _getGeoLocationPosition();
  var lat = currentCoordinates.latitude;
  var lon = currentCoordinates.longitude;
  print('lat: $lat');
  print('lon: $lon');

  String address = await _getAddressFromLatLong(currentCoordinates);
  print(address);

  var requestUrl =
      '$endPointUrl/weather?lat=$lat&lon=$lon&apikey=$apiKey&units=metric';

  var url = Uri.parse(requestUrl);

  var response = await http.get(url);

  if (response.statusCode == 200) {
    final Map jsonResponse = jsonDecode(response.body);
    final attr = jsonResponse.keys;

    double temp = 0;
    double dwpt = 0;
    double rhum = 0;
    double prcp = 0;
    double wdir = 0;
    double wspd = 0;
    double pres = 0;
    double coco = 2.0;
    String light = "";
    String weather = "";

    if (attr.contains('main')) {
      final main = jsonResponse['main'];
      temp = _check(main, 'temp').toDouble();
      rhum = _check(main, 'humidity').toDouble();
      pres = _check(main, 'pressure').toDouble();
      print('temp: $temp');
      print('rhum: $rhum');
      print('pres: $pres');
    }

    if (attr.contains('wind')) {
      final wind = jsonResponse['wind'];
      wspd = _check(wind, 'speed').toDouble();
      wdir = _check(wind, 'deg').toDouble();
      print('wspd: $wspd');
      print('wdir: $wdir');
    }

    if (attr.contains('rain')) {
      final rain = jsonResponse['rain'];
      prcp = _check(rain, '1h').toDouble();
      print('prcp: $prcp');
      if (prcp == 0) {
        prcp = _check(rain, '3h').toDouble();
      }
      print('prcp: $prcp');
    } else {
      prcp = 0;
      print('prcp: $prcp');
    }

    if (attr.contains('weather')) {
      final id = jsonResponse['weather'][0]['id'];
      switch (id) {
        // Thunderstorm
        case 200:
        case 201:
        case 210:
        case 211:
        case 221:
        case 230:
        case 231:
        case 232:
          coco = 25.0;
          break;
        case 202:
        case 212:
          coco = 26.0;
          break;

        // Drizzle
        case 300:
        case 301:
        case 302:
        case 310:
        case 311:
        case 312:
        case 313:
        case 314:
        case 321:
          coco = 7.0;
          break;

        // Rain
        case 500:
        case 520:
          coco = 7.0;
          break;
        case 501:
        case 531:
          coco = 8.0;
          break;
        case 502:
        case 503:
        case 504:
          coco = 9.0;
          break;
        case 511:
          coco = 10.0;
          break;
        case 521:
          coco = 17.0;
          break;
        case 522:
          coco = 18.0;
          break;

        // Snow
        case 600:
        case 601:
          coco = 15.0;
          break;
        case 602:
          coco = 16.0;
          break;
        case 611:
          coco = 12.0;
          break;
        case 612:
        case 613:
          coco = 19.0;
          break;
        case 615:
        case 616:
        case 620:
        case 621:
          coco = 21.0;
          break;
        case 622:
          coco = 22.0;
          break;

        // Atmosphere
        case 741:
        case 701:
        case 711:
        case 721:
        case 731:
        case 751:
        case 761:
        case 762:
        case 771:
        case 781:
          coco = 5.0;
          break;

        // Clear
        case 800:
          coco = 1.0;
          break;

        // Clouds
        case 801:
        case 802:
          coco = 2.0;
          break;
        case 803:
          coco = 3.0;
          break;
        case 804:
          coco = 4.0;
          break;
      }
      print('coco: $coco');
    }

    dwpt = ((temp -
                (14.55 + 0.114 * temp) * (1 - (0.01 * rhum)) -
                pow(((2.5 + 0.007 * temp) * (1 - (0.01 * rhum))), 3) -
                (15.9 + 0.117 * temp) * pow((1 - (0.01 * rhum)), 14))
            .round())
        .toDouble();
    print('dwpt: $dwpt');

    var currentDateTime =
        DateTime.fromMillisecondsSinceEpoch(jsonResponse['dt'] * 1000);
    var hour = currentDateTime.hour;
    if (hour >= 4 && hour <= 7) {
      light = 'dawn';
    } else if (hour > 7 && hour < 17) {
      light = 'day';
    } else if (hour >= 17 && hour <= 19) {
      light = 'dusk';
    } else {
      light = 'night';
    }
    print('light: $light');

    if (coco == 5.0) {
      weather = 'fog';
    } else if (coco == 4.0) {
      weather = 'cloudy';
    } else if (coco == 1.0) {
      if (light == 'day' || light == 'dusk') {
        weather = 'clear-day';
      } else {
        weather = 'clear-night';
      }
    } else if (coco == 3.0) {
      if (light == 'day' || light == 'dusk') {
        weather = 'partly-cloudy-day';
      } else {
        weather = 'partly-cloudy-night';
      }
    } else {
      weather = 'None';
    }
    print('weather: $weather');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

/* void main(List<String> args) {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getWeatherData();
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getWeatherData());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
} */
