import 'dart:async';
import 'dart:math';

import 'package:acciaware/fetch_features.dart';
import 'package:acciaware/government.dart';
import 'package:acciaware/info_services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/parser.dart';
import 'package:loader_overlay/loader_overlay.dart';

class DelhiView extends StatefulWidget {
  const DelhiView({Key? key}) : super(key: key);
  @override
  State<DelhiView> createState() => _DelhiViewState();
}

class _DelhiViewState extends State<DelhiView> with TickerProviderStateMixin {
  late GoogleMapController mapController;

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Services services = Services();

  Map values = {};
  List<dynamic> steps = [];
  // Map<dynamic, dynamic> predictions = {};
  bool predictionsMadeOnce = false;

  int no_of_routes = 1;
  List<dynamic> preds = [];
  Map predScores = {};
  List<dynamic> roadNames = [];

  late TabController tabcontroller;
  Color indicatorColor = Colors.blue;

  Map delhi_predScores = {"Route 1": 22.50, "Route 2": 23.56, "Route 3": 24};

  List<dynamic> delhi_preds = [
    {
      "Lala Ganesh Dass Khatri Marg": {
        "accident_chance": 24.64,
        "outcome": "Safe"
      },
      "Sardar Bahadur Singh Marg ": {
        "accident_chance": 24.63,
        "outcome": "Safe"
      },
      "Najafgarh Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Shivaji Marg Flyover": {"accident_chance": 64.64, "outcome": "Safe"},
      "Satguru Ram Singh Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Old Rotak Road": {"accident_chance": 64.64, "outcome": "Safe"},
      "West Moti Bagh ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Azad Rd": {"accident_chance": 64.64, "outcome": "Safe"},
    },
    {
      "Widow Colony": {"accident_chance": 24.64, "outcome": "Safe"},
      "Lala Ganesh Dass Khatri Marg": {
        "accident_chance": 24.63,
        "outcome": "Safe"
      },
      "Mbs Nagar Rd ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Outer Ring Rd": {"accident_chance": 64.64, "outcome": "Safe"},
      "Raghubir Nagar Rd": {"accident_chance": 64.64, "outcome": "Safe"},
      "Baba Ramdev Marg": {"accident_chance": 64.64, "outcome": "Safe"},
      " Rotak Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Vir Banda Bairagi Marg": {"accident_chance": 64.64, "outcome": "Safe"},
      "Old Rohtak Rd": {"accident_chance": 64.64, "outcome": "Safe"},
      "Azad Rd": {"accident_chance": 64.64, "outcome": "Safe"},
    },
    {
      "Lala Ganesh Dass Khatri Marg": {
        "accident_chance": 24.64,
        "outcome": "Safe"
      },
      "Sardar Bahadur Singh Marg ": {
        "accident_chance": 24.63,
        "outcome": "Safe"
      },
      "Mall Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Najafgarh Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      " Shivaji Marg Flyover": {"accident_chance": 64.64, "outcome": "Safe"},
      "Mahatma Gandhi Marg": {"accident_chance": 64.64, "outcome": "Safe"},
      " Rotak Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Vir Banda Bairagi Marg": {"accident_chance": 64.64, "outcome": "Safe"},
      "Old Rohtak Rd": {"accident_chance": 64.64, "outcome": "Safe"},
      "Azad Rd": {"accident_chance": 64.64, "outcome": "Safe"},
    },
    {
      "Lala Ganesh Dass Khatri Marg": {
        "accident_chance": 24.64,
        "outcome": "Safe"
      },
      "Sardar Bahadur Singh Marg ": {
        "accident_chance": 24.63,
        "outcome": "Safe"
      },
      "Najafgarh Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Shivaji Marg Flyover": {"accident_chance": 64.64, "outcome": "Safe"},
      "Satguru Ram Singh Road ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Old Rotak Road": {"accident_chance": 64.64, "outcome": "Safe"},
      "West Moti Bagh ": {"accident_chance": 64.64, "outcome": "Safe"},
      "Azad Rd": {"accident_chance": 64.64, "outcome": "Safe"},
    },
  ];

