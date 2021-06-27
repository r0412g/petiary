import 'dart:core';
import 'dart:io';
import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:pet_diary/common/theme.dart';

class IntroPage extends StatefulWidget {
  _IntroPageState createState() => _IntroPageState();
}

class MyPetInfo {
  static var myPetImage;

  static String myPetType = '請選擇';
  static String myPetBreeds = '請選擇';

  static int genderIndex = 0;

  static TextEditingController petTypeController = TextEditingController();
  static TextEditingController petBreedsController = TextEditingController();
  static TextEditingController petNameController = TextEditingController();
}

class AllPetData {
  static String? petType;
  static String? petBreeds;

  static List<String> defaultBreeds = [];
  static List<String> dogBreeds = [
    '博美',
    '法鬥',
    '臘腸',
    '貴賓',
    '柯基',
    '柴犬',
    '比熊犬',
    '巴哥犬',
    '米格魯',
    '牧羊犬',
    '哈士奇',
    '吉娃娃',
    '薩摩耶',
    '雪納瑞',
    '約克夏',
    '蝴蝶犬',
    '馬爾濟斯',
    '拉不拉多',
    '黃金獵犬',
    '自行輸入'
  ];
  static List<String> catBreeds = [
    '虎斑貓',
    '波斯貓',
    '玳瑁貓',
    '暹羅貓',
    '布偶貓',
    '三色貓',
    '迷克斯',
    '曼赤肯貓',
    '美國短毛貓',
    '英國短毛貓',
    '自行輸入'
  ];
  static List<String> rabbitBreeds = [
    '道奇兔',
    '海棠兔',
    '獅子兔',
    '銀貂兔',
    '香檳兔',
    '奶油兔',
    '銀狐兔',
    '斑點兔',
    '金吉拉兔',
    '安哥拉兔',
    '比利時兔',
    '黃暹羅兔',
    '黑暹羅兔',
    '白暹羅兔',
    '波蘭白兔',
    '雷克斯兔',
    '長毛垂耳兔',
    '短毛垂耳兔',
    '紐西蘭大白兔',
    '自行輸入'
  ];
  static List<String> turtleBreeds = [
    '蛋龜',
    '擬鱷龜',
    '平胸龜',
    '中華花龜',
    '中華草龜',
    '黃喉擬水龜',
    '巴西紅耳龜',
    '三線閉殼龜',
    '自行輸入'
  ];
}

class _IntroPageState extends State<IntroPage> {
  bool imageSelected = false;

  final introKey = GlobalKey<IntroductionScreenState>();
  final formattedDate = DateFormat('yyyy-MM-dd');

  String myPetBirth = '點擊選擇寵物生日';

  var myPetName;

  TextStyle titleStyle = TextStyle(
    color: ColorSet.secondaryColors,
    fontSize: 20,
    letterSpacing: 1.5,
  );

  TextStyle pageTwoContentStyle = TextStyle(
    color: ColorSet.secondaryColors,
    fontSize: 15,
    letterSpacing: 1.5,
  );

  /* Select Pet Image On User Device */
  Future<Null> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    MyPetInfo.myPetImage = pickedImage;
    if (MyPetInfo.myPetImage != null) {
      setState(() {
        imageSelected = true;
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
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: MyPetInfo.myPetImage.path,
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
      androidUiSettings: AndroidUiSettings(
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
    if (croppedFile != null) {
      setState(() {
        MyPetInfo.myPetImage = croppedFile;
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

  void _onIntroEnd(context) {
    myPetName = MyPetInfo.petNameController.text;
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (context) => new MyHomePage(title: '寵物日記')));
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: introKey,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0.0, 150.0, 0.0, 150.0),
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
                                                MyPetInfo.myPetBreeds =
                                                    MyPetInfo
                                                        .petBreedsController
                                                        .text;
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
                const SizedBox(height: 40.0),
                /* Show User Selected Type And Breeds */
                SingleChildScrollView(
                    child: Column(children: <Widget>[
                  Text(
                    '我的寵物類型：${MyPetInfo.myPetType}',
                    style: pageTwoContentStyle,
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    '我的寵物品種：${MyPetInfo.myPetBreeds}',
                    style: pageTwoContentStyle,
                  ),
                ])),
              ],
            ),
          ),
          margin: MyCardTheme.cardMargin,
          shape: MyCardTheme.cardShapeBorder,
        ),
        /* Page 3: Set Pet Information */
        Card(
          color: ColorSet.primaryColors,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0.0, 150.0, 0.0, 150.0),
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
                    MyPetInfo.myPetImage != null
                        ? Image.file(File(MyPetInfo.myPetImage.path),
                            fit: BoxFit.fill, width: 150.0, height: 150.0)
                        : Image.asset('assets/paw.jpg',
                            fit: BoxFit.fill, width: 150.0, height: 150.0),
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
                                  if (imageSelected == true) {
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
                                    style:
                                        const TextStyle(color: Colors.black))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Container(
                  color: ColorSet.thirdColors,
                  width: 250.0,
                  height: 40.0,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: MyPetInfo.petNameController,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.pets),
                      hintText: '請輸入寵物的名字',
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Container(
                  color: ColorSet.thirdColors,
                  width: 250.0,
                  height: 40.0,
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 1,
                        child: const Icon(Icons.calendar_today,
                            color: Colors.black45),
                      ),
                      Expanded(
                        flex: 2,
                        child: Tooltip(
                          message: '選擇日期',
                          child: TextButton(
                            style: TextButton.styleFrom(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(2.0),
                                primary: Colors.black45,
                                textStyle: const TextStyle(fontSize: 17),
                                minimumSize: const Size(225, 35)),
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(1971, 1, 1),
                                  maxTime: DateTime(2030, 12, 31),
                                  onConfirm: (date) {
                                setState(() {
                                  myPetBirth = formattedDate.format(date);
                                });
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.tw);
                            },
                            child: Text(myPetBirth),
                          ),
                        ),
                      ),
                    ],
                  ),
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
              ],
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
        child: Text('跳過'),
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
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: ColorSet.secondaryDarkColors,
        activeColor: Colors.brown,
      ),
      dotsFlex: 1,
    );
  }
}
