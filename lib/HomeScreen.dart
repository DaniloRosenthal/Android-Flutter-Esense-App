import 'package:flutter/material.dart';

import 'ESenseFunctionality.dart';
import 'package:esense/CameraScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';
import 'ESenseFunctionality.dart';
import 'GalleryScreen.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  static double zAxisDouble = ESenseFunctionality.zAxisCalculated;
  String zAxisString = zAxisDouble.toString();

  String status = ESenseFunctionality.deviceStatus;
  String isButtonPressed = ESenseFunctionality.button;

  @override
  void initState() {
    super.initState();
    ESenseFunctionality.connectToESense();
    _listenToESenseEvents();
  }

  String getButtonPressed() {
    return isButtonPressed;
  }

  void _listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
          case ButtonEventChanged:
            isButtonPressed = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xffdbdbdb),
        body: new Center(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text(
              'Share your pictures with your friends!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color(0xff00263b),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
                'Share your most valuable memories with your friends and family. Take new pictures or '
                'browse your gallery.',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Color(0xff00a1ab),
                )),
            SizedBox(
              height: 40,
            ),
            Text(
              'SharePic tries to connect to your eSense Earbuds which can take a few seconds...',
              style: TextStyle(
                color: Color(0xff00a1ab),
              ),
            ),
            SizedBox(
              height: 13,
            ),
            Text(
              'eSense Device Status: \t$status',
              style: TextStyle(
                color: Color(0xff00a1ab),
              ),
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.red)),
              child: new Icon(
                Icons.bluetooth_connected,
                color: Colors.white,
              ),
              color: Color(0xff00263b),
              onPressed: () async {
                if (!ESenseManager.connected) {
                  setState(() {
                    status = 'not connected';
                  });
                } else {
                  print("Clicked");
                  setState(() {
                    status = 'connected';
                  });
                  /*Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new CameraScreen()),
                  );*/
                }
              },
            ),
            Text(
              'eSense Device Status: \t$isButtonPressed',
              style: TextStyle(
                color: Color(0xff00a1ab),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
