import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

class LocationUtil {
  static final LocationUtil _instance = LocationUtil._();

  LocationUtil._();

  StreamSubscription<Position>? streamSubscription;

  factory LocationUtil() => _instance;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  startLocationService() {
late LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        timeLimit: const Duration(minutes: 5),
        distanceFilter: 20,
        forceLocationManager: true,
        accuracy: LocationAccuracy.bestForNavigation,
        intervalDuration: Duration(seconds: 30),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: "Running in Background",
            enableWakeLock: true,
            enableWifiLock: true,
            setOngoing: true,
            notificationChannelName: 'location_servive',
            notificationText:
                'app will continue to receive your location even when you aren\'t using it'),
      );
    }
    var stream =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    streamSubscription = stream.listen((event) {
      log('current location ${event.toJson()}');
    });
  }

  dispose() {
    streamSubscription?.cancel();
  }
}