  // List roads1 = [
  //   'LALA GANESH DASS KHATRI MARG',
  //   'SARDAR BAHADUR SINGH MARG',
  //   'NAJAFGARH ROAD',
  //   'SHIVAJI MARG FLYOVER',
  //   'SATGURU RAM SINGH ROAD ',
  //   'OLD ROTAK ROAD ',
  //   'WEST MOTI BAGH ',
  //   'AZAD RD',
  // ];

  String convertToTitleCase(String text) {
    if (text.length <= 1) {
      return text.toUpperCase();
    }

    // Split string into multiple words
    final List<String> words = text.split(' ');

    // Capitalize first letter of each words
    final capitalizedWords = words.map((word) {
      if (word.trim().isNotEmpty) {
        final String firstLetter = word.trim().substring(0, 1).toUpperCase();
        final String remainingLetters = word.trim().substring(1);

        return '$firstLetter$remainingLetters';
      }
      return '';
    });

    // Join/Merge all words back to one String
    return capitalizedWords.join(' ');
  }

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return SizedBox(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        // ignore: avoid_print
        // print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      // ignore: avoid_print
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';

      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          150.0,
        ),
      );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      return true;
    } catch (e) {
      print("ERROR CALCULATING DISTANCE");
      print(e);
    }
    return false;
  }

  // Get predictions for all routes
  // getPredictions() async {
  //   for (var i = 0; i < no_of_routes; i++) {
  //     var pred = await getFeatures(steps[i]);
  //     preds.add(pred);
  //     print(pred);
  //     // for (var v in pred.values) {
  //     //   print(v['accident_chance']);
  //     //   print(v['accident_chance'].runtimeType);
  //     // }
  //     double sum = 0;
  //     double count = 0;
  //     for (var v in pred.values) {
  //       sum += v['accident_chance'];
  //       count += 1;
  //     }
  //     predScores['Route ${i + 1}'] = (sum / count);
  //   }
  //   print("PREDS CALCULATED");
  //   return preds;
  // }

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    const String STATUS_OK = "ok";

    values = await services.getDirectionsinfo(startLatitude, startLongitude,
        destinationLatitude, destinationLongitude);
    PolylineResult result = PolylineResult();
    result.status = values["status"];
    if (values["status"]?.toLowerCase() == STATUS_OK &&
        values["routes"] != null &&
        values["routes"].isNotEmpty) {
      result.points = services.decodeEncodedPolyline(
          values["routes"][0]["overview_polyline"]["points"]);
      setState(() {
        _placeDistance =
            (values["routes"][0]["legs"][0]["distance"]["value"] / 1000)
                .toStringAsFixed(2);
      });
    } else {
      result.errorMessage = values["error_message"];
    }
    // print(result);

    no_of_routes = min(values["routes"].length, 3);
    print("NO OF ROUTES");
    print(no_of_routes);

    tabcontroller = TabController(vsync: this, length: no_of_routes);

    // steps = values["routes"][0]["legs"][0]["steps"];
    for (var i = 0; i < no_of_routes; i++) {
      var step = values["routes"][i]["legs"][0]["steps"];
      steps.add(step);
    }
    // print(steps);
    print("NO OF STEPS");
    print(steps.length);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    tabcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Widget _buildRow(int index, String name) {
      return Card(
          elevation: 3,
          child: ListTile(
            title: Text(
              (name.contains('Unknown:'))
                  ? convertToTitleCase(name.substring(name.indexOf(':') + 2))
                  : convertToTitleCase(name),
              style: const TextStyle(fontSize: 18.0),
            ),
            subtitle: (delhi_preds[index][name]["outcome"] == "Safe")
                ? Text(
                    delhi_preds[index][name]["outcome"],
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.green,
                    ),
                  )
                : (delhi_preds[index][name]["outcome"] == "Injurious")
                    ? Text(
                        preds[index][name]["outcome"],
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.orange),
                      )
                    : Text(
                        delhi_preds[index][name]["outcome"],
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.red,
                        ),
                      ),
            trailing: (delhi_preds[index][name]["outcome"] == "Safe")
                ? Text(
                    delhi_preds[index][name]["accident_chance"].toString() +
                        "%",
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                    ),
                  )
                : (delhi_preds[index][name]["outcome"] == "Injurious")
                    ? Text(
                        delhi_preds[index][name]["accident_chance"].toString() +
                            "%",
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.orange,
                        ),
                      )
                    : Text(
                        delhi_preds[index][name]["accident_chance"].toString() +
                            "%",
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                        ),
                      ),
          ));
    }

    // For each route, display list of roads
    pageBuilder(BuildContext context, int index, ScrollController controller) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
                controller: controller,
                itemCount: steps[index].length * 2,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (BuildContext context, int i) {
                  if (i.isOdd) {
                    return const Divider();
                  }
                  final idx = i ~/ 2;
                  var singleIns = steps[index]["html_instructions"];
                  var document = parse(singleIns);
                  var elements = document.getElementsByTagName('b');
                  List ele = elements
                      .map((element) => element.text.toLowerCase())
                      .toList();
                  roadNames.addAll(ele);
                  print(roadNames);
                  return _buildRow(index, roadNames[idx]);
                }),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Each tab of Tab Bar
    tabBuilder(BuildContext context, int index) {
      return Tab(
        icon: Column(
          children: [
            Text(
              'Route ${index + 1}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            (delhi_predScores['Route ${index + 1}'] < 50)
                ? Text(
                    '${delhi_predScores['Route ${index + 1}'].toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : Text(
                    '${delhi_predScores['Route ${index + 1}'].toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ],
        ),
      );
    }

    Widget buildSheet() {
      return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) => DefaultTabController(
              length: no_of_routes,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 5.0,
                        width: 70.0,
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Routes with Accident Chance',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TabBar(
                      controller: tabcontroller,
                      indicatorColor: Colors.blue,
                      tabs: List.generate(
                          no_of_routes, (index) => tabBuilder(context, index)),
                    ),
                    // const SizedBox(height: 12),
                    // const Center(
                    //   child: Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 24),
                    //       child: Text(
                    //         'Roads                Accident Chance',
                    //         style: TextStyle(fontSize: 20),
                    //       )),
                    // ),
                    Expanded(
                      child: TabBarView(
                          controller: tabcontroller,
                          children: List.generate(
                              no_of_routes,
                              (index) =>
                                  pageBuilder(context, index, controller))),
                    )
                  ],
                ),
              )));
    }

    return LoaderOverlay(
      child: SizedBox(
        height: height,
        width: width,
        child: Scaffold(
          appBar: AppBar(),
          drawer: SafeArea(
            child: Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Text(
                        "AcciAware",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text("Home"),
                    leading: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => DelhiView()));
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => DelhiView()));
                    },
                  ),
                  Divider(color: Colors.grey),
                  ListTile(
                    title: const Text("Governments"),
                    leading: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => Government()));
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => Government()));
                    },
                  ),
                  Divider(color: Colors.grey),
                  ListTile(
                    title: const Text("Past Accident Case"),
                    leading: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => Government()));
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => Government()));
                    },
                  ),
                  Divider(color: Colors.grey),
                ],
              ),
            ),
          ),
          body: Stack(
            children: [
              // child 1
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: const LatLng(20.5937, 78.9629),
                ),
                myLocationEnabled: true,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                markers: Set<Marker>.from(markers),
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              ),

              // Show zoom buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.blue.shade100, // button color
                          child: InkWell(
                            splashColor: Colors.blue, // inkwell color
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.zoom_in),
                            ),
                            onTap: () {
                              mapController.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipOval(
                        child: Material(
                          color: Colors.blue.shade100, // button color
                          child: InkWell(
                            splashColor: Colors.blue, // inkwell color
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.zoom_out),
                            ),
                            onTap: () {
                              // on button tap
                              mapController.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Show the place input fields & button for
              // showing the route
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      width: width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'AcciAware',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            const SizedBox(height: 10),
                            _textField(
                                label: 'Start',
                                hint: 'Choose starting point',
                                prefixIcon: const Icon(
                                  Icons.looks_one,
                                  color: Colors.blue,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.my_location),
                                  onPressed: () {
                                    startAddressController.text =
                                        _currentAddress;
                                    _startAddress = _currentAddress;
                                  },
                                ),
                                controller: startAddressController,
                                focusNode: startAddressFocusNode,
                                width: width,
                                locationCallback: (String value) {
                                  setState(() {
                                    _startAddress = value;
                                    predictionsMadeOnce = false;
                                    steps.clear();
                                  });
                                }),
                            const SizedBox(height: 10),
                            _textField(
                                label: 'Destination',
                                hint: 'Choose destination',
                                prefixIcon: const Icon(
                                  Icons.looks_two,
                                  color: Colors.red,
                                ),
                                controller: destinationAddressController,
                                focusNode: destinationAddressFocusNode,
                                width: width,
                                locationCallback: (String value) {
                                  setState(() {
                                    _destinationAddress = value;
                                    predictionsMadeOnce = false;
                                    steps.clear();
                                  });
                                }),
                            const SizedBox(height: 10),
                            Visibility(
                              visible: _placeDistance == null ? false : true,
                              child: Text(
                                'DISTANCE: $_placeDistance km',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: (_startAddress != '' &&
                                          _destinationAddress != '')
                                      ? () {
                                          // context.loaderOverlay.show();
                                          startAddressFocusNode.unfocus();
                                          destinationAddressFocusNode.unfocus();
                                          setState(() {
                                            if (markers.isNotEmpty)
                                              markers.clear();
                                            if (polylines.isNotEmpty) {
                                              polylines.clear();
                                            }
                                            if (polylineCoordinates
                                                .isNotEmpty) {
                                              polylineCoordinates.clear();
                                            }
                                            _placeDistance = null;
                                          });
                                          _calculateDistance()
                                              .then((isCalculated) {
                                            if (isCalculated) {
                                              // context.loaderOverlay.hide();
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: const [
                                                      Icon(
                                                        Icons.warning,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 15),
                                                      Text(
                                                        'Error: Source or Destination not found',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                              // context.loaderOverlay.hide();
                                            }
                                          });
                                        }
                                      : null,
                                  // color: Colors.red,
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(20.0),
                                  // ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      'Show Route'.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: (_startAddress != '' &&
                                          _destinationAddress != '')
                                      ? () async {
                                          if (steps.isNotEmpty &&
                                              predictionsMadeOnce == false) {
                                            context.loaderOverlay.show();
                                            // preds = await getPredictions();
                                            context.loaderOverlay.hide();
                                            predictionsMadeOnce = true;
                                          } else {
                                            if (steps.isEmpty) {
                                              preds.clear();
                                            }
                                          }
                                          (delhi_preds.isNotEmpty)
                                              ? showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  isDismissible: true,
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      16))),
                                                  builder: (context) {
                                                    return buildSheet();
                                                  })
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: const [
                                                        Icon(
                                                          Icons.warning,
                                                          color: Colors.red,
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'First Click Show Route then Show Roads',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                        }
                                      : null,
                                  // color: Colors.red,
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(20.0),
                                  // ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      'Show Roads'.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Show current location button
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                    child: ClipOval(
                      child: Material(
                        color: Colors.orange.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.orange, // inkwell color
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.my_location),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    _currentPosition.latitude,
                                    _currentPosition.longitude,
                                  ),
                                  zoom: 18.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }
}
