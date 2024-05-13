import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tw_challenge_mobile/view/home.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            headerSection(),
            textSection(),
            buttonSection(),
          ],
        ),
      ),
    );
  }

  signUp(String name, email, pass, pass_confirmation) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'name' : name,
      'email': email,
      'password': pass,
      'password_confirmation': pass_confirmation,
    };
    var jsonResponse;
    var url = Uri.http('10.0.2.2:9090', 'api/auth/register');
    var response = await http.post(url, body: data);
    if(response.statusCode == 201) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['access_token']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => HomePage()), (Route<dynamic> route) => false);
      }
    }
    else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style,
        onPressed: emailController.text == "" || passwordController.text == "" ? null : () {
          setState(() {
            _isLoading = true;
          });
          signUp(nameController.text, emailController.text, passwordController.text, passwordConfirmationController.text);
        },
        child: Text("Registrarse", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
      ),
    );
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController = TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: nameController,
            cursorColor: Colors.black87,

            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              icon: Icon(Icons.people, color: Colors.blue),
              hintText: "Nombre",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: emailController,
            cursorColor: Colors.black87,

            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.blue),
              hintText: "Correo electrónico",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.black87,
            obscureText: true,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.blue),
              hintText: "Contraseña",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: passwordConfirmationController,
            cursorColor: Colors.black87,
            obscureText: true,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              icon: Icon(Icons.repeat, color: Colors.blue),
              hintText: "Confirmar Contraseña",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Center(
        child: Text("Registrarse",
            style: TextStyle(
                color: Colors.blue,
                fontSize: 40.0,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

}