import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/setting_page/setting_my_pet_page.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isSoundSwitched = true;
  bool _isVibrationSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              color: ColorSet.secondaryColors,
              child: Tooltip(
                message: '編輯我的寵物',
                child: ListTile(
                  leading: Icon(Icons.pets),
                  title: Text('我的寵物'),
                  trailing: Icon(Icons.keyboard_arrow_right),
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
                    Text(
                      '通知設定',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SwitchListTile(
                        title: Text('聲音'),
                        contentPadding: const EdgeInsets.all(0.0),
                        value: _isSoundSwitched,
                        onChanged: (value) {
                          setState(() {
                            _isSoundSwitched = value;
                          });
                        }),
                    SwitchListTile(
                        title: Text('振動'),
                        contentPadding: const EdgeInsets.all(0.0),
                        value: _isVibrationSwitched,
                        onChanged: (value) {
                          setState(() {
                            _isVibrationSwitched = value;
                          });
                        }),
                  ],
                ),
              ),
              margin: MyCardTheme.cardMargin,
              shape: RoundedRectangleBorder(
                side:
                    BorderSide(color: ColorSet.primaryLightColors, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
