import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class NetworkHelper {
  NetworkHelper({required this.url});

  final String url;

  Future getData() async {
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      var logger = Logger();
      logger.e('Response Code: ${response.statusCode}');
    }
  }
}

class OpenWeatherMapWeatherApi {
  static const endPointUrl = 'https://api.openweathermap.org/data/2.5';
  static const apiKey = "4aaa7189955f46d461aebab4a2b86f5f";

  static const lat = 33.44;
  static const lon = -94.04;

  final requestUrl =
      '$endPointUrl/weather?lat=$lat&lon=$lon&apikey=$apiKey&units=metric';

  Future<dynamic> getCurrentWeather() async {
    NetworkHelper networkHelper = NetworkHelper(url: requestUrl);
    var weatherData = await networkHelper.getData();
    return weatherData;
  }
}

/* OpenWeatherMapWeatherApi weather = OpenWeatherMapWeatherApi();
var weatherData = await weather.getCurrentWeather();
var temp = weatherData['main']['temp'];
var rhum = weatherData['main']['humidity'];
var pres = weatherData['main']['pressure'];
var wspd = weatherData['wind']['speed'];
var wdir = weatherData['wind']['deg'];

// var prcp = weatherData['rain']['1h'];
print(weatherData); */