import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Future<String> _futureWaitingData = Future<String>.delayed(
    const Duration(seconds: 1),
    () => 'Data Loaded',
  );

  var homePageImagePathByFile;
  var homePageName = '';
  var homePageIsNeutered;
  var homePageIsExactDate;
  var homePageType;
  var homePageBreeds;
  String homePageImagePathByAssets = 'assets/images/loading.png';
  String homePageGender = '公';
  String homePageBirthday =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  int homePageAge = 0;

  TextStyle othersTextStyle = const TextStyle(
    color: ColorSet.colorsWhite,
    fontSize: 18.0,
  );

  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  _loadData(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      homePageIsExactDate = prefs.getBool('keyIsExactDate') ?? false;
      homePageName = prefs.getString('keyPetName') ?? '';

      if (prefs.getString('keyPetType') == '') {
        homePageType = '未設定';
      } else {
        homePageType = prefs.getString('keyPetType') ?? '';
      }

      if (prefs.getString('keyPetBreeds') == '') {
        homePageBreeds = '未設定';
      } else {
        homePageBreeds = prefs.getString('keyPetBreeds') ?? '';
      }

      homePageIsNeutered = prefs.getBool('keyIsNeutered') ?? false;
      homePageGender = prefs.getString('keyPetGender') ?? '公';

      if (prefs.getString('keyPetImagePathByAssets') != '') {
        homePageImagePathByAssets =
            prefs.getString('keyPetImagePathByAssets') ?? '';
      }
      if (prefs.getString('keyPetImagePathByFile') != '') {
        homePageImagePathByFile = prefs.getString('keyPetImagePathByFile');
      }

      if (homePageIsExactDate == true) {
        homePageBirthday = prefs.getString('keyPetBirthday') ?? '未設定';
      }
      homePageAge = prefs.getInt('keyPetAge') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _futureWaitingData,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text(
                    '寵物資料',
                    style: const TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: ColorSet.colorsBlackOfOpacity80,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 540.0,
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
                        height: 540.0,
                        child: Card(
                          color: ColorSet.primaryColorsGreenOfOpacity80,
                          margin:
                              const EdgeInsets.only(top: 55.0, bottom: 17.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                30.0, 40.0, 30.0, 25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  child: homePageImagePathByFile != null
                                      ? Image.file(
                                          File(homePageImagePathByFile),
                                          fit: BoxFit.fill,
                                          width: 225.0,
                                          height: 225.0,
                                        )
                                      : Image.asset(
                                          homePageImagePathByAssets,
                                          fit: BoxFit.fill,
                                          width: 225.0,
                                          height: 225.0,
                                        ),
                                ),
                                Container(
                                  child: Text(
                                    '$homePageName',
                                    style: const TextStyle(
                                      color: ColorSet.colorsWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: homePageIsExactDate == true
                                      ? Text(
                                          '$homePageBirthday ($homePageAge歲)',
                                          style: const TextStyle(
                                            color: ColorSet.colorsWhite,
                                            fontSize: 17.0,
                                            letterSpacing: 1.5,
                                          ),
                                        )
                                      : Text(
                                          '$homePageAge 歲',
                                          style: const TextStyle(
                                            color: ColorSet.colorsWhite,
                                            fontSize: 17.0,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '$homePageType',
                                        style: othersTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '$homePageBreeds',
                                        style: othersTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '$homePageGender',
                                        style: othersTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${homePageIsNeutered == false ? '未結紮' : '已結紮'}',
                                        style: othersTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 540.0,
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
          );
        } else {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text(
                    '寵物資料',
                    style: const TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: ColorSet.colorsBlackOfOpacity80,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 540.0,
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
                        height: 540.0,
                        child: Card(
                          color: ColorSet.primaryColorsGreenOfOpacity80,
                          margin:
                              const EdgeInsets.only(top: 55.0, bottom: 17.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                30.0, 40.0, 30.0, 35.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  '載入資料中',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: ColorSet.colorsWhite,
                                  ),
                                ),
                                const SizedBox(
                                  height: 25.0,
                                ),
                                const Center(
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                    color: ColorSet.colorsWhiteGrayOfOpacity80,
                                    backgroundColor:
                                        ColorSet.colorsDarkBlueGreenOfOpacity80,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 540.0,
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
          );
        }
      },
    );
  }
}
