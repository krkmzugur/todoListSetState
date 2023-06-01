import 'dart:async';
import 'package:flutter/material.dart';
import 'TodoListPage.dart';
import 'login.dart';
import 'model/SessionManager.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      navigateToNextScreen();
    });
  }

  void navigateToNextScreen() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? TodoListPage() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
