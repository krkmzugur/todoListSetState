import 'package:flutter/material.dart';
import 'package:todo/splash.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Todo Uygulaması',
    theme: ThemeData(
      primarySwatch: Colors.grey,
    ),
    home: SplashScreen(),
  ));
}
