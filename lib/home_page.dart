import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/location_util.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracking'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                bg.BackgroundGeolocation.start();
            
              },
              child: Text('Start tracking'),
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  bg.BackgroundGeolocation.stop();
                } on Exception catch (e) {
                  // TODO
                }

              },
              child: Text('Stop tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
