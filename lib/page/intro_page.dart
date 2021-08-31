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
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/main.dart';
import 'package:pet_diary/models/pet_model.dart';
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
  final formattedDate = DateFormat('yyyy-MM-dd');
  var introImageByFile;
  String introImagePathByAssets = 'assets/images/default_image.png';

  FocusNode introNameFocusNode = new FocusNode();
  FocusNode introDateFocusNode = new FocusNode();
  TextEditingController introTypeController = TextEditingController();
  TextEditingController introBreedsController = TextEditingController();
  TextEditingController introNameController = TextEditingController();
  TextEditingController introAgeController = TextEditingController();

  TextStyle _titleStyle = const TextStyle(
    color: ColorSet.colorsBlackOfOpacity80,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  Decoration _containerOfDropdownButtonDeco = ShapeDecoration(
    shape: RoundedRectangleBorder(
      side:
          BorderSide(color: ColorSet.primaryColorsGreenOfOpacity80, width: 3.0),
      borderRadius: ForAllTheme.allRadius,
    ),
  );

  List<BoxShadow> _boxShadow = [
    const BoxShadow(
      color: ColorSet.colorsGrayOfOpacity80,
      blurRadius: 5.0,
      offset: const Offset(2.0, 2.0),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

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
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      introImageByFile = pickedImage;
    });

    // Image selected then save
    if (introImageByFile != null) {
      introImagePathByAssets = '';
      prefs.setString('keyPetImagePathByAssets', '');
      _cropImage();
    } else {
      Fluttertoast.showToast(
          msg: "您沒有選擇相片",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: ColorSet.colorsBlackOfOpacity80,
          fontSize: 16.0);
    }
  }

  /* Crop Pet Image By User Selected */
  Future<Null> _cropImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: introImageByFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: const AndroidUiSettings(
        activeControlsWidgetColor: ColorSet.primaryColorsGreenOfOpacity80,
        backgroundColor: ColorSet.colorsBlackOfOpacity80,
        cropFrameStrokeWidth: 5,
        cropGridStrokeWidth: 5,
        cropFrameColor: ColorSet.colorsBlackOfOpacity80,
        dimmedLayerColor: ColorSet.colorsWhiteGrayOfOpacity80,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: false,
        toolbarTitle: '剪裁相片',
        toolbarColor: ColorSet.colorsBlackOfOpacity80,
        toolbarWidgetColor: ColorSet.colorsWhite,
        showCropGrid: false,
      ),
    );

    // Image cropped then save
    if (croppedFile != null) {
      setState(() {
        introImageByFile = croppedFile;
      });
      introImagePathByAssets = '';
      prefs.setString('keyPetImagePathByAssets', '');
    } else {
      Fluttertoast.showToast(
          msg: "您沒有剪裁相片",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: ColorSet.colorsBlackOfOpacity80,
          fontSize: 16.0);
    }
  }

  _onIntroEnd(context) async {
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('keyChecked', true);

    if (introImageByFile != null) {
      //myPet.setImagePathByFile(introImageByFile.path);
      await prefs.setString('keyPetImagePathByFile', introImageByFile.path);
    }
    if (introImagePathByAssets != '') {
      //myPet.setImagePathByAssets(introImagePathByAssets);
      await prefs.setString('keyPetImagePathByAssets', introImagePathByAssets);
    }
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

    myPet.setIsNeutered(introIsNeutered);
    await prefs.setBool('keyIsNeutered', introIsNeutered);

    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);

    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      /* All pages in IntroScreen */
      rawPages: [
        /* Page 1: Welcome Page */
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                width: 175.0,
                height: 175.0,
              ),
              SizedBox(
                height: 70.0,
              ),
              Text(
                '歡迎使用寵物日記\n\n一起為您的寵物建立檔案吧！',
                textAlign: TextAlign.center,
                style: _titleStyle,
              ),
            ],
          ),
        ),
        /* Page 2: Select Pet Type And Breeds */
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '您的寵物類型：${myPet.getType}',
                  style: _titleStyle,
                ),
                const SizedBox(height: 25.0),
                Container(
                    width: 250.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    decoration: _containerOfDropdownButtonDeco,
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration.collapsed(hintText: ''),
                          icon: Icon(Icons.keyboard_arrow_down_outlined),
                          iconSize: 30.0,
                          iconEnabledColor:
                              ColorSet.primaryColorsGreenOfOpacity80,
                          isExpanded: true,
                          value: AllDataModel.petType,
                          onChanged: (value) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              AllDataModel.petType = value;
                              myPet.setBreeds("請選擇");
                            });
                            AllDataModel.defaultBreeds.clear();
                            myPet.setBreeds('');
                            await prefs.setString('keyPetImagePathByFile', '');
                            introImageByFile = null;
                            await prefs.setString('keyPetBreeds', '');
                            /* Change Breeds List By Select Different Type */
                            switch (AllDataModel.petType) {
                              case "狗狗":
                                myPet.setType("狗狗");
                                prefs.setString('keyPetType', '狗狗');
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.dogBreeds);
                                introImagePathByAssets =
                                    'assets/images/default_dog.png';
                                break;
                              case "貓咪":
                                myPet.setType("貓咪");
                                prefs.setString('keyPetType', '貓咪');
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.catBreeds);
                                introImagePathByAssets =
                                    'assets/images/default_cat.png';
                                break;
                              case "兔子":
                                myPet.setType("兔子");
                                prefs.setString('keyPetType', '兔子');
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.rabbitBreeds);
                                introImagePathByAssets =
                                    'assets/images/default_rabbit.png';
                                break;
                              case "烏龜":
                                myPet.setType("烏龜");
                                prefs.setString('keyPetType', '烏龜');
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.turtleBreeds);
                                introImagePathByAssets =
                                    'assets/images/default_turtle.png';
                                break;
                              case "其他":
                                AllDataModel.defaultBreeds.add("自行輸入");
                                introImagePathByAssets =
                                    'assets/images/default_image.png';
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('自行輸入寵物類型'),
                                        actions: <Widget>[
                                          TextFormField(
                                            controller: introTypeController,
                                            decoration: const InputDecoration(
                                              prefixIcon:
                                                  const Icon(Icons.pets),
                                              hintText: '請輸入寵物的類型',
                                            ),
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'Cancel'),
                                                  child: const Text(
                                                    '取消',
                                                    style: TextStyle(
                                                        color: ColorSet
                                                            .primaryColorsGreenOfOpacity80),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, 'OK');
                                                    setState(() {
                                                      prefs.setString(
                                                          'keyPetType',
                                                          introTypeController
                                                              .text);
                                                      myPet.setType(
                                                          introTypeController
                                                              .text);
                                                    });
                                                  },
                                                  child: const Text(
                                                    '確定',
                                                    style: TextStyle(
                                                        color: ColorSet
                                                            .primaryColorsGreenOfOpacity80),
                                                  ),
                                                ),
                                              ]),
                                        ],
                                      );
                                    });
                                break;
                              default:
                                print('something went wrong.');
                              /**/
                            }
                            AllDataModel.petBreeds = null;
                          },
                          items: <String>['狗狗', '貓咪', '兔子', '烏龜', '其他']
                              .map<DropdownMenuItem<String>>((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: new Text(type),
                            );
                          }).toList(),
                          hint: const Text(
                            "請選擇",
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 70.0),
                Text(
                  '您的寵物品種：${myPet.getBreeds}',
                  textAlign: TextAlign.center,
                  style: _titleStyle,
                ),
                const SizedBox(height: 25.0),
                Container(
                  width: 250.0,
                  height: 40.0,
                  alignment: Alignment.center,
                  decoration: _containerOfDropdownButtonDeco,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration.collapsed(hintText: ''),
                        icon: Icon(Icons.keyboard_arrow_down_outlined),
                        iconSize: 30.0,
                        iconEnabledColor:
                            ColorSet.primaryColorsGreenOfOpacity80,
                        iconDisabledColor: ColorSet.colorsWhiteGrayOfOpacity80,
                        hint: const Text(
                          "請選擇",
                        ),
                        value: AllDataModel.petBreeds,
                        isExpanded: true,
                        onChanged: (String? value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString(
                              'keyPetBreeds', value.toString());
                          setState(() {
                            AllDataModel.petBreeds = value;
                            myPet.setBreeds(value.toString());
                          });
                          switch (value) {
                            case "自行輸入":
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('自行輸入寵物品種'),
                                      actions: <Widget>[
                                        TextFormField(
                                          controller: introBreedsController,
                                          decoration: const InputDecoration(
                                            prefixIcon: const Icon(Icons.pets),
                                            hintText: '請輸入寵物的品種',
                                          ),
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'Cancel'),
                                                child: const Text(
                                                  '取消',
                                                  style: TextStyle(
                                                    color: ColorSet
                                                        .primaryColorsGreenOfOpacity80,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await prefs.setString(
                                                      'keyPetBreeds',
                                                      introBreedsController
                                                          .text);
                                                  Navigator.pop(context, 'OK');
                                                  setState(() {
                                                    myPet.setBreeds(
                                                        introBreedsController
                                                            .text);
                                                  });
                                                },
                                                child: const Text(
                                                  '確定',
                                                  style: TextStyle(
                                                      color: ColorSet
                                                          .primaryColorsGreenOfOpacity80),
                                                ),
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
                        items: AllDataModel.defaultBreeds
                            .map<DropdownMenuItem<String>>((breeds) {
                          return DropdownMenuItem<String>(
                            value: breeds,
                            child: new Text(breeds),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /* Page 3: Set Pet Information */
        Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  '基本資料',
                  textAlign: TextAlign.center,
                  style: _titleStyle,
                ),
                const SizedBox(height: 15.0),
                Container(
                  width: 125.0,
                  height: 125.0,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: ColorSet.colorsBlackOfOpacity80, width: 3.0),
                      borderRadius: ForAllTheme.allRadius,
                    ),
                  ),
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: introImageByFile != null
                          ? Image.file(
                              File(introImageByFile.path),
                              fit: BoxFit.fill,
                              width: 125.0,
                              height: 125.0,
                            )
                          : Image.asset(
                              introImagePathByAssets,
                              fit: BoxFit.fill,
                              width: 125.0,
                              height: 125.0,
                            ),
                    ),
                    onTap: () {
                      // pick pet image on phone
                      _pickImage();
                    },
                  ),
                ),
                const SizedBox(height: 25.0),
                Container(
                  width: 300.0,
                  height: 45.0,
                  padding: EdgeInsets.only(
                    left: 25.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: ForAllTheme.allRadius,
                    color: ColorSet.primaryColorsGreenOfOpacity80,
                    boxShadow: _boxShadow,
                  ),
                  child: TextField(
                    style: TextStyle(
                      color: ColorSet.colorsWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    textAlignVertical: TextAlignVertical.center,
                    focusNode: introNameFocusNode,
                    cursorColor: ColorSet.colorsWhite,
                    controller: introNameController,
                    onEditingComplete: () {
                      introNameFocusNode.unfocus();
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Text(
                        '輸入寵物姓名',
                        style: TextStyle(
                            color: ColorSet.colorsWhite,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 0, minHeight: 0),
                      contentPadding: EdgeInsets.only(
                        bottom: 10.0,
                        right: 35.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: 300.0,
                  height: 45.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: ForAllTheme.allRadius,
                    color: ColorSet.primaryColorsGreenOfOpacity80,
                    boxShadow: _boxShadow,
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            '選擇性別',
                            style: TextStyle(
                                color: ColorSet.colorsWhite,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          ToggleSwitch(
                            minWidth: 30.0,
                            minHeight: 20.0,
                            initialLabelIndex: introGenderIndex,
                            cornerRadius: 20.0,
                            inactiveBgColor: ColorSet.colorsWhite,
                            borderColor: [Colors.white],
                            borderWidth: 2.0,
                            totalSwitches: 2,
                            fontSize: 15.0,
                            customTextStyles: [
                              TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorSet.colorsWhite,
                              ),
                              TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorSet.colorsWhite,
                              ),
                            ],
                            labels: ['公', '母'],
                            activeBgColors: [
                              [ColorSet.colorsDarkBlueGreenOfOpacity80],
                              [ColorSet.colorsDarkBlueGreenOfOpacity80]
                            ],
                            onToggle: (index) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              switch (index) {
                                case 0:
                                  introGenderIndex = 0;
                                  myPet.setGender('公');
                                  await prefs.setString('keyPetGender', '公');
                                  break;
                                case 1:
                                  introGenderIndex = 1;
                                  myPet.setGender('母');
                                  await prefs.setString('keyPetGender', '母');
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: 300.0,
                  height: 45.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: ForAllTheme.allRadius,
                    color: ColorSet.primaryColorsGreenOfOpacity80,
                    boxShadow: _boxShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      const Text(
                        '年齡/生日',
                        style: TextStyle(
                            color: ColorSet.colorsWhite,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Switch(
                          value: introIsExactDate,
                          inactiveThumbColor:
                              ColorSet.colorsWhiteGrayOfOpacity80,
                          inactiveTrackColor: ColorSet.colorsWhite,
                          activeColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                          activeTrackColor: ColorSet.colorsWhite,
                          onChanged: (value) {
                            setState(() {
                              introIsExactDate = value;
                            });
                            /* Reset value while switch on changed */
                            if (introIsExactDate == false) {
                              introAgeController.text = '';
                            } else {
                              myPet.setBirthday(formattedDate
                                  .format(DateTime.now())
                                  .toString());
                            }
                          }),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: 300.0,
                  height: 45.0,
                  padding: EdgeInsets.only(
                    left: 25.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: ForAllTheme.allRadius,
                    color: ColorSet.primaryColorsGreenOfOpacity80,
                    boxShadow: _boxShadow,
                  ),
                  child: introIsExactDate == true
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: const Text(
                                '選擇生日',
                                style: TextStyle(
                                    color: ColorSet.colorsWhite,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0),
                              ),
                            ),
                            Expanded(
                              child: Tooltip(
                                message: '選擇日期',
                                child: TextButton(
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
                                        await prefs.setString('keyPetAge',
                                            birthdayAge.toString());
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
                                  child: Text(
                                    myPet.getBirthday == ''
                                        ? formattedDate
                                            .format(DateTime.now())
                                            .toString()
                                        : myPet.getBirthday,
                                    style: TextStyle(
                                      color: ColorSet.colorsWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : TextField(
                          style: TextStyle(
                            color: ColorSet.colorsWhite,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          focusNode: introDateFocusNode,
                          cursorColor: ColorSet.colorsWhite,
                          controller: introAgeController,
                          onEditingComplete: () {
                            introDateFocusNode.unfocus();
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Text(
                              '輸入年齡',
                              style: TextStyle(
                                  color: ColorSet.colorsWhite,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0),
                            ),
                            prefixIconConstraints:
                                BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixText: '歲',
                            suffixStyle: TextStyle(
                                color: ColorSet.colorsWhite,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0),
                            contentPadding: EdgeInsets.only(
                              bottom: 10.0,
                              right: 35.0,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: 300.0,
                  height: 45.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: ForAllTheme.allRadius,
                    color: ColorSet.primaryColorsGreenOfOpacity80,
                    boxShadow: _boxShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      const Text(
                        '是否結紮',
                        style: TextStyle(
                            color: ColorSet.colorsWhite,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Switch(
                        value: introIsNeutered,
                        inactiveThumbColor: ColorSet.colorsWhiteGrayOfOpacity80,
                        inactiveTrackColor: ColorSet.colorsWhite,
                        activeColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                        activeTrackColor: ColorSet.colorsWhite,
                        onChanged: (value) {
                          setState(() {
                            introIsNeutered = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      isTopSafeArea: true,
      isBottomSafeArea: true,

      /* Skip Button */
      skip: const Tooltip(
        message: '跳過初始設定',
        child: const Text(
          '略過',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      showSkipButton: true,
      skipFlex: 1,

      /* Next Button */
      next: Container(
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        decoration: BoxDecoration(
          color: ColorSet.primaryColorsGreenOfOpacity80,
          borderRadius: ForAllTheme.allRadius,
          boxShadow: _boxShadow,
        ),
        child: const Text(
          '下一頁',
          style: TextStyle(
              color: ColorSet.colorsWhite, fontWeight: FontWeight.bold),
        ),
      ),
      showNextButton: true,
      nextFlex: 1,

      /* Done Button */
      done: Container(
        padding: EdgeInsets.fromLTRB(17.0, 5.0, 17.0, 5.0),
        decoration: BoxDecoration(
          color: ColorSet.primaryColorsGreenOfOpacity80,
          borderRadius: ForAllTheme.allRadius,
          boxShadow: _boxShadow,
        ),
        child: const Text(
          '完成',
          style: TextStyle(
              color: ColorSet.colorsWhite, fontWeight: FontWeight.bold),
        ),
      ),
      onDone: () => _onIntroEnd(context),

      /* controls/dots */
      controlsMargin: const EdgeInsets.fromLTRB(10.0, 10.0, 35.0, 10.0),
      color: ColorSet.colorsBlackOfOpacity80,
      dotsDecorator: const DotsDecorator(
        size: const Size(10.0, 10.0),
        color: ColorSet.colorsWhiteGrayOfOpacity80,
        activeColor: ColorSet.primaryColorsGreenOfOpacity80,
      ),
      dotsFlex: 1,
    );
  }
}
