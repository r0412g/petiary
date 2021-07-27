import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/main.dart';
import 'package:pet_diary/page/intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void initState() {
    super.initState();
  }

  /* checked if user seen the intro page */
  Future<Widget> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AllDataModel.checkFirstSeen = prefs.getBool('keyChecked') ?? false;
    return AllDataModel.checkFirstSeen == false
        ? IntroPage()
        : //IntroPage();
        MyHomePage(title: '寵物日記');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      splash: 'assets/paw.jpg',
      splashTransition: SplashTransition.scaleTransition,
      screenFunction: () {
        return checkFirstTime();
      },
    );
  }
}
