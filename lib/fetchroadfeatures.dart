import 'dart:convert';
import 'dart:io';

// import 'package:acciaware/model_params.dart';
import 'package:acciaware/weather.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:csv/csv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';

List<dynamic> steps = [
  {
    "distance": {"text": "3.3 km", "value": 3269},
    "duration": {"text": "13 mins", "value": 781},
    "end_location": {"lat": 19.2030566, "lng": 72.84945359999999},
    "html_instructions":
        "Head \u003cb\u003esoutheast\u003c/b\u003e on \u003cb\u003eLokmanya Tilak Rd\u003c/b\u003e/\u003cwbr/\u003e\u003cb\u003eSV Rd\u003c/b\u003e toward \u003cb\u003eSV Rd\u003c/b\u003e\u003cdiv style=\"font-size:0.9em\"\u003eContinue to follow SV Rd\u003c/div\u003e\u003cdiv style=\"font-size:0.9em\"\u003ePass by Lancelot Apartments (on the left in 1.4&nbsp;km)\u003c/div\u003e",
    "polyline": {
      "points":
          "g_ktBgyt{L?E@C?GTDjAP\\J`@JF@PF|@VFBRD|@Vb@Ld@L@?NBfD~@b@LHBzAd@`Ct@FBPDTHz@TVJlBh@j@N|Ad@B@@?ZJz@Xt@TlBn@LBtBp@rE~AVFp@LF@t@TRF\\LD@XJt@RnAb@bA`@l@JZJzBt@dAZb@Lf@PVJJDTHXJHB|AXTDl@H`BT@?j@FD?l@FZBN@z@?\\Er@KRGNEBAPIf@ULMr@o@p@c@?AFENGXMJGHCTGTEXCV@L@J@`ALrAP`ANPFjA`@RHbAb@p@TpAb@HDd@Lf@JB?p@LB@xATF@LBF?tBXhAJf@Dv@Hp@JbALl@HhBTh@H@?~AXt@Rj@HjAPJ@fEh@"
    },
    "start_location": {"lat": 19.2307624, "lng": 72.8566781},
    "travel_mode": "DRIVING"
  },
  {
    "distance": {"text": "0.2 km", "value": 189},
    "duration": {"text": "1 min", "value": 84},
    "end_location": {"lat": 19.2030297, "lng": 72.85123089999999},
    "html_instructions":
        "Turn \u003cb\u003eleft\u003c/b\u003e onto \u003cb\u003eFatak Rd\u003c/b\u003e",
    "maneuver": "turn-left",
    "polyline": {"points": "cretBals{LJO?GC}@BoB?{BEa@"},
    "start_location": {"lat": 19.2030566, "lng": 72.84945359999999},
    "travel_mode": "DRIVING"
  },
  {
    "distance": {"text": "13 m", "value": 13},
    "duration": {"text": "1 min", "value": 16},
    "end_location": {"lat": 19.2029131, "lng": 72.8512159},
    "html_instructions":
        "\u003cb\u003eFatak Rd\u003c/b\u003e turns \u003cb\u003eright\u003c/b\u003e and becomes \u003cb\u003eKasturba Rd\u003c/b\u003e/\u003cwbr/\u003e\u003cb\u003eTrikamdas Rd\u003c/b\u003e\u003cdiv style=\"font-size:0.9em\"\u003eDestination will be on the left\u003c/div\u003e",
    "polyline": {"points": "}qetBews{LV@"},
    "start_location": {"lat": 19.2030297, "lng": 72.85123089999999},
    "travel_mode": "DRIVING"
  }
];

getFeatures(List<dynamic> steps) async {
  // print(steps);
  List<dynamic> roadNames = [];
  for (var i = 0; i < steps.length; i++) {
    var singleIns = steps[i]["html_instructions"];
    var document = parse(singleIns);
    var elements = document.getElementsByTagName('b');
    List ele = elements.map((element) => element.text.toLowerCase()).toList();
    roadNames.addAll(ele);
  }
  Set<dynamic> roadNamesSet = roadNames.toSet();
  Set<String> directions = {
    "right",
    "left",
    "north",
    "northeast",
    "northwest",
    "south",
    "southeast",
    "southwest",
    "east",
    "west"
  };
  List roadsData = await fetchcsv();
  var choices = roadsData.map<String>((row) => row[0]).toList(growable: false);
  // print(choices);

  Set<dynamic> onlyRoads = roadNamesSet.difference(directions);
  // print(onlyRoads);
  List<dynamic> names = [];
  for (var i = 0; i < onlyRoads.length; i++) {
    // print(onlyRoads.elementAt(i));
    try {
      var top = extractOne(
        query: onlyRoads.elementAt(i),
        choices: choices,
        cutoff: 95,
      ).toString();
      // print(top.split(',')[0].substring(8));
      names.add(top.split(',')[0].substring(8));
    } catch (e) {
      names.add("Unknown: " + onlyRoads.elementAt(i));
    }
  }

  Map<String, Map<String, dynamic>> features = {};

  for (var name in names) {
    double shapeLength = 0;
    String highway = "";
    if (name.contains('Unknown:')) {
      shapeLength = 583.668;
      highway = "unclassified";
    }
    for (var row in roadsData) {
      if (name == row[0]) {
        highway = row[1];
        shapeLength = double.parse(row[2]);
        break;
      }
    }
    // print('Road: ${name}');
    // print(highway);
    // print(shapeLength);

    List<Location> locations = await locationFromAddress(name);
    var location = locations.first;
    var lat = location.latitude;
    var lon = location.longitude;
    // print(lat);
    // print(lon);

    Map<String, dynamic> weatherData =
        await getWeatherData(location.latitude, location.longitude);
    Map<String, dynamic> roadData = {
      'highway': highway,
      'shape_length': shapeLength,
      'lat': lat,
      'lon': lon
    };
    Map<String, dynamic> combinedWeatherRoadData = {};
    combinedWeatherRoadData.addAll(roadData);
    combinedWeatherRoadData.addAll(weatherData);

    features[name] = combinedWeatherRoadData;
  }
  print(features);
}

// Function to fetch data from CSV
Future<List> fetchcsv() async {
  List<dynamic> roadsData = [];
  final input = await rootBundle.loadString("assets/road_records.csv");
  LineSplitter ls = LineSplitter();
  ls.convert(input).forEach((l) => roadsData.add(l.split(',')));
  return roadsData;
}

// void main(List<String> args) {
//   getFeatures(steps);
// }

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => getFeatures(steps));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
