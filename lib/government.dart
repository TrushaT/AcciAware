import 'dart:io';

import 'package:acciaware/data_visualization.dart';
import 'package:acciaware/delhi.dart';
import 'package:acciaware/main.dart';
import 'package:acciaware/risky.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class Government extends StatefulWidget {
  const Government({Key? key}) : super(key: key);

  @override
  State<Government> createState() => _GovernmentState();
}

class _GovernmentState extends State<Government> {
  int _activeStepIndex = 0;
  FileType pickingType = FileType.custom;
  String? _extension = "csv";
  String? fileChosen;
  String? file2Chosen;
  var _cities = ['Mumbai', 'Delhi'];
  String? _currentSelectedValue = 'Mumbai';

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text(
            'Enter Details',
            style: TextStyle(fontFamily: 'Bebas', letterSpacing: 2),
          ),
          content: Container(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Dept. Name',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: city,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'City',
                  ),
                ),
              ],
            ),
          ),
        ),
        Step(
          state: _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: const Text(
            'Upload Accident Record CSV File',
            style: TextStyle(
              fontFamily: 'Bebas',
              letterSpacing: 2,
            ),
          ),
          content: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: pickingType,
                      allowedExtensions: (_extension?.isNotEmpty ?? false)
                          ? _extension?.replaceAll(' ', '').split(',')
                          : null,
                    );

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      setState(() {
                        fileChosen = file.path.split('/').last;
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: const Text('Choose File'),
                ),
                (fileChosen != null)
                    ? Text(fileChosen!)
                    : const Text('No file chosen yet')
              ],
            ),
          ),
        ),
        Step(
          state: _activeStepIndex <= 2 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 2,
          title: const Text(
            'Upload Static Road Data CSV File',
            style: TextStyle(
              fontFamily: 'Bebas',
              letterSpacing: 2,
            ),
          ),
          content: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: pickingType,
                      allowedExtensions: (_extension?.isNotEmpty ?? false)
                          ? _extension?.replaceAll(' ', '').split(',')
                          : null,
                    );

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      setState(() {
                        file2Chosen = file.path.split('/').last;
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: const Text('Choose File'),
                ),
                (file2Chosen != null)
                    ? Text(file2Chosen!)
                    : const Text('No file chosen yet')
              ],
            ),
          ),
        ),
        Step(
          state: StepState.complete,
          isActive: _activeStepIndex >= 3,
          title: const Text(
            'View your City',
            style: TextStyle(
              fontFamily: 'Bebas',
              letterSpacing: 2,
            ),
          ),
          content: FormField<String>(
            builder: (FormFieldState<String> state) {
              return InputDecorator(
                decoration: InputDecoration(
                    // labelStyle: textStyle,
                    errorStyle: const TextStyle(
                        color: Colors.redAccent, fontSize: 16.0),
                    hintText: 'Please select expense',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
                isEmpty: _currentSelectedValue == '',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentSelectedValue,
                    isDense: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _currentSelectedValue = newValue;
                        state.didChange(newValue);
                      });
                    },
                    items: _cities.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ];
  // void _openFileExplorer() async {
  //   try {
  //     await FilePicker.platform.pickFiles(
  //     );
  //   } on PlatformException catch (e) {
  //     print("Unsupported operation" + e.toString());
  //   } catch (ex) {
  //     print(ex);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Governments"),
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
                  title: const Text("Past Accident Cases"),
                  leading: IconButton(
                    icon: const Icon(Icons.error),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => const Risky()));
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => const Risky()));
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
        body: Container(
            child: ListView(
          children: <Widget>[
            Card(
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _activeStepIndex,
                steps: stepList(),
                onStepContinue: () {
                  if (_activeStepIndex < (stepList().length - 1)) {
                    setState(() {
                      _activeStepIndex += 1;
                    });
                  } else {
                    print('Submitted');
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => const DelhiView()));
                  }
                },
                onStepCancel: () {
                  if (_activeStepIndex == 0) {
                    return;
                  }

                  setState(() {
                    _activeStepIndex -= 1;
                  });
                },
                onStepTapped: (int index) {
                  setState(() {
                    _activeStepIndex = index;
                  });
                },
                controlsBuilder: (context, ControlsDetails controls) {
                  final isLastStep = _activeStepIndex == stepList().length - 1;
                  return Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controls.onStepContinue,
                            child: (isLastStep)
                                ? const Text('Try It Out')
                                : const Text('Next'),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (_activeStepIndex > 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controls.onStepCancel,
                              child: const Text('Back'),
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
        )));
  }
}
