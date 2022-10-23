import 'package:flutter/material.dart';

final themeData = ThemeData(
  colorScheme: ColorScheme(
      primary: Colors.blue.shade800,
      secondary: Colors.blue.shade500,
      surface: Colors.blue.shade300,
      background: Colors.blue.shade300,
      error: Colors.red,
      onPrimary: Colors.blue.shade100,
      onSecondary: Colors.blue.shade100,
      onSurface: Colors.blue.shade800,
      onBackground: Colors.blue.shade800,
      onError: Colors.lightBlue,
      brightness: Brightness.light),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: Colors.white,
      backgroundColor: Colors.blue.shade900,
      side: const BorderSide(
        color: Colors.white,
      ),
    ),
  ),
  scaffoldBackgroundColor: Colors.blue.shade300,
  // ),scaffoldBackgroundColor: this.,
  cardColor: Colors.grey[400],
  textTheme: TextTheme(
    bodyText1: TextStyle(color: Colors.blue[900]),
    bodyText2: TextStyle(
      color: Colors.blue[900],
      fontSize: 20,
      overflow: TextOverflow.ellipsis,
    ),
  ),
);
