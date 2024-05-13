import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_challenge_mobile/models/location.model.dart';
import 'package:tw_challenge_mobile/models/user.model.dart';
import 'package:tw_challenge_mobile/view/login.dart';
import 'package:tw_challenge_mobile/view/map.dart';
import 'package:tw_challenge_mobile/view/welcome.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences sharedPreferences;

  UserTW userTW = UserTW();
  LocationTW locationTW = LocationTW();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
    getCurrentuser();
  }

  getCurrentuser() async {
    var jsonResponse;
    String token = sharedPreferences.getString("token").toString();
    var url = Uri.http('10.0.2.2:9090', 'api/auth/me');
    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        var id = jsonResponse['id'];
        var name = jsonResponse['name'];
        var email = jsonResponse['email'];
        userTW.id = id;
        userTW.name = name;
        userTW.email = email;
        getLocation(id.toString());
      }
    } else {
      print("ERROR: Ha ocurrido un error al intentar recuperar el usuario.");
    }
  }

  getLocation(String userId) async {
    var jsonResponse;
    String token = sharedPreferences.getString("token").toString();
    var url = Uri.http('10.0.2.2:9090', 'api/users/location/$userId');
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        if (jsonResponse['error'] != null) {
          locationTW.latitude = 0.0;
          locationTW.longitude = 0.0;
        } else {
          locationTW.id = jsonResponse['id'];
          locationTW.userId = jsonResponse['user_id'];
          locationTW.latitude = jsonResponse['latitude'];
          locationTW.longitude = jsonResponse['longitude'];

          latitudeController.text = jsonResponse['latitude'].toString();
          longitudeController.text = jsonResponse['longitude'].toString();

          sharedPreferences.setInt('loc_id', jsonResponse['id']);
          sharedPreferences.setInt('loc_user_id', jsonResponse['user_id']);
          sharedPreferences.setDouble('loc_latitude', jsonResponse['latitude']);
          sharedPreferences.setDouble('loc_longitude', jsonResponse['longitude']);
        }
      }
    } else {
      print("ERROR: Ha ocurrido un error al intentar recuperar la ubicación del usuario.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("TW Group",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
          actions: <Widget>[
            Text(userTW.name.toString()),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                sharedPreferences.clear();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => MainPage()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text("Dashboard",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 25)),
              Text("Ubicación",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              inputSection(),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  margin: EdgeInsets.only(top: 15.0),
                  child: Text("Mapa",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18))),
              // getMap(),
              ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MapPage()));
                },
                child: Text("Ver Mapa",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ));
  }

  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  Container inputSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: latitudeController,
            cursorColor: Colors.black87,
            readOnly: true,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Latitud',
              hintText: "Latitud",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade500)),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          TextFormField(
            controller: longitudeController,
            cursorColor: Colors.black87,
            readOnly: true,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Longitud',
              hintText: "Longitud",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade500)),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
      // TextFormField(
      //   controller: longitudeController,
      //   cursorColor: Colors.black87,

      //   style: TextStyle(color: Colors.black87),
      //   decoration: InputDecoration(
      //     icon: Icon(Icons.email, color: Colors.blue),
      //     hintText: "Correo electrónico",
      //     border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
      //     hintStyle: TextStyle(color: Colors.grey.shade500),
      //   ),
      // ),
    );
  }

  FlutterMap getMap() {
    return FlutterMap(options: MapOptions(minZoom: 10.0), children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c'],
      )
    ]);
  }
}
