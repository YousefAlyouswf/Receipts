import 'package:flutter/material.dart';
import 'package:receipt/loaded.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        primaryColor: Colors.green[800],
        colorScheme: ColorScheme.light(primary: const Color(0xFF006700)),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Colors.green),
      ),
      home: Loaded(),
    );
  }
}
