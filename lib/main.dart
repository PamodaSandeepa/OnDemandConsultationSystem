import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebaseapp/Provider.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.redAccent,
          accentColor: Colors.green,
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
          ),
        ),
        title: 'splash screen',
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/home': (context) => Provider(),
        });
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /* void initState() {
    super.initState();
    Timer(Duration(seconds: 2),
        () => Navigator.pushReplacementNamed(context, '/home'));
  }  */

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.blue[300],
      splash: 'assets/EC.png',
      splashIconSize: 140.0,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.scale,
      nextScreen: Provider(),
    );
  }
}
