import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:melembra/app/pages/home_page.dart';

import 'models/reminder.dart';

class AppWidget extends StatelessWidget {

  Reminder reminder = new Reminder(0, '', '');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Me Lembra',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent[700],
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: HomePage(reminder),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
    );
  }
}
