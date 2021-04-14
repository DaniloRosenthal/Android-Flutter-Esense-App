import 'package:esense/HomeScreen.dart';
import 'package:flutter/material.dart';

import 'ESenseFunctionality.dart';
import 'dart:async';
import 'HomeScreen.dart';

import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen> {
  static double zAxisDouble = ESenseFunctionality.zAxisCalculated;
  String zAxisString = zAxisDouble.toString();
  String buttonPressing = ESenseFunctionality.button;

  @override
  void initState() {
    super.initState();
    //ESenseFunctionality.startListenToSensorEvents();
  }

  Future<String> getZAxisData() async {
    /*var weatherData = _MyAppState().dispose();

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LocationScreen(
        locationWeather: weatherData,
      );
    }));*/
    setState(() {
      ESenseFunctionality.startListenToSensorEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('eSense Device Status: \t$buttonPressing'),
        ),
      ),
    );
  }
}
