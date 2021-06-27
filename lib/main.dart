import 'package:flutter/material.dart';
import 'package:pet_diary/splash_page.dart';
import 'package:pet_diary/bottom_navigation_bar_page/home_page.dart';
import 'package:pet_diary/bottom_navigation_bar_page/hospital_page.dart';
import 'package:pet_diary/bottom_navigation_bar_page/calendar_page.dart';
import 'setting_page/setting_page.dart';
import 'package:pet_diary/common/theme.dart';

void main() => runApp(MainClass());

/* Root Of Application */
class MainClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Diary', // 開啟所有app管理時會看到
      theme: appTheme,
      debugShowCheckedModeBanner: false, // 去除Debug標誌
      home: SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final pages = [HomePage(), HospitalPage(), CalendarPage(), SettingPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              tooltip: '設定',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingPage()));
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        type: BottomNavigationBarType.shifting,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: ColorSet.primaryColors,
            icon: Icon(Icons.home_outlined),
            label: '主頁',
          ),
          BottomNavigationBarItem(
            backgroundColor: ColorSet.primaryColors,
            icon: Icon(Icons.local_hospital_outlined),
            label: '就醫紀錄',
          ),
          BottomNavigationBarItem(
            backgroundColor: ColorSet.primaryColors,
            icon: Icon(Icons.calendar_today_outlined),
            label: '行事曆',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: ColorSet.secondaryColors,
        backgroundColor: ColorSet.primaryColors,
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }
}
