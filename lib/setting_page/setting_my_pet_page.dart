import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/intro_page.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingMyPetPage extends StatefulWidget {
  SettingMyPetPage({Key? key}) : super(key: key);
  @override
  _SettingMyPetPageState createState() => _SettingMyPetPageState();
}

class _SettingMyPetPageState extends State<SettingMyPetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('編輯我的寵物'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          color: ColorSet.primaryLightColors,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30.0),
              MyPetInfo.myPetImage != null
                  ? Image.file(File(MyPetInfo.myPetImage.path),
                      fit: BoxFit.fill, width: 150.0, height: 150.0)
                  : Image.asset('assets/paw.jpg',
                      fit: BoxFit.fill, width: 150.0, height: 150.0),
              const SizedBox(height: 10.0),
              TextField(
                controller: MyPetInfo.petNameController,
                decoration: InputDecoration(
                    icon: Icon(Icons.pets),
                    labelText: '寵物名字',
                    hintText: '請輸入寵物名字'),
              ),
              const SizedBox(height: 30.0),
              ToggleSwitch(
                minWidth: 90.0,
                initialLabelIndex: MyPetInfo.genderIndex,
                cornerRadius: 20.0,
                activeFgColor: Colors.black,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                icons: [Icons.male, Icons.female],
                iconSize: 20,
                activeBgColors: [
                  [Colors.blue],
                  [Colors.pink]
                ],
                onToggle: (index) {
                  switch (index) {
                    case 0:
                      MyPetInfo.genderIndex = 0;
                      break;
                    case 1:
                      MyPetInfo.genderIndex = 1;
                      break;
                  }
                },
              ),
              const SizedBox(height: 30.0),
              Container(
                color: ColorSet.thirdColors,
                width: 250.0,
                height: 40.0,
                alignment: Alignment.center,
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: ColorSet.thirdColors,
                  value: AllPetData.petType,
                  onChanged: (value) {
                    setState(() {
                      AllPetData.petType = value;
                      MyPetInfo.myPetBreeds = "請選擇";
                    });
                    AllPetData.defaultBreeds.clear();
                    /* Change Breeds List By Select Different Type */
                    switch (AllPetData.petType) {
                      case "狗狗":
                        MyPetInfo.myPetType = "狗狗";
                        AllPetData.defaultBreeds.addAll(AllPetData.dogBreeds);
                        break;
                      case "貓咪":
                        MyPetInfo.myPetType = "貓咪";
                        AllPetData.defaultBreeds.addAll(AllPetData.catBreeds);
                        break;
                      case "兔子":
                        MyPetInfo.myPetType = "兔子";
                        AllPetData.defaultBreeds
                            .addAll(AllPetData.rabbitBreeds);
                        break;
                      case "烏龜":
                        MyPetInfo.myPetType = "烏龜";
                        AllPetData.defaultBreeds
                            .addAll(AllPetData.turtleBreeds);
                        break;
                      case "其他":
                        AllPetData.defaultBreeds.add("自行輸入");
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('自行輸入寵物類型'),
                                actions: <Widget>[
                                  TextFormField(
                                    controller: MyPetInfo.petTypeController,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.pets),
                                      hintText: '請輸入寵物的類型',
                                    ),
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, 'OK');
                                            setState(() {
                                              MyPetInfo.myPetType = MyPetInfo
                                                  .petTypeController.text;
                                            });
                                          },
                                          child: const Text('確定'),
                                        ),
                                      ]),
                                ],
                              );
                            });
                        break;
                      default:
                        AllPetData.defaultBreeds.clear();
                    }
                    AllPetData.petBreeds = null;
                  },
                  items: <String>['狗狗', '貓咪', '兔子', '烏龜', '其他']
                      .map<DropdownMenuItem<String>>((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: new Text(type),
                    );
                  }).toList(),
                  hint: Text(
                    MyPetInfo.myPetType == '請選擇'
                        ? "選擇寵物類型"
                        : '${MyPetInfo.myPetType}',
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              Container(
                color: ColorSet.thirdColors,
                width: 250.0,
                height: 40.0,
                alignment: Alignment.center,
                child: DropdownButton(
                  hint: Text(
                    MyPetInfo.myPetBreeds == '請選擇'
                        ? "選擇寵物品種(花色)"
                        : '${MyPetInfo.myPetBreeds}',
                  ),
                  value: AllPetData.petBreeds,
                  isExpanded: true,
                  dropdownColor: ColorSet.thirdColors,
                  onChanged: (String? value) {
                    setState(() {
                      AllPetData.petBreeds = value;
                      MyPetInfo.myPetBreeds = value.toString();
                    });
                    switch (value) {
                      case "自行輸入":
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('自行輸入寵物品種(花色)'),
                                actions: <Widget>[
                                  TextFormField(
                                    controller: MyPetInfo.petBreedsController,
                                    decoration: const InputDecoration(
                                      icon: const Icon(Icons.pets),
                                      hintText: '請輸入寵物的品種(花色)',
                                    ),
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, 'OK');
                                            setState(() {
                                              MyPetInfo.myPetBreeds = MyPetInfo
                                                  .petBreedsController.text;
                                            });
                                          },
                                          child: const Text('確定'),
                                        ),
                                      ]),
                                ],
                              );
                            });
                        break;
                      default:
                      /**/
                    }
                  },
                  items: AllPetData.defaultBreeds
                      .map<DropdownMenuItem<String>>((breeds) {
                    return DropdownMenuItem<String>(
                      value: breeds,
                      child: new Text(breeds),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
          shape: MyCardTheme.cardShapeBorder,
          margin: MyCardTheme.cardMargin,
        ),
      ),
    );
  }
}
