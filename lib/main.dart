import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:untitled/firebase_options.dart';
import 'package:untitled/firebase_utils.dart';
import 'package:untitled/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  bg.BackgroundGeolocation.registerHeadlessTask(
      backgroundGeolocationHeadlessTask);

  /// Register BackgroundFetch headless-task.
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
       FirebaseUtil().writeLocationToDocument(location);

    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: false,
        debug: true,
        backgroundPermissionRationale: bg.PermissionRationale(
            title:
                "Allow {applicationName} to access this device's location even when the app is closed or not in use.",
            message:
                "This app collects location data to enable recording your trips to work and calculate distance-travelled.",
            positiveAction: 'Change to "{backgroundPermissionOptionLabel}"',
            negativeAction: 'Cancel'),
        foregroundService: true,
        notificationPriority: bg.Config.NOTIFICATION_PRIORITY_LOW,
        notification: bg.Notification(
          title: "The Title",
          text: "The Text",
          priority: bg.Config.NOTIFICATION_PRIORITY_LOW,
        ),
        notificationChannelName: 'Location_service',
        enableHeadless: true,
        logLevel: bg.Config.LOG_LEVEL_ERROR));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

/// Receive events from BackgroundGeolocation in Headless state.
@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  print('📬 --> $headlessEvent');

  switch (headlessEvent.name) {
    case bg.Event.BOOT:
      bg.State state = await bg.BackgroundGeolocation.state;
      print("📬 didDeviceReboot: ${state.didDeviceReboot}");
      break;
    case bg.Event.TERMINATE:
      bg.State state = await bg.BackgroundGeolocation.state;
      if (state.stopOnTerminate!) {
        // Don't request getCurrentPosition when stopOnTerminate: true
        return;
      }
      try {
        bg.Location location =
            await bg.BackgroundGeolocation.getCurrentPosition(
                samples: 1,
                persist: true,
                extras: {"event": "terminate", "headless": true});
        print("[getCurrentPosition] Headless: $location");
      } catch (error) {
        print("[getCurrentPosition] Headless ERROR: $error");
      }

      break;
    case bg.Event.HEARTBEAT:
      try {
        bg.Location location =
            await bg.BackgroundGeolocation.getCurrentPosition(
                samples: 2,
                timeout: 10,
                extras: {"event": "heartbeat", "headless": true});

        print('[getCurrentPosition] Headless: $location');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await FirebaseUtil().writeLocationToDocument(location);
      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print(location);
      break;
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      print(geofenceEvent);
      break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print(state);
      break;
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print(response);
      break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.AUTHORIZATION:
      bg.AuthorizationEvent event = headlessEvent.event;
      print(event);
      break;
  }
}

/// Receive events from BackgroundFetch in Headless state.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;

  // Is this a background_fetch timeout event?  If so, simply #finish and bail-out.
  if (task.timeout) {
    print("[BackgroundFetch] HeadlessTask TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print("[BackgroundFetch] HeadlessTask: $taskId");

  try {
    var location = await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 2, extras: {"event": "background-fetch", "headless": true});
    print("[location] $location");
  } catch (error) {
    print("[location] ERROR: $error");
  }

  BackgroundFetch.finish(taskId);
}
