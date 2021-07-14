import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_diary/main.dart';
import 'package:pet_diary/models/pet_model.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/common/data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class IntroPage extends StatefulWidget {
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int introGenderIndex = 0;
  bool introIsNeutered = false;
  bool introIsExactDate = false;
  bool introImageSelected = false;
  final formattedDate = DateFormat('yyyy-MM-dd');
  var introImage;

  FocusNode introNameFocusNode = new FocusNode();
  FocusNode introDateFocusNode = new FocusNode();
  TextEditingController introTypeController = TextEditingController();
  TextEditingController introBreedsController = TextEditingController();
  TextEditingController introNameController = TextEditingController();
  TextEditingController introAgeController = TextEditingController();

  TextStyle titleStyle = const TextStyle(
    color: ColorSet.secondaryColors,
    fontSize: 20,
    letterSpacing: 1.5,
  );

  TextStyle introPageTwoTextStyle = const TextStyle(
    color: ColorSet.secondaryColors,
    fontSize: 15,
    letterSpacing: 1.5,
  );

  /* Clean up the controller when the widget is disposed */
  @override
  void dispose() {
    introTypeController.dispose();
    introBreedsController.dispose();
    introNameController.dispose();
    introAgeController.dispose();
    super.dispose();
  }

  /* Select Pet Image On User Device */
  Future<Null> _pickImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    introImage = pickedImage;

    // Image selected then save
    if (introImage != null) {
      introImageSelected = true;
      await prefs.setString('keyPetImagePath', introImage.path);
      setState(() {
        myPet.setImagePath(introImage.path);
      });
      Fluttertoast.showToast(
          msg: "可以點選剪裁相片修改唷!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "您沒有選擇相片",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  /* Crop Pet Image By User Selected */
  Future<Null> _cropImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: introImage.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: const AndroidUiSettings(
        activeControlsWidgetColor: ColorSet.primaryColors,
        backgroundColor: Colors.black,
        cropFrameStrokeWidth: 5,
        cropGridStrokeWidth: 5,
        dimmedLayerColor: ColorSet.primaryLightColors,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        toolbarTitle: '剪裁相片',
        toolbarColor: ColorSet.primaryColors,
        toolbarWidgetColor: Colors.white,
      ),
    );

    // Image cropped then save
    if (croppedFile != null) {
      introImage = croppedFile;
      await prefs.setString('keyPetImagePath', introImage.path);
      setState(() {
        myPet.setImagePath(introImage.path);
      });
    } else {
      Fluttertoast.showToast(
          msg: "您沒有剪裁相片",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  _onIntroEnd(context) async {
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save pet name if user have input
    if (introNameController.text != '') {
      myPet.setName(introNameController.text);
      await prefs.setString('keyPetName', introNameController.text);
    }

    myPet.setIsExactDate(introIsExactDate);
    await prefs.setBool('keyIsExactDate', introIsExactDate);
    // Save pet age if user have input
    if (introAgeController.text != '') {
      myPet.setAge(introAgeController.text);
      await prefs.setString('keyPetAge', introAgeController.text);
    }

    myPet.setLigation(introIsNeutered);

    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (context) => new MyHomePage(title: '寵物日記')));
  }

  @override
  Widget build(BuildContext context) {
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);

    return IntroductionScreen(
      globalBackgroundColor: ColorSet.primaryLightColors,
      /* All pages in IntroScreen */
      rawPages: [
        /* Page 1: Welcome Page */
        Card(
          color: ColorSet.primaryColors,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '歡迎使用寵物日記\n\n讓我們先來做些初始設定吧!',
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ],
          ),
          margin: MyCardTheme.cardMargin,
          shape: MyCardTheme.cardShapeBorder,
        ),
        /* Page 2: Select Pet Type And Breeds */
        Card(
          color: ColorSet.primaryColors,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '請選擇您的寵物類型',
                    style: titleStyle,
                  ),
                  const SizedBox(height: 40.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: ColorSet.thirdColors,
                      value: AllPetModel.petType,
                      onChanged: (value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          AllPetModel.petType = value;
                          myPet.setBreeds("請選擇");
                        });
                        AllPetModel.defaultBreeds.clear();
                        myPet.setBreeds('');
                        await prefs.setString('keyPetBreeds', '');
                        /* Change Breeds List By Select Different Type */
                        switch (AllPetModel.petType) {
                          case "狗狗":
                            myPet.setType("狗狗");
                            prefs.setString('keyPetType', '狗狗');
                            AllPetModel.defaultBreeds
                                .addAll(AllPetModel.dogBreeds);
                            break;
                          case "貓咪":
                            myPet.setType("貓咪");
                            prefs.setString('keyPetType', '貓咪');
                            AllPetModel.defaultBreeds
                                .addAll(AllPetModel.catBreeds);
                            break;
                          case "兔子":
                            myPet.setType("兔子");
                            prefs.setString('keyPetType', '兔子');
                            AllPetModel.defaultBreeds
                                .addAll(AllPetModel.rabbitBreeds);
                            break;
                          case "烏龜":
                            myPet.setType("烏龜");
                            prefs.setString('keyPetType', '烏龜');
                            AllPetModel.defaultBreeds
                                .addAll(AllPetModel.turtleBreeds);
                            break;
                          case "其他":
                            AllPetModel.defaultBreeds.add("自行輸入");
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('自行輸入寵物類型'),
                                    actions: <Widget>[
                                      TextFormField(
                                        controller: introTypeController,
                                        decoration: const InputDecoration(
                                          icon: const Icon(Icons.pets),
                                          hintText: '請輸入寵物的類型',
                                        ),
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('取消'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, 'OK');
                                                setState(() {
                                                  prefs.setString('keyPetType',
                                                      introTypeController.text);
                                                  myPet.setType(
                                                      introTypeController.text);
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
                        AllPetModel.petBreeds = null;
                      },
                      items: <String>['狗狗', '貓咪', '兔子', '烏龜', '其他']
                          .map<DropdownMenuItem<String>>((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: new Text(type),
                        );
                      }).toList(),
                      hint: const Text(
                        "選擇寵物類型",
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Text(
                    '請選擇您的寵物品種(花色)',
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                  const SizedBox(height: 40.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    child: DropdownButton(
                      hint: const Text(
                        "選擇寵物品種(花色)",
                      ),
                      value: AllPetModel.petBreeds,
                      isExpanded: true,
                      dropdownColor: ColorSet.thirdColors,
                      onChanged: (String? value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('keyPetBreeds', value.toString());
                        setState(() {
                          AllPetModel.petBreeds = value;
                          myPet.setBreeds(value.toString());
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
                                        controller: introBreedsController,
                                        decoration: const InputDecoration(
                                          icon: const Icon(Icons.pets),
                                          hintText: '請輸入寵物的品種(花色)',
                                        ),
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('取消'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.setString(
                                                    'keyPetBreeds',
                                                    introBreedsController.text);
                                                Navigator.pop(context, 'OK');
                                                setState(() {
                                                  myPet.setBreeds(
                                                      introBreedsController
                                                          .text);
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
                      items: AllPetModel.defaultBreeds
                          .map<DropdownMenuItem<String>>((breeds) {
                        return DropdownMenuItem<String>(
                          value: breeds,
                          child: new Text(breeds),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  /* Show User Selected Type And Breeds */
                  SingleChildScrollView(
                      child: Column(children: <Widget>[
                    Text(
                      '我的寵物類型：${myPet.getType}',
                      style: introPageTwoTextStyle,
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      '我的寵物品種：${myPet.getBreeds}',
                      style: introPageTwoTextStyle,
                    ),
                  ])),
                ],
              ),
            ),
          ),
          margin: MyCardTheme.cardMargin,
          shape: MyCardTheme.cardShapeBorder,
        ),
        /* Page 3: Set Pet Information */
        Card(
          color: ColorSet.primaryColors,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '來輸入寵物的基本資料吧!',
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      introImage != null
                          ? Image.file(File(introImage.path),
                              fit: BoxFit.fill, width: 125.0, height: 125.0)
                          : Image.asset(AllPetModel.defaultImage,
                              fit: BoxFit.fill, width: 125.0, height: 125.0),
                      const SizedBox(width: 20.0),
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Tooltip(
                              message: "新增寵物相片",
                              child: TextButton.icon(
                                  onPressed: () {
                                    _pickImage();
                                  },
                                  icon: const Icon(
                                    Icons.add_photo_alternate,
                                    color: Colors.black,
                                  ),
                                  label: Text('選擇相片',
                                      style: TextStyle(color: Colors.black))),
                            ),
                            Tooltip(
                              message: "剪裁寵物相片",
                              child: TextButton.icon(
                                  onPressed: () {
                                    if (introImageSelected == true) {
                                      _cropImage();
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "請先選擇相片",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          fontSize: 16.0);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.crop,
                                    color: Colors.black,
                                  ),
                                  label: const Text('剪裁相片',
                                      style: const TextStyle(
                                          color: Colors.black))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    height: 40.0,
                    child: TextField(
                      focusNode: introNameFocusNode,
                      cursorColor: ColorSet.primaryLightColors,
                      controller: introNameController,
                      onEditingComplete: () {
                        introNameFocusNode.unfocus();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.pets,
                            color: ColorSet.primaryLightColors),
                        hintText: '請輸入寵物的名字',
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    child: SwitchListTile(
                        title: const Text('寵物是否結紮?'),
                        subtitle: introIsNeutered == false
                            ? const Text('否')
                            : const Text('是'),
                        value: introIsNeutered,
                        activeColor: ColorSet.primaryLightColors,
                        onChanged: (value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('keyPetLigation', value);
                          setState(() {
                            introIsNeutered = value;
                          });
                        }),
                  ),
                  const SizedBox(height: 25.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                            title: Text('寵物確切生日?'),
                            subtitle: introIsExactDate == true
                                ? const Text('是')
                                : const Text('否'),
                            value: introIsExactDate,
                            activeColor: ColorSet.primaryLightColors,
                            onChanged: (value) {
                              setState(() {
                                introIsExactDate = value;
                              });
                              /* Reset value while switch on changed */
                              if (introIsExactDate == false) {
                                myPet.setBirthday('點擊選擇寵物生日');
                              } else {
                                myPet.setAge('');
                                introAgeController.text = '';
                              }
                            }),
                        introIsExactDate == true
                            ? Tooltip(
                                message: '選擇日期',
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    alignment: Alignment.center,
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            ColorSet.primaryLightColors),
                                  ),
                                  onPressed: () {
                                    DatePicker.showDatePicker(
                                      context,
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.tw,
                                      minTime: DateTime(1971, 1, 1),
                                      maxTime: DateTime(2030, 12, 31),
                                      onConfirm: (date) async {
                                        int birthdayAge =
                                            DateTime.now().year - date.year;
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setString('keyPetBirthday',
                                            formattedDate.format(date));
                                        setState(() {
                                          myPet.setBirthday(
                                              formattedDate.format(date));
                                          myPet.setAge(birthdayAge.toString());
                                        });
                                      },
                                      theme: DatePickerTheme(
                                        cancelStyle: const TextStyle(
                                            color: Colors.redAccent),
                                      ),
                                    );
                                  },
                                  child: Text(myPet.getBirthday == ''
                                      ? '點擊選擇寵物生日'
                                      : myPet.getBirthday),
                                ),
                              )
                            : Container(
                                width: 150.0,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  focusNode: introDateFocusNode,
                                  cursorColor: ColorSet.primaryLightColors,
                                  controller: introAgeController,
                                  onEditingComplete: () {
                                    introDateFocusNode.unfocus();
                                  },
                                  decoration: const InputDecoration(
                                    suffixText: '歲',
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(
                                        Icons.date_range_outlined,
                                        color: ColorSet.primaryLightColors),
                                    hintText: '請輸入年齡',
                                  ),
                                ),
                              ),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  ToggleSwitch(
                    minWidth: 90.0,
                    initialLabelIndex: introGenderIndex,
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
                    onToggle: (index) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      switch (index) {
                        case 0:
                          introGenderIndex = 0;
                          myPet.setGender('男');
                          await prefs.setString('keyPetGender', '男');
                          break;
                        case 1:
                          introGenderIndex = 1;
                          myPet.setGender('女');
                          await prefs.setString('keyPetGender', '女');
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          margin: MyCardTheme.cardMargin,
          shape: MyCardTheme.cardShapeBorder,
        ),
      ],
      isTopSafeArea: true,
      isBottomSafeArea: true,
      color: ColorSet.secondaryColors,

      /* Skip Button */
      skip: const Tooltip(
        message: '跳過初始設定',
        child: const Text('跳過'),
      ),
      showSkipButton: true,
      skipFlex: 1,

      /* Next Button */
      next: const Text('下一頁'),
      showNextButton: true,
      nextFlex: 1,

      /* Done Button */
      done: const Text('完成'),
      onDone: () => _onIntroEnd(context),

      /* controls/dots */
      controlsMargin: const EdgeInsets.all(40.0),
      dotsDecorator: const DotsDecorator(
        size: const Size(10.0, 10.0),
        color: ColorSet.secondaryDarkColors,
        activeColor: Colors.brown,
      ),
      dotsFlex: 1,
    );
  }
}
