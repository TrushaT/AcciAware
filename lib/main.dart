import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Map Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _locationSubscription;
  final Location _locationTracker = Location();
  Marker? marker;
  Circle? circle;
  GoogleMapController? _controller;

  static const CameraPosition initialLocation = CameraPosition(
    target: LatLng(19.0760, 72.8777),
    zoom: 14,
  );

  // ignore: prefer_typing_uninitialized_variables
  var cameraUpdate;

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerandCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latLng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    // ignore: unnecessary_this
    this.setState(() {
      marker = Marker(
          markerId: const MarkerId("home"),
          position: latLng,
          rotation: newLocalData.heading!,
          draggable: false,
          zIndex: 2, //marker above circle
          flat: true,
          anchor: const Offset(0.5, 0.5), //so circle and car both move
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: const CircleId("car"),
          radius: newLocalData.accuracy!,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latLng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerandCircle(location, imageData);

      _locationSubscription?.cancel();

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller?.animateCamera(cameraUpdate.newCameraPosition(
              // ignore: unnecessary_new
              new CameraPosition(
                  bearing: 192.83,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerandCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        initialCameraPosition: initialLocation,
        markers: Set.of((marker != null) ? [marker!] : []),
        circles: Set.of((circle != null) ? [circle!] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}
