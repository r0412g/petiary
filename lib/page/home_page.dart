import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/models/pet_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextStyle contentStyle = const TextStyle(
    color: Colors.black,
    fontSize: 17,
    letterSpacing: 1.5,
    height: 2.0,
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
      myPet.setName(prefs.getString('keyPetName') ?? '尚未設定');
      myPet.setType(prefs.getString('keyPetType') ?? '尚未設定');
      myPet.setBreeds(prefs.getString('keyPetBreeds') ?? '尚未設定');
      myPet.setGender(prefs.getString('keyPetGender') ?? '男');
      myPet.setLigation(prefs.getBool('keyPetLigation') ?? false);
      myPet.setImagePath(prefs.getString('keyPetImagePath') ?? '');

      if (myPet.getIsExactDate == true)
        myPet.setBirthday(prefs.getString('keyPetBirthday') ?? '尚未設定');
      else
        myPet.setAge(prefs.getString('keyPetAge') ?? '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    var myPet = Provider.of<MyPetModel>(context);

    return Center(
        child: SingleChildScrollView(
      child: Card(
        color: ColorSet.secondaryColors,
        child: Padding(
          padding: myPet.getIsExactDate == true
              ? const EdgeInsets.fromLTRB(50.0, 75.0, 50.0, 75.0)
              : const EdgeInsets.all(75.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              myPet.getImagePath != ''
                  ? Image.file(File(myPet.getImagePath),
                      fit: BoxFit.fill, width: 150.0, height: 150.0)
                  : Image.asset(AllPetModel.defaultImage,
                      fit: BoxFit.fill, width: 150.0, height: 150.0),
              const SizedBox(height: 10.0),
              Text('我的寵物：${myPet.getName}', style: contentStyle),
              myPet.getIsExactDate == true
                  ? Text('生日：${myPet.getBirthday} (${myPet.getAge}歲)',
                      style: contentStyle)
                  : Text('年齡：${myPet.getAge} 歲', style: contentStyle),
              Text('類型：${myPet.getType}', style: contentStyle),
              Text('品種：${myPet.getBreeds}', style: contentStyle),
              Text('性別：${myPet.getGender}', style: contentStyle),
              Text('結紮：${myPet.getLigation == false ? '未結紮' : '已結紮'}',
                  style: contentStyle),
            ],
          ),
        ),
        margin: MyCardTheme.cardMargin,
        shape: MyCardTheme.cardShapeBorder,
      ),
    ));
  }
}
