import 'package:flutter/material.dart';
import 'package:pet_diary/main.dart';
import 'intro_page.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  /* checked if user seen the intro page */
  checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _check = (prefs.getBool('checked') ?? false); // init check as false

    if (_check) {
      Navigator.of(context).pushReplacement(
    new MaterialPageRoute(
    builder: (context) => new MyHomePage(title: '寵物日記')));
    /*new MaterialPageRoute(builder: (context) => new IntroPage()));*/
    } else {
      await prefs.setBool('checked', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      splash: 'assets/paw.jpg',
      screenFunction: () async {
        return checkFirstTime();
      },
      splashTransition: SplashTransition.scaleTransition,
    );
  }
}
