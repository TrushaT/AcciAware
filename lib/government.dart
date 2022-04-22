import 'package:flutter/material.dart';

class Government extends StatefulWidget {
  const Government({Key? key}) : super(key: key);

  @override
  State<Government> createState() => _GovernmentState();
}

class _GovernmentState extends State<Government> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Governments"),
        ),
        body: Container(
            child: ListView(
          children: <Widget>[
            Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Stack(children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Stack(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 10, top: 5),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              "Governments. Please upload your collected data and we will shortly return to you with prediction services.")),
                                    )
                                  ],
                                )
                              ],
                            ))
                      ],
                    ),
                  )
                ]),
              ),
            ),
            Card(
                // child: Stepper(

                // ),
                )
          ],
          padding: EdgeInsets.all(10),
          shrinkWrap: true,
        )));
  }
}
