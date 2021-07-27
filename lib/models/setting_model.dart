import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/* Using for Provider */
class SettingModel with ChangeNotifier {
  int _firstDayOfWeek = 7;
  bool _showWeekNumber = false;
  bool _is24hourSystem = true;

  int get getFirstDayOfWeek => _firstDayOfWeek;
  bool get getShowWeekNumber => _showWeekNumber;
  bool get getIs24hourSystem => _is24hourSystem;

  void setFirstDayOfWeek(int value) {
    _firstDayOfWeek = value;
    notifyListeners();
  }

  void setShowWeekNumber(bool value) {
    _showWeekNumber = value;
    notifyListeners();
  }

  void setIs24hourSystem(bool value) {
    _is24hourSystem = value;
    notifyListeners();
  }
}
