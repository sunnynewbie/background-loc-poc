import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;
class FirebaseUtil {
  writeLocationToDocument(bg.Location location) async {

    var item ={
      'lat':location.coords.latitude,
      'lng':location.coords.longitude,
      'time':location.timestamp,

    };
    await FirebaseFirestore.instance.collection("locations").doc(location.uuid).set(item);
  }
}
