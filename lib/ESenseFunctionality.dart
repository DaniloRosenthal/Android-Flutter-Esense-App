import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';

class ESenseFunctionality {
  static String deviceName = 'Unknown';
  static double voltage = -1;
  static String deviceStatus = '';
  static bool sampling = false;
  static String eventString = '';
  static String button = 'not pressed';
  static int zAxis = 0;
  static double zAxisCalculated = 0;

  // the name of the eSense device to connect to -- change this to your own device.
  static String eSenseName = 'eSense-0151';

  static Future<void> connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) listenToESenseEvents();

      switch (event.type) {
        case ConnectionType.connected:
          deviceStatus = 'connected';
          break;
        case ConnectionType.unknown:
          deviceStatus = 'unknown';
          break;
        case ConnectionType.disconnected:
          deviceStatus = 'disconnected';
          break;
        case ConnectionType.device_found:
          deviceStatus = 'device_found';
          break;
        case ConnectionType.device_not_found:
          deviceStatus = 'device_not_found';
          break;
      }
    });

    con = await ESenseManager.connect(eSenseName);

    deviceStatus = con ? 'connecting' : 'connection failed';
  }

  static void listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      switch (event.runtimeType) {
        case DeviceNameRead:
          deviceName = (event as DeviceNameRead).deviceName;
          break;
        case BatteryRead:
          voltage = (event as BatteryRead).voltage;
          break;
        case ButtonEventChanged:
          button =
              (event as ButtonEventChanged).pressed ? 'pressed' : 'not pressed';
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

    getESenseProperties();
  }

  static void getESenseProperties() async {
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
  static void startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      print('SENSOR event: $event');
      zAxis = event.accel[2];
      zAxisCalculated = (zAxis / 4096) * 9.80665;
      eventString = event.toString();
    });
    sampling = true;
  }

  static void pauseListenToSensorEvents() {
    subscription.cancel();
    sampling = false;
  }

  static void dispose() {
    pauseListenToSensorEvents();
    ESenseManager.disconnect();
    //super.dispose();
  }
}
