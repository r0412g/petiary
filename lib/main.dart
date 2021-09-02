import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/page/calendar_page.dart';
import 'package:pet_diary/page/home_page.dart';
import 'package:pet_diary/page/hospital_page.dart';
import 'package:pet_diary/page/setting_page.dart';
import 'package:pet_diary/page/splash_page.dart';
import 'common/background_painter.dart';

void main() => runApp(MainClass());

/* Root Of Application */
class MainClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
        const Locale('en'),
        const Locale('ja'),
        const Locale('zh'),
      ],
      locale: const Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
      title: '寵物日記 Petiary', // 開啟所有app管理時會看到
      theme: appTheme,
      debugShowCheckedModeBanner: false, // 去除Debug標誌
      home: SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  final pages = [CalendarPage(), HomePage(), HospitalPage(), SettingPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          Center(
            child: pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ColorSet.colorsWhite,
        elevation: 0.0,
        type: BottomNavigationBarType.fixed,
        fixedColor: ColorSet.colorsBlackOfOpacity80,
        currentIndex: _selectedIndex,
        /* Label setting */
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          color: ColorSet.colorsBlackOfOpacity80,
          fontSize: 12.0,
        ),
        unselectedLabelStyle: const TextStyle(
          color: ColorSet.colorsBlackOfOpacity80,
        ),

        /* Icon setting */
        selectedIconTheme: const IconThemeData(
          color: ColorSet.colorsDarkBlueGreenOfOpacity80,
        ),
        unselectedIconTheme: const IconThemeData(
          color: ColorSet.colorsWhiteGrayOfOpacity80,
        ),

        /* Item setting */
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            tooltip: '選擇行事曆頁面',
            icon: const Icon(
              Icons.calendar_today_outlined,
            ),
            activeIcon: const Icon(
              Icons.calendar_today,
            ),
            label: '行事曆',
          ),
          const BottomNavigationBarItem(
            tooltip: '選擇主頁',
            icon: const Icon(
              Icons.home_outlined,
            ),
            activeIcon: const Icon(
              Icons.home,
            ),
            label: '主頁',
          ),
          const BottomNavigationBarItem(
            tooltip: '選擇就醫紀錄頁面',
            icon: const Icon(
              Icons.local_hospital_outlined,
            ),
            activeIcon: const Icon(
              Icons.local_hospital,
            ),
            label: '就醫紀錄',
          ),
          const BottomNavigationBarItem(
            tooltip: '選擇設定頁面',
            icon: const Icon(
              Icons.settings_outlined,
            ),
            activeIcon: const Icon(
              Icons.settings,
            ),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
