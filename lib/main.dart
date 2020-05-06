import 'package:flutter/material.dart';
import 'package:receipt/loaded.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Colors.brown,
       // cardColor: Color(0xFF008080),
       // textSelectionColor: Colors.white
      ),
      home: Loaded(),
    );
  }
}


