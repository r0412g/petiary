import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:pet_diary/common/background_painter.dart';
import 'package:pet_diary/common/theme.dart';


class SettingSignInPage extends StatefulWidget {
  SettingSignInPage({Key? key}) : super(key: key);

  @override
  _SettingSignInPageState createState() => _SettingSignInPageState();
}

class _SettingSignInPageState extends State<SettingSignInPage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Center(
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 50.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    '設定',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: ColorSet.colorsBlackOfOpacity80,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 600.0,
                          child: Card(
                            color: ColorSet.primaryColorsGreenOfOpacity80,
                            margin: const EdgeInsets.only(
                                right: 22.0, top: 55.0, bottom: 17.0),
                            shape: MyCardTheme.cardsForLeftShapeBorder,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300.0,
                        height: 600.0,
                        child: Stack(
                          children: <Widget>[
                            Card(
                              color: ColorSet.primaryColorsGreenOfOpacity80,
                              margin: const EdgeInsets.only(
                                  top: 55.0, bottom: 17.0),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    25.0, 25.0, 25.0, 65.0),
                                child: Column(
                                  children: <Widget>[
                                    const Text(
                                      '連結帳戶',
                                      style: const TextStyle(
                                        letterSpacing: 1.0,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                        color: ColorSet.colorsBlackOfOpacity80,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 35.0,
                                    ),
                                    Container(
                                      width: 300.0,
                                      height: 45.0,
                                      alignment: Alignment.center,
                                      child: SignInButton(
                                        Buttons.Google,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                ForAllTheme.allRadius),
                                        onPressed: () {
                                          // signInWithGoogle();
                                          print('STOP USING THIS');
                                          //authChanges();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20.0,
                              bottom: 27.0,
                              child: Row(
                                children: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      '取消',
                                      style: const TextStyle(
                                          color: ColorSet.colorsWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0,
                                          letterSpacing: 2.0),
                                    ),
                                  ),
                                  Container(
                                    height: 34.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: ForAllTheme.allRadius,
                                      color: ColorSet
                                          .colorsDarkBlueGreenOfOpacity80,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        //_confirmChanges();
                                      },
                                      child: const Text(
                                        '完成',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: ColorSet.colorsWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                            letterSpacing: 2.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 600.0,
                          child: Card(
                            color: ColorSet.primaryColorsGreenOfOpacity80,
                            margin: const EdgeInsets.only(
                                left: 22.0, top: 55.0, bottom: 17.0),
                            shape: MyCardTheme.cardsForRightShapeBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
