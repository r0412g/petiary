import 'dart:io';
import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class IntroPage extends StatefulWidget {
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool imageSelected = false;

  HexColor primaryColors = HexColor("#455A64");
  HexColor primaryLightColors = HexColor('#718792');
  HexColor secondaryColors = HexColor('#D7CCC8');
  HexColor secondaryDarkColors = HexColor('#A69B97');
  HexColor thirdColors = HexColor('#C4C4C4');

  final introKey = GlobalKey<IntroductionScreenState>();
  final formattedDate = DateFormat('yyyy-MM-dd');

  String? _petType;
  String? _petBreeds;
  String myPetType = '請選擇';
  String myPetBreeds = '請選擇';
  String myPetBirth = '點擊選擇寵物生日';
  String myPetGender = 'male';

  TextEditingController petTypeController = TextEditingController();
  TextEditingController petBreedsController = TextEditingController();
  TextEditingController petNameController = TextEditingController();

  var myPetImage;
  var myPetName;

  List<String> _default = [];
  List<String> _dogBreeds = [
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
  List<String> _catBreeds = [
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
  List<String> _rabbitBreeds = [
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
  List<String> _turtleBreeds = [
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

  /* Select Pet Image On User Device */
  Future<Null> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    myPetImage = pickedImage;
    if (myPetImage != null) {
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
      sourcePath: myPetImage.path,
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
        activeControlsWidgetColor: primaryColors,
        backgroundColor: Colors.black,
        cropFrameStrokeWidth: 5,
        cropGridStrokeWidth: 5,
        dimmedLayerColor: primaryLightColors,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        toolbarTitle: '剪裁相片',
        toolbarColor: primaryColors,
        toolbarWidgetColor: Colors.white,
      ),
    );
    if (croppedFile != null) {
      setState(() {
        myPetImage = croppedFile;
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
    myPetName = petNameController.text;
    print("我的寵物類型為$myPetType");
    print("我的寵物品種為$myPetBreeds");
    print("我的寵物名為$myPetName");
    print("我的寵物性別為$myPetGender");
    print("我的寵物生日為$myPetBirth");
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (context) => new MyHomePage(title: '寵物日記')));
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: primaryLightColors,

      /* All pages in IntroScreen */
      rawPages: [
        /* Page 1: Welcome Page */
        Card(
          color: primaryColors,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '歡迎使用寵物日記\n\n讓我們先來做些初始設定吧!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryColors,
                  fontSize: 20,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          margin: EdgeInsets.all(35.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        /* Page 2: Select Pet Type And Breeds */
        Card(
          color: primaryColors,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '請選擇您的寵物類型',
                style: TextStyle(
                  color: secondaryColors,
                  fontSize: 20,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 40),
              Container(
                color: thirdColors,
                width: 250,
                height: 40,
                alignment: Alignment.center,
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: thirdColors,
                  value: _petType,
                  onChanged: (value) {
                    setState(() {
                      _petType = value;
                      myPetBreeds = "請選擇";
                    });
                    _default.clear();
                    /* Change Breeds List By Select Different Type */
                    switch (_petType) {
                      case "狗狗":
                        myPetType = "狗狗";
                        _default.addAll(_dogBreeds);
                        break;
                      case "貓咪":
                        myPetType = "貓咪";
                        _default.addAll(_catBreeds);
                        break;
                      case "兔子":
                        myPetType = "兔子";
                        _default.addAll(_rabbitBreeds);
                        break;
                      case "烏龜":
                        myPetType = "烏龜";
                        _default.addAll(_turtleBreeds);
                        break;
                      case "其他":
                        _default.add("自行輸入");
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('自行輸入寵物類型'),
                                actions: <Widget>[
                                  TextFormField(
                                    controller: petTypeController,
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
                                              myPetType =
                                                  petTypeController.text;
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
                        _default.clear();
                    }
                    _petBreeds = null;
                  },
                  items: <String>['狗狗', '貓咪', '兔子', '烏龜', '其他']
                      .map<DropdownMenuItem<String>>((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: new Text(type),
                    );
                  }).toList(),
                  hint: Text(
                    "選擇寵物類型",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                '請選擇您的寵物品種(花色)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryColors,
                  fontSize: 20,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 40),
              Container(
                color: thirdColors,
                width: 250,
                height: 40,
                alignment: Alignment.center,
                child: DropdownButton(
                  hint: Text(
                    "選擇寵物品種(花色)",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  value: _petBreeds,
                  isExpanded: true,
                  dropdownColor: thirdColors,
                  onChanged: (String? value) {
                    setState(() {
                      _petBreeds = value;
                      myPetBreeds = value.toString();
                    });
                    switch (value) {
                      case "自行輸入":
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('自行輸入寵物品種(花色)'),
                                actions: <Widget>[
                                  TextFormField(
                                    controller: petBreedsController,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.pets),
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
                                              myPetBreeds =
                                                  petBreedsController.text;
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
                  items: _default.map<DropdownMenuItem<String>>((breeds) {
                    return DropdownMenuItem<String>(
                      value: breeds,
                      child: new Text(breeds),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 40),
              /* Show User Selected Type And Breeds */
              SingleChildScrollView(
                  child: Column(children: <Widget>[
                Text(
                  '我的寵物類型：$myPetType',
                  style: TextStyle(
                    color: secondaryColors,
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '我的寵物品種：$myPetBreeds',
                  style: TextStyle(
                    color: secondaryColors,
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
              ])),
            ],
          ),
          margin: EdgeInsets.all(35.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        /* Page 3: Set Pet Information */
        Card(
          color: primaryColors,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '來輸入寵物的基本資料吧!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryColors,
                    fontSize: 20,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    myPetImage != null
                        ? Image.file(File(myPetImage.path),
                            fit: BoxFit.fill, width: 150, height: 150)
                        : Image.asset('assets/paw.jpg',
                            fit: BoxFit.fill, width: 150, height: 150),
                    SizedBox(width: 20),
                    SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Tooltip(
                            message: "新增寵物相片",
                            child: TextButton.icon(
                                onPressed: () {
                                  _pickImage();
                                },
                                icon: Icon(
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
                                icon: Icon(
                                  Icons.crop,
                                  color: Colors.black,
                                ),
                                label: Text('剪裁相片',
                                    style: TextStyle(color: Colors.black))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  color: thirdColors,
                  width: 250,
                  height: 40,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: petNameController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.pets),
                      hintText: '請輸入寵物的名字',
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  color: thirdColors,
                  width: 250,
                  height: 40,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child:
                            Icon(Icons.calendar_today, color: Colors.black45),
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
                                minimumSize: Size(225, 35)),
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
                SizedBox(height: 30),
                ToggleSwitch(
                  minWidth: 90.0,
                  initialLabelIndex: 0,
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
                        myPetGender = "male";
                        break;
                      case 1:
                        myPetGender = "female";
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
          margin: EdgeInsets.all(35.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ],
      isTopSafeArea: true,
      isBottomSafeArea: true,
      color: secondaryColors,

      /* Skip Button */
      skip: const Text('跳過'),
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
      controlsMargin: EdgeInsets.all(40.0),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: secondaryDarkColors,
        activeColor: Colors.brown,
      ),
      dotsFlex: 1,
    );
  }
}
