import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/* Using for Provider */
class MyPetModel with ChangeNotifier {
  bool _isNeutered = false;
  bool _isExactDate = false;
  String _imagePath = '';
  String _type = '';
  String _breeds = '';
  String _gender = '男';
  String _birthday = '';
  String _name = '';
  String _age = '';

  bool get getIsNeutered => _isNeutered;
  bool get getIsExactDate => _isExactDate;
  String get getType => _type;
  String get getImagePath => _imagePath;
  String get getBreeds => _breeds;
  String get getGender => _gender;
  String get getBirthday => _birthday;
  String get getName => _name;
  String get getAge => _age;

  void setType(String value) {
    _type = value;
    notifyListeners();
  }

  void setImagePath(String value) {
    _imagePath = value;
    notifyListeners();
  }

  void setBreeds(String value) {
    _breeds = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setBirthday(String value) {
    _birthday = value;
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setAge(String value) {
    _age = value;
    notifyListeners();
  }

  void setIsNeutered(bool value) {
    _isNeutered = value;
    notifyListeners();
  }

  void setIsExactDate(bool value) {
    _isExactDate = value;
    notifyListeners();
  }
}
