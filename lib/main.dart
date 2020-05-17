import 'package:flutter/material.dart';
import 'package:receipt/loaded.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('ar'), // Arabic
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white, fontSize: 22),
          headline2: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          headline3: TextStyle(color: Colors.white, fontSize: 15),
        ),
        colorScheme: ColorScheme.light(primary: const Color(0xFF000000)),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      home: Loaded(),
    );
  }
}
