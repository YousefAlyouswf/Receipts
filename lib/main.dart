import 'package:flutter/material.dart';
import 'package:receipt/loaded.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        primaryColor: Colors.green[800],
        floatingActionButtonTheme: FloatingActionButtonThemeData (backgroundColor: Colors.green),
       
      
      ),
      home: Loaded(),
    );
  }
}


