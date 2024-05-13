import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_challenge_mobile/models/location.model.dart';
import 'package:tw_challenge_mobile/plugins/zoombuttoins_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:tw_challenge_mobile/view/home.dart';

class MapPage extends StatefulWidget {

  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late SharedPreferences sharedPreferences;
  // Alignment selectedAlignment = Alignment.topCenter;
  bool counterRotate = false;
  final LocationTW location = LocationTW();

  late final customMarkers = <Marker>[
    buildPin(LatLng(51.51868093513547, -0.12835376940892318)),
  ];

  var mapCenter = LatLng(51.51868093513547, -0.12835376940892318);

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Column(
        children: [
          Flexible(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 5,
                onTap: (_, p) => {
                  setState(() => customMarkers.clear()),
                  setState(() => customMarkers.add(buildPin(p))),
                  location.latitude = p.latitude,
                  location.longitude = p.longitude,
                },
                interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                const FlutterMapZoomButtons(
                  minZoom: 4,
                  maxZoom: 19,
                  mini: true,
                  padding: 10,
                  alignment: Alignment.bottomLeft,
                ),
                MarkerLayer(
                  markers: customMarkers,
                  rotate: counterRotate,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          setState(() {
            saveLocation(location);
          })
        },
        tooltip: 'Agregar ubicación',
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }


  getLocation() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    LatLng newLatLng = LatLng(sharedPreferences.getDouble("loc_latitude")!,
        sharedPreferences.getDouble("loc_longitude")!);
    
    location.id = sharedPreferences.getInt("loc_id");
    location.userId = sharedPreferences.getInt("loc_user_id");
    location.latitude = sharedPreferences.getDouble("loc_latitude");
    location.longitude = sharedPreferences.getDouble("loc_longitude");

    setState(() => customMarkers.clear());
    setState(() => customMarkers.add(buildPin(newLatLng)));
    setState(() => mapCenter = newLatLng);
  }

  Marker buildPin(LatLng point) => Marker(
    point: point,
    width: 60,
    height: 60,
    child: GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta es tu ubicación actual',
            style: TextStyle(fontSize: 18),
          ),
          duration: Duration(seconds: 3),
          showCloseIcon: true,
          backgroundColor: Colors.blue,
        ),
      ),
      child: const Icon(Icons.location_pin, size: 60, color: Colors.blue),
    ),
  );

  saveLocation(LocationTW location) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'latitude': location.latitude!.toStringAsFixed(4),
      'longitude': location.longitude!.toStringAsFixed(4)
    };
    
    var jsonResponse;
    String token = sharedPreferences.getString("token").toString();
    var url = Uri.http('10.0.2.2:9090', 'api/users/location/${location.id}');
    var response = await http.put(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: jsonEncode(data));
    if(response.statusCode == 200 || response.statusCode == 201) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => HomePage()), (Route<dynamic> route) => false);
      }
    }
    else {
      print(response.body);
    }
  }
}
