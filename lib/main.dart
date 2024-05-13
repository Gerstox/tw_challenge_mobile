import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tw_challenge_mobile/view/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: "TW Group",
          debugShowCheckedModeBanner: false,
          home: MainPage(),
          // home: MapPage(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ));
  }
}

class MyAppState extends ChangeNotifier {}
