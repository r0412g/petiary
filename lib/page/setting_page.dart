import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/models/setting_model.dart';
import 'package:pet_diary/page/setting_my_pet_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  _loadData(context) async {
    SettingModel mySet = Provider.of<SettingModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mySet.setFirstDayOfWeek(prefs.getInt('keyFirstDayOfWeek') ?? 7);
      mySet.setShowWeekNumber(prefs.getBool('keyShowWeekNumber') ?? false);
      mySet.setIs24hourSystem(prefs.getBool('keyIs24hourSystem') ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var mySet = Provider.of<SettingModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              color: ColorSet.secondaryColors,
              child: Tooltip(
                message: '編輯我的寵物',
                child: ListTile(
                  leading: const Icon(Icons.pets),
                  title: const Text('編輯我的寵物'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingMyPetPage()));
                  },
                  shape: MyCardTheme.cardShapeBorder,
                ),
              ),
              margin: MyCardTheme.cardMargin,
              shape: MyCardTheme.cardShapeBorder,
            ),
            Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    const Text(
                      '日曆設定',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    const Divider(
                      height: 30.0,
                      thickness: 3.0,
                      indent: 15.0,
                      endIndent: 15.0,
                      color: ColorSet.thirdColors,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          '一周的第一天為：',
                          style: TextStyle(fontSize: 17),
                        ),
                        DropdownButton<String>(
                          value: AllDataModel.firstDayOfWeek,
                          onChanged: (value) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              AllDataModel.firstDayOfWeek = value;
                              switch (value) {
                                case '星期日':
                                  prefs.setInt('keyFirstDayOfWeek', 7);
                                  mySet.setFirstDayOfWeek(7);
                                  break;
                                case '星期一':
                                  prefs.setInt('keyFirstDayOfWeek', 1);
                                  mySet.setFirstDayOfWeek(1);
                                  break;
                              }
                            });
                          },
                          items: <String>['星期日', '星期一']
                              .map<DropdownMenuItem<String>>((String week) {
                            return DropdownMenuItem<String>(
                              value: week,
                              child: Text(week),
                            );
                          }).toList(),
                          hint: Text(
                            mySet.getFirstDayOfWeek == 1 ? '星期一' : '星期日',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    SwitchListTile(
                        title: const Text('顯示週數?'),
                        subtitle: mySet.getShowWeekNumber == true
                            ? const Text('是')
                            : const Text('否'),
                        contentPadding: const EdgeInsets.all(0.0),
                        value: mySet.getShowWeekNumber,
                        activeColor: ColorSet.primaryLightColors,
                        onChanged: (value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('keyShowWeekNumber', value);
                          setState(() {
                            mySet.setShowWeekNumber(value);
                          });
                        }),
                    SwitchListTile(
                        title: const Text('24小時制?'),
                        subtitle: mySet.getIs24hourSystem == true
                            ? const Text('是')
                            : const Text('否'),
                        contentPadding: const EdgeInsets.all(0.0),
                        value: mySet.getIs24hourSystem,
                        activeColor: ColorSet.primaryLightColors,
                        onChanged: (value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('keyIs24hourSystem', value);
                          setState(() {
                            mySet.setIs24hourSystem(value);
                          });
                        }),
                  ],
                ),
              ),
              margin: MyCardTheme.cardMargin,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                    color: ColorSet.primaryLightColors, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
