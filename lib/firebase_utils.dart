import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class FirebaseUtil {
  writeLocationToDocument(bg.Location location) async {
    var item = {
      'lat': location.coords.latitude,
      'lng': location.coords.longitude,
      'time': location.timestamp,
    };
    String id = '';

    if (Platform.isAndroid) {
      var info = await DeviceInfoPlugin().androidInfo;
      id = info.id;
    } else {
      var info = await DeviceInfoPlugin().iosInfo;
      id = info.identifierForVendor ?? '';
    }
    var doc = FirebaseFirestore.instance
        .collection("locations")
        .doc(id)
        .collection("position");
    var itemCount = await doc.count().get();
    await doc.doc("${itemCount.count ?? 0}").set(item);
  }
}
