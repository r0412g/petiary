import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_diary/common/background_painter.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingCalendarPage extends StatefulWidget {
  SettingCalendarPage({Key? key}) : super(key: key);

  @override
  _SettingCalendarPageState createState() => _SettingCalendarPageState();
}

class _SettingCalendarPageState extends State<SettingCalendarPage> {
  String? firstDayOfWeek;
  int settingPageFirstDayOfWeek = 7;
  bool? isShowWeekNumber;
  bool settingPageShowWeekNumber = false;
  bool? is24hourSystem;
  bool settingPageIs24hourSystem = true;

  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  _loadData(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      settingPageFirstDayOfWeek = prefs.getInt('keyFirstDayOfWeek') ?? 7;
      settingPageShowWeekNumber = prefs.getBool('keyShowWeekNumber') ?? false;
      settingPageIs24hourSystem = prefs.getBool('keyIs24hourSystem') ?? true;
    });

    if (settingPageFirstDayOfWeek == 7) {
      firstDayOfWeek = '週日';
    } else {
      firstDayOfWeek = '週一';
    }

    isShowWeekNumber = settingPageShowWeekNumber;
    is24hourSystem = settingPageIs24hourSystem;
  }

  void _confirmChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the first day of week by user selected
    switch (firstDayOfWeek) {
      case '週日':
        prefs.setInt('keyFirstDayOfWeek', 7);
        break;
      case '週一':
        prefs.setInt('keyFirstDayOfWeek', 1);
        break;
    }

    // Save whether show week number on calendar
    if (isShowWeekNumber == true) {
      await prefs.setBool('keyShowWeekNumber', true);
    } else {
      await prefs.setBool('keyShowWeekNumber', false);
    }

    // Using 24 hour system or not
    if (is24hourSystem == true) {
      await prefs.setBool('keyIs24hourSystem', true);
    } else {
      await prefs.setBool('keyIs24hourSystem', false);
    }

    Navigator.of(context).pop();

    Fluttertoast.showToast(
        msg: "修改完成!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: ColorSet.colorsWhite,
        textColor: ColorSet.colorsBlackOfOpacity80,
        fontSize: 16.0);
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
                                      '行事曆格式設定',
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
                                      decoration: ShapeDecoration(
                                          color: ColorSet
                                              .colorsWhiteGrayOfOpacity80,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  ForAllTheme.allRadius)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          const Text(
                                            '每週起始日',
                                            style: const TextStyle(
                                              color: ColorSet
                                                  .colorsBlackOfOpacity80,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                          DropdownButtonHideUnderline(
                                            child: ButtonTheme(
                                              alignedDropdown: true,
                                              child: DropdownButton<String>(
                                                icon: const Icon(Icons
                                                    .arrow_drop_down_outlined),
                                                iconEnabledColor: ColorSet
                                                    .colorsDarkBlueGreenOfOpacity80,
                                                value: firstDayOfWeek,
                                                onChanged: (value) {
                                                  setState(() {
                                                    firstDayOfWeek = value;
                                                  });
                                                },
                                                items: <String>[
                                                  '週日',
                                                  '週一'
                                                ].map<DropdownMenuItem<String>>(
                                                    (String week) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: week,
                                                    child: Text(
                                                      week,
                                                      style: const TextStyle(
                                                        color: ColorSet
                                                            .colorsBlackOfOpacity80,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    Container(
                                      width: 300.0,
                                      height: 45.0,
                                      alignment: Alignment.center,
                                      decoration: ShapeDecoration(
                                          color: ColorSet
                                              .colorsWhiteGrayOfOpacity80,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  ForAllTheme.allRadius)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          const Text(
                                            '是否顯示週數',
                                            style: const TextStyle(
                                              color: ColorSet
                                                  .colorsBlackOfOpacity80,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                          Switch(
                                              value: isShowWeekNumber ?? false,
                                              inactiveThumbColor: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                              inactiveTrackColor:
                                                  ColorSet.colorsWhite,
                                              activeColor: ColorSet
                                                  .colorsDarkBlueGreenOfOpacity80,
                                              activeTrackColor:
                                                  ColorSet.colorsWhite,
                                              onChanged: (value) {
                                                setState(() {
                                                  isShowWeekNumber = value;
                                                });
                                              }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    Container(
                                      width: 300.0,
                                      height: 45.0,
                                      alignment: Alignment.center,
                                      decoration: ShapeDecoration(
                                          color: ColorSet
                                              .colorsWhiteGrayOfOpacity80,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  ForAllTheme.allRadius)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          const Text(
                                            '24小時制',
                                            style: const TextStyle(
                                              color: ColorSet
                                                  .colorsBlackOfOpacity80,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 2.0,
                                          ),
                                          Switch(
                                              value: is24hourSystem ?? true,
                                              inactiveThumbColor: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                              inactiveTrackColor:
                                                  ColorSet.colorsWhite,
                                              activeColor: ColorSet
                                                  .colorsDarkBlueGreenOfOpacity80,
                                              activeTrackColor:
                                                  ColorSet.colorsWhite,
                                              onChanged: (value) {
                                                setState(() {
                                                  is24hourSystem = value;
                                                });
                                              }),
                                        ],
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
                                        _confirmChanges();
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
