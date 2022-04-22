import 'package:acciaware/government.dart';
import 'package:acciaware/main.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class DataVisualizer extends StatefulWidget {
  const DataVisualizer({Key? key}) : super(key: key);

  @override
  State<DataVisualizer> createState() => _DataVisualizerState();
}

class _DataVisualizerState extends State<DataVisualizer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Data Visualizer"),
        ),
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
                          builder: (BuildContext context) => const MapView()));
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => const MapView()));
                  },
                ),
                const Divider(color: Colors.grey),
                ListTile(
                  title: const Text("Governments"),
                  leading: IconButton(
                    icon: const Icon(Icons.people),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const Government()));
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => const Government()));
                  },
                ),
                const Divider(color: Colors.grey),
                ListTile(
                  title: const Text("Past Accident Case"),
                  leading: IconButton(
                    icon: const Icon(Icons.error),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const Government()));
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => const Government()));
                  },
                ),
                const Divider(color: Colors.grey),
                ListTile(
                    title: const Text("Data Visualization"),
                    leading: IconButton(
                      icon: const Icon(Icons.pie_chart),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => const DataVisualizer()));
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) =>const DataVisualizer()));
                    },
                  ),
              ],
            ),
          ),
        ),
        body: ListView(children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              SizedBox(
                width: 400,
                height: 400,
                child: Image(
                  image: AssetImage('assets/blackspots.jpeg'),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Crash Spot Identification ',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                
                  ],
                ),
               
                SizedBox(height: 10)

              ])
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),


Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              SizedBox(
                width: 400,
                height: 400,
                child: Image(
                  image: AssetImage('assets/bardata.jpeg'),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      ' Crash Frequency, by Hour',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                
                  ],
                ),
               
                SizedBox(height: 10)

              ])
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
        



 Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              SizedBox(
                width: 400,
                height: 400,
                child: Image(
                  image: AssetImage('assets/winddata.jpeg'),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      ' WindImpact',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                
                  ],
                ),
               
                SizedBox(height: 10)

              ])
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
        
Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              SizedBox(
                width: 400,
                height: 400,
                child: Image(
                  image: AssetImage('assets/blackandwhite.jpeg'),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Snazzy Maps',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                
                  ],
                ),
               
                SizedBox(height: 10)

              ])
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
        

      ]),);
  }
}
