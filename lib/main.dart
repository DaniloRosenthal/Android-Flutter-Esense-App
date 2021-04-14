import 'package:esense/CameraScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';
import 'ESenseFunctionality.dart';
import 'GalleryScreen.dart';
import 'HomeScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String _deviceName = 'Unknown';
  static double _voltage = -1;
  static String _deviceStatus = '';
  static bool sampling = false;
  static String _event = '';
  static String _button = 'not pressed';
  static int _zAxis = 0;
  static double _zAxisCalculated = 0;

  String status = ESenseFunctionality.deviceStatus;
  int _bottomNavBarIndex = 0;
  final selectedPage = [HomeScreen(), CameraScreen(), GalleryScreen()];

  // the name of the eSense device to connect to -- change this to your own device.
  static String eSenseName = 'eSense-0151';

  @override
  void initState() {
    super.initState();
    connectToESense();
    //ESenseFunctionality.connectToESense();
  }

  Future<void> connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });

    con = await ESenseManager.connect(eSenseName);

    setState(() {
      _deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }

  void _listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
            break;
          case AccelerometerOffsetRead:
            // TODO
            break;
          case AdvertisementAndConnectionIntervalRead:
            // TODO
            break;
          case SensorConfigRead:
            // TODO
            break;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10),
        (timer) async => await ESenseManager.getBatteryVoltage());

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(
        Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    Timer(Duration(seconds: 3),
        () async => await ESenseManager.getAccelerometerOffset());
    Timer(
        Duration(seconds: 4),
        () async =>
            await ESenseManager.getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5),
        () async => await ESenseManager.getSensorConfig());
  }

  static StreamSubscription subscription;

  void startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      print('SENSOR event: $event');
      setState(() {
        _zAxis = event.accel[2];
        _zAxisCalculated = (_zAxis / 4096) * 9.80665;
        _event = event.toString();
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription.cancel();
    setState(() {
      sampling = false;
    });
  }

  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: new AppBar(
          backgroundColor: Color(0xff212121),
          title: new Text(
            "PicShare",
            style: TextStyle(color: Color(0xff00a1ab)),
          ),
        ),
        body: selectedPage[_bottomNavBarIndex],
        bottomNavigationBar: new BottomNavigationBar(
            currentIndex: _bottomNavBarIndex,
            onTap: (int index) {
              setState(() {
                _bottomNavBarIndex = index;
              });
            },
            items: [
              new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.home,
                ),
                title: Text(
                  'Home',
                  style: TextStyle(),
                ),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.camera_alt,
                ),
                title: Text(
                  'Take a photo',
                  style: TextStyle(),
                ),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.photo,
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(),
                ),
              ),
            ]),
      ),
    );
  }
}

/* home Scaffold(
      appBar: new AppBar(
        title: new Text("PicShare"),
      ),
    body: selectedPage[_bottomNavBarIndex],
    bottomNavigationBar: new BottomNavigationBar(
    currentIndex: _bottomNavBarIndex,
    onTap: (int index) {
    setState(() {
    _bottomNavBarIndex = index;
    });
    },
    items: [
    new BottomNavigationBarItem(
    icon: new Icon(Icons.home),
    title: Text('Home'),
    ),
    new BottomNavigationBarItem(
    icon: new Icon(Icons.camera_alt),
    title: Text('Take a photo'),
    ),
    new BottomNavigationBarItem(
    icon: new Icon(Icons.photo),
    title: Text('Gallery'),
    ),
    ]),
    );
    ),

  }
}*/

/*
class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String status = ESenseFunctionality.deviceStatus;
  int _bottomNavBarIndex = 0;
  final selectedPage = [HomeScreen(), CameraScreen(), GalleryScreen()];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("PicShare"),
      ),
      body: selectedPage[_bottomNavBarIndex],
      bottomNavigationBar: new BottomNavigationBar(
          currentIndex: _bottomNavBarIndex,
          onTap: (int index) {
            setState(() {
              _bottomNavBarIndex = index;
            });
          },
          items: [
            new BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: Text('Home'),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(Icons.camera_alt),
              title: Text('Take a photo'),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(Icons.photo),
              title: Text('Gallery'),
            ),
          ]),
    );
  }
}*/

/*
body: Align(
          alignment: Alignment.topLeft,
          child: ListView(
            children: [
              Text('eSense Device Status: \t$_deviceStatus'),
              Text('eSense Device Name: \t$_deviceName'),
              Text('eSense Battery Level: \t$_voltage'),
              Text('eSense Button Event: \t$_button'),
              Text(''),
              Text('$_event'),
              Text(''),
              Text('$_zAxis'),
              Text('$_zAxisCalculated'),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          // a floating button that starts/stops listening to sensor events.
          // is disabled until we're connected to the device.
          onPressed: () async {
            //_startListenToSensorEvents();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CameraScreen();
            }));
            ;
          },
          tooltip: 'Listen to eSense sensors',
          child: (!sampling) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
        ),


* (!ESenseManager.connected)
              ? null
              : (!sampling)
                  ? _startListenToSensorEvents
                  : _pauseListenToSensorEvents
*
*
* */
