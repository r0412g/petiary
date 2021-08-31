import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/models/pet_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var homeImagePathByFile;
  String homeImagePathByAssets = 'assets/images/loading.png';

  TextStyle nameTextStyle = const TextStyle(
    color: ColorSet.colorsWhite,
    fontWeight: FontWeight.bold,
    fontSize: 28.0,
  );

  TextStyle ageTextStyle = const TextStyle(
    color: ColorSet.colorsWhite,
    fontSize: 17.0,
    letterSpacing: 1.5,
  );

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
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myPet.setIsExactDate(prefs.getBool('keyIsExactDate') ?? false);
      myPet.setName(prefs.getString('keyPetName') ?? '');
      myPet.setType(prefs.getString('keyPetType') ?? '');
      myPet.setBreeds(prefs.getString('keyPetBreeds') ?? '');
      myPet.setGender(prefs.getString('keyPetGender') ?? '公');
      myPet.setIsNeutered(prefs.getBool('keyIsNeutered') ?? false);

      if (prefs.getString('keyPetImagePathByAssets') != '') {
        homeImagePathByAssets =
            prefs.getString('keyPetImagePathByAssets') ?? '';
      }
      if (prefs.getString('keyPetImagePathByFile') != '') {
        homeImagePathByFile = prefs.getString('keyPetImagePathByFile');
      }

      if (myPet.getIsExactDate == true) {
        myPet.setBirthday(prefs.getString('keyPetBirthday') ?? '未設定');
        myPet.setAge(prefs.getString('keyPetAge') ?? '0');
      } else {
        myPet.setAge(prefs.getString('keyPetAge') ?? '0');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myPet = Provider.of<MyPetModel>(context);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Text(
            '寵物資料',
            style: TextStyle(
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
                    margin:
                        EdgeInsets.only(right: 22.0, top: 20.0, bottom: 17.0),
                    shape: MyCardTheme.cardsForLeftShapeBorder,
                  ),
                ),
              ),
              SizedBox(
                width: 300.0,
                height: 540.0,
                child: Card(
                  color: ColorSet.primaryColorsGreenOfOpacity80,
                  margin: EdgeInsets.only(top: 20.0, bottom: 17.0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 35.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          child: homeImagePathByFile != null
                              ? Image.file(
                                  File(homeImagePathByFile),
                                  fit: BoxFit.fill,
                                  width: 225.0,
                                  height: 225.0,
                                )
                              : Image.asset(
                                  homeImagePathByAssets,
                                  fit: BoxFit.fill,
                                  width: 225.0,
                                  height: 225.0,
                                ),
                        ),
                        Container(
                          child: myPet.getName == ''
                              ? Text(
                                  '未設定',
                                  style: nameTextStyle,
                                )
                              : Text(
                                  '${myPet.getName}',
                                  style: nameTextStyle,
                                ),
                        ),
                        Container(
                          child: myPet.getIsExactDate == true
                              ? Text('${myPet.getBirthday} (${myPet.getAge}歲)',
                                  style: ageTextStyle)
                              : Text('${myPet.getAge} 歲', style: ageTextStyle),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: myPet.getType == ''
                                  ? Text(
                                      '未設定',
                                      style: othersTextStyle,
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      '${myPet.getType}',
                                      style: othersTextStyle,
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                            Expanded(
                              flex: 2,
                              child: myPet.getBreeds == ''
                                  ? Text(
                                      '未設定',
                                      style: othersTextStyle,
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      '${myPet.getBreeds}',
                                      style: othersTextStyle,
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${myPet.getGender}',
                                style: othersTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${myPet.getIsNeutered == false ? '未結紮' : '已結紮'}',
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
                    margin:
                        EdgeInsets.only(left: 22.0, top: 20.0, bottom: 17.0),
                    shape: MyCardTheme.cardsForRightShapeBorder,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
