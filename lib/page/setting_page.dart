import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/page/setting_calendar_page.dart';
import 'package:pet_diary/page/setting_my_pet_page.dart';

class SettingPage extends StatefulWidget {
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Text(
            '設定',
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
                    padding: const EdgeInsets.fromLTRB(20.0, 45.0, 20.0, 35.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          width: 300.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: ForAllTheme.allRadius,
                            color: ColorSet.colorsWhiteGrayOfOpacity80,
                          ),
                          child: SizedBox.expand(
                            child: Tooltip(
                              message: '進入編輯寵物基本資料頁面',
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SettingMyPetPage()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '編輯基本資料',
                                    style: TextStyle(
                                        color: ColorSet.colorsBlackOfOpacity80,
                                        fontSize: 16.0,
                                        letterSpacing: 1.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          width: 300.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: ForAllTheme.allRadius,
                            color: ColorSet.colorsWhiteGrayOfOpacity80,
                          ),
                          child: SizedBox.expand(
                            child: Tooltip(
                              message: '進入行事曆格式設定頁面',
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SettingCalendarPage()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '行事曆格式設定',
                                    style: TextStyle(
                                        color: ColorSet.colorsBlackOfOpacity80,
                                        fontSize: 16.0,
                                        letterSpacing: 1.0),
                                  ),
                                ),
                              ),
                            ),
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
