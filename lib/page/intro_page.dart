import 'dart:core';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dateTimePicker;

class IntroPage extends StatefulWidget {
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int introPageGenderIndex = 0;
  int introPageAge = 0;
  bool introPageIsNeutered = false;
  bool introPageIsExactDate = false;
  final formattedDate = DateFormat('yyyy-MM-dd');
  var introPageImageByFile;
  String introPageImagePathByAssets = 'assets/images/default_image.png';
  String introPageType = '';
  String introPageBreeds = '';
  String introPageBirthday =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

  FocusNode introPageNameFocusNode = new FocusNode();
  FocusNode introPageDateFocusNode = new FocusNode();
  FocusNode introPageTypeFocusNode = new FocusNode();
  FocusNode introPageBreedsFocusNode = new FocusNode();

  TextEditingController introPageTypeController = TextEditingController();
  TextEditingController introPageBreedsController = TextEditingController();
  TextEditingController introPageNameController = TextEditingController();
  TextEditingController introPageAgeController = TextEditingController();

  TextStyle _titleStyle = const TextStyle(
    color: ColorSet.colorsBlackOfOpacity80,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  Decoration _containerOfDropdownButtonDeco = ShapeDecoration(
    shape: RoundedRectangleBorder(
      side: const BorderSide(
          color: ColorSet.primaryColorsGreenOfOpacity80, width: 3.0),
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

  /* Clean up the controller and focus node when the widget is disposed */
  @override
  void dispose() {
    introPageTypeController.dispose();
    introPageBreedsController.dispose();
    introPageNameController.dispose();
    introPageAgeController.dispose();
    introPageNameFocusNode.dispose();
    introPageDateFocusNode.dispose();
    introPageTypeFocusNode.dispose();
    introPageBreedsFocusNode.dispose();
    super.dispose();
  }

  /* Select Pet Image On User Device */
  Future<Null> _pickImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      introPageImageByFile = pickedImage;
    });

    // If image selected, then go to crop image
    if (introPageImageByFile != null) {
      introPageImagePathByAssets = '';
      prefs.setString('keyPetImagePathByAssets', '');
      _cropImage();
    } else {
      Fluttertoast.showToast(
          msg: "您沒有選擇相片",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: ColorSet.colorsWhite,
          textColor: ColorSet.colorsBlackOfOpacity80,
          fontSize: 16.0);
    }
  }

  /* Crop Pet Image By User Selected */
  Future<Null> _cropImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: introPageImageByFile.path,
      uiSettings: [
        AndroidUiSettings(
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
      ],
    );

    // Image cropped
    setState(() {
      introPageImageByFile = croppedFile;
    });
    introPageImagePathByAssets = '';
    prefs.setString('keyPetImagePathByAssets', '');
  }

  /* Save info when end intro page */
  _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save true then intro page won't show when user open app next time
    await prefs.setBool('keyChecked', true);

    // Save image depends on user select photo or default image
    if (introPageImageByFile != null) {
      await prefs.setString('keyPetImagePathByFile', introPageImageByFile.path);
    }
    if (introPageImagePathByAssets != '') {
      await prefs.setString('keyPetImagePathByFile', '');
      await prefs.setString(
          'keyPetImagePathByAssets', introPageImagePathByAssets);
    }

    // Save pet name
    if (introPageNameController.text != '') {
      await prefs.setString('keyPetName', introPageNameController.text);
    } else {
      await prefs.setString('keyPetName', '未設定');
    }

    // Save pet type
    await prefs.setString('keyPetType', introPageType);
    // Save pet breeds
    await prefs.setString('keyPetBreeds', introPageBreeds);
    // Save user choose input age or select date
    await prefs.setBool('keyIsExactDate', introPageIsExactDate);
    // Save is neutered or not
    await prefs.setBool('keyIsNeutered', introPageIsNeutered);

    // Save pet gender
    if (introPageGenderIndex == 0) {
      await prefs.setString('keyPetGender', '公');
    } else {
      await prefs.setString('keyPetGender', '母');
    }

    // Save pet age if user have input
    if (introPageAgeController.text != '') {
      await prefs.setInt('keyPetAge', int.parse(introPageAgeController.text));
    }

    // User doesn't know exact date
    if (introPageIsExactDate == false) {
      // User doesn't input age
      if (introPageAgeController.text == '') {
        await prefs.setInt('keyPetAge', 0);
      } else {
        await prefs.setInt('keyPetAge', int.parse(introPageAgeController.text));
      }
    }
    // User know exact date
    else {
      // User doesn't choose date
      if (introPageBirthday ==
          formattedDate.format(DateTime.now()).toString()) {
        await prefs.setInt('keyPetAge', 0);
        await prefs.setString(
            'keyPetBirthday', formattedDate.format(DateTime.now()).toString());
      } else {
        await prefs.setInt('keyPetAge', introPageAge);
        await prefs.setString('keyPetBirthday', introPageBirthday);
      }
    }

    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: ColorSet.colorsWhite,
      /* All pages in IntroScreen */
      rawPages: [
        /* Page 1: Welcome Page */
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  width: 175.0,
                  height: 175.0,
                ),
                const SizedBox(
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
        ),

        /* Page 2: Select Pet Type And Breeds */
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Show type by user selected or custom input
                Text(
                  '您的寵物類型：$introPageType',
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
                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                          iconSize: 30.0,
                          iconEnabledColor:
                              ColorSet.primaryColorsGreenOfOpacity80,
                          isExpanded: true,
                          initialValue: AllDataModel.petType,
                          onChanged: (value) {
                            setState(() {
                              AllDataModel.petType = value;
                              // Reset breeds content
                              introPageBreeds = "請選擇";
                              // Clear breeds list
                              AllDataModel.defaultBreeds.clear();
                            });
                            // Set image path to null for using default image
                            introPageImageByFile = null;
                            // Change breeds list and default image by select different type
                            switch (AllDataModel.petType) {
                              case "狗狗":
                                introPageType = '狗狗';
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.dogBreeds);
                                introPageImagePathByAssets =
                                    'assets/images/default_dog.png';
                                break;
                              case "貓咪":
                                introPageType = '貓咪';
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.catBreeds);
                                introPageImagePathByAssets =
                                    'assets/images/default_cat.png';
                                break;
                              case "兔子":
                                introPageType = '兔子';
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.rabbitBreeds);
                                introPageImagePathByAssets =
                                    'assets/images/default_rabbit.png';
                                break;
                              case "烏龜":
                                introPageType = '烏龜';
                                AllDataModel.defaultBreeds
                                    .addAll(AllDataModel.turtleBreeds);
                                introPageImagePathByAssets =
                                    'assets/images/default_turtle.png';
                                break;
                              case "其他":
                                AllDataModel.defaultBreeds.add("其他");
                                introPageImagePathByAssets =
                                    'assets/images/default_image.png';
                                // Show dialog for user to input custom type
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              const Text(
                                                '其他',
                                                style: const TextStyle(
                                                  color: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 30.0,
                                              ),
                                              TextField(
                                                style: MyDialogTheme
                                                    .dialogContentStyle,
                                                textAlign: TextAlign.center,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                controller:
                                                    introPageTypeController,
                                                focusNode:
                                                    introPageTypeFocusNode,
                                                cursorColor: ColorSet
                                                    .primaryColorsGreenOfOpacity80,
                                                onEditingComplete: () {
                                                  introPageTypeFocusNode
                                                      .unfocus();
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: '請自行輸入寵物類型',
                                                  hintStyle: const TextStyle(
                                                      color: ColorSet
                                                          .colorsGrayOfOpacity80),
                                                ),
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    // If user doesn't input custom type, then set no content
                                                    introPageType = '';
                                                    Navigator.pop(
                                                        context, 'Cancel');
                                                  },
                                                  child: const Text(
                                                    '取消',
                                                    style: const TextStyle(
                                                        color: ColorSet
                                                            .colorsGrayOfOpacity80,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13.0,
                                                        letterSpacing: 2.0),
                                                  ),
                                                ),
                                                Container(
                                                  height: 34.0,
                                                  width: 50.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        ForAllTheme.allRadius,
                                                    color: ColorSet
                                                        .primaryColorsGreenOfOpacity80,
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, 'OK');
                                                      setState(() {
                                                        introPageType =
                                                            introPageTypeController
                                                                .text;
                                                      });
                                                    },
                                                    child: const Text(
                                                      '完成',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          color: ColorSet
                                                              .colorsWhite,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13.0,
                                                          letterSpacing: 2.0),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                        ],
                                      );
                                    });
                                break;
                              default:
                                AllDataModel.defaultBreeds.clear();
                                break;
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
                // Show breeds by user selected or custom input
                Text(
                  '您的寵物品種：$introPageBreeds',
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
                        icon: const Icon(Icons.keyboard_arrow_down_outlined),
                        iconSize: 30.0,
                        iconEnabledColor:
                            ColorSet.primaryColorsGreenOfOpacity80,
                        iconDisabledColor: ColorSet.colorsWhiteGrayOfOpacity80,
                        hint: const Text(
                          "請選擇",
                        ),
                        initialValue: AllDataModel.petBreeds,
                        isExpanded: true,
                        onChanged: (String? value) {
                          setState(() {
                            AllDataModel.petBreeds = value;
                            introPageBreeds = value.toString();
                          });
                          switch (value) {
                            case "其他":
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // Show dialog for user to input custom breeds
                                    return AlertDialog(
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            const Text(
                                              '其他',
                                              style: const TextStyle(
                                                color: ColorSet
                                                    .colorsBlackOfOpacity80,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30.0,
                                            ),
                                            TextFormField(
                                              style: MyDialogTheme
                                                  .dialogContentStyle,
                                              textAlign: TextAlign.center,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              controller:
                                                  introPageBreedsController,
                                              focusNode:
                                                  introPageBreedsFocusNode,
                                              cursorColor: ColorSet
                                                  .primaryColorsGreenOfOpacity80,
                                              onEditingComplete: () {
                                                introPageBreedsFocusNode
                                                    .unfocus();
                                              },
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '請自行輸入寵物品種',
                                                hintStyle: const TextStyle(
                                                    color: ColorSet
                                                        .colorsGrayOfOpacity80),
                                              ),
                                            ),
                                            const Divider(),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  introPageBreeds = '';
                                                  Navigator.pop(
                                                      context, 'Cancel');
                                                },
                                                child: const Text(
                                                  '取消',
                                                  style: const TextStyle(
                                                      color: ColorSet
                                                          .colorsGrayOfOpacity80,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.0,
                                                      letterSpacing: 2.0),
                                                ),
                                              ),
                                              Container(
                                                height: 34.0,
                                                width: 50.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius:
                                                      ForAllTheme.allRadius,
                                                  color: ColorSet
                                                      .primaryColorsGreenOfOpacity80,
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, 'OK');
                                                    setState(() {
                                                      introPageBreeds =
                                                          introPageBreedsController
                                                              .text;
                                                    });
                                                  },
                                                  child: const Text(
                                                    '完成',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: ColorSet
                                                            .colorsWhite,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13.0,
                                                        letterSpacing: 2.0),
                                                  ),
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
                      side: const BorderSide(
                          color: ColorSet.colorsBlackOfOpacity80, width: 3.0),
                      borderRadius: ForAllTheme.allRadius,
                    ),
                  ),
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: introPageImageByFile != null
                          ? Image.file(
                              File(introPageImageByFile.path),
                              fit: BoxFit.fill,
                              width: 125.0,
                              height: 125.0,
                            )
                          : Image.asset(
                              introPageImagePathByAssets,
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
                  padding: const EdgeInsets.only(
                    left: 25.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: ForAllTheme.allRadius,
                    color: ColorSet.primaryColorsGreenOfOpacity80,
                    boxShadow: _boxShadow,
                  ),
                  child: TextField(
                    style: const TextStyle(
                      color: ColorSet.colorsWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    textAlignVertical: TextAlignVertical.center,
                    focusNode: introPageNameFocusNode,
                    cursorColor: ColorSet.colorsWhite,
                    controller: introPageNameController,
                    onEditingComplete: () {
                      introPageNameFocusNode.unfocus();
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Text(
                        '輸入寵物姓名',
                        style: const TextStyle(
                            color: ColorSet.colorsWhite,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      contentPadding: const EdgeInsets.only(
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
                          const Text(
                            '選擇性別',
                            style: const TextStyle(
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
                            initialLabelIndex: introPageGenderIndex,
                            cornerRadius: 20.0,
                            inactiveBgColor: ColorSet.colorsWhite,
                            borderColor: [
                              ColorSet.colorsWhite,
                            ],
                            borderWidth: 2.0,
                            totalSwitches: 2,
                            fontSize: 15.0,
                            customTextStyles: [
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorSet.colorsWhite,
                              ),
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorSet.colorsWhite,
                              ),
                            ],
                            labels: ['公', '母'],
                            activeBgColors: [
                              [ColorSet.colorsDarkBlueGreenOfOpacity80],
                              [ColorSet.colorsDarkBlueGreenOfOpacity80]
                            ],
                            onToggle: (index) {
                              switch (index) {
                                case 0:
                                  introPageGenderIndex = 0;
                                  break;
                                case 1:
                                  introPageGenderIndex = 1;
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
                        style: const TextStyle(
                            color: ColorSet.colorsWhite,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Switch(
                          value: introPageIsExactDate,
                          inactiveThumbColor:
                              ColorSet.colorsWhiteGrayOfOpacity80,
                          inactiveTrackColor: ColorSet.colorsWhite,
                          activeThumbColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                          activeTrackColor: ColorSet.colorsWhite,
                          onChanged: (value) {
                            setState(() {
                              introPageIsExactDate = value;
                            });
                            /* Reset value while switch on changed */
                            if (introPageIsExactDate == false) {
                              introPageAgeController.text = '';
                            } else {
                              introPageBirthday = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now())
                                  .toString();
                            }
                          }),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: 300.0,
                  height: 45.0,
                  padding: const EdgeInsets.only(
                    left: 25.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: ForAllTheme.allRadius,
                    color: ColorSet.primaryColorsGreenOfOpacity80,
                    boxShadow: _boxShadow,
                  ),
                  child: introPageIsExactDate == true
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: const Text(
                                '選擇生日',
                                style: const TextStyle(
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
                                    dateTimePicker.DatePicker.showDatePicker(
                                      context,
                                      currentTime: DateTime.now(),
                                      locale: dateTimePicker.LocaleType.tw,
                                      minTime: DateTime(1971, 1, 1),
                                      maxTime: DateTime(2030, 12, 31),
                                      onConfirm: (date) {
                                        introPageAge =
                                            DateTime.now().year - date.year;
                                        setState(() {
                                          introPageBirthday =
                                              formattedDate.format(date);
                                        });
                                      },
                                    );
                                  },
                                  child: Text(
                                    introPageBirthday,
                                    style: const TextStyle(
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
                          style: const TextStyle(
                            color: ColorSet.colorsWhite,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          focusNode: introPageDateFocusNode,
                          cursorColor: ColorSet.colorsWhite,
                          controller: introPageAgeController,
                          onEditingComplete: () {
                            introPageDateFocusNode.unfocus();
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Text(
                              '輸入年齡',
                              style: const TextStyle(
                                  color: ColorSet.colorsWhite,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixText: '歲',
                            suffixStyle: const TextStyle(
                                color: ColorSet.colorsWhite,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0),
                            contentPadding: const EdgeInsets.only(
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
                        style: const TextStyle(
                            color: ColorSet.colorsWhite,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Switch(
                        value: introPageIsNeutered,
                        inactiveThumbColor: ColorSet.colorsWhiteGrayOfOpacity80,
                        inactiveTrackColor: ColorSet.colorsWhite,
                        activeThumbColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                        activeTrackColor: ColorSet.colorsWhite,
                        onChanged: (value) {
                          setState(() {
                            introPageIsNeutered = value;
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
      safeAreaList: [false, false, true, true],

      /* Skip Button */
      skip: const Tooltip(
        message: '跳過初始設定',
        child: const Text(
          '略過',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorSet.colorsBlackOfOpacity80,
          ),
        ),
      ),
      showSkipButton: true,
      skipOrBackFlex: 1,

      /* Next Button */
      next: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        decoration: BoxDecoration(
          color: ColorSet.primaryColorsGreenOfOpacity80,
          borderRadius: ForAllTheme.allRadius,
          boxShadow: _boxShadow,
        ),
        child: const Text(
          '下一頁',
          style: const TextStyle(
              color: ColorSet.colorsWhite, fontWeight: FontWeight.bold),
        ),
      ),
      showNextButton: true,
      nextFlex: 1,

      /* Done Button */
      done: Container(
        padding: const EdgeInsets.fromLTRB(17.0, 5.0, 17.0, 5.0),
        decoration: BoxDecoration(
          color: ColorSet.primaryColorsGreenOfOpacity80,
          borderRadius: ForAllTheme.allRadius,
          boxShadow: _boxShadow,
        ),
        child: const Text(
          '完成',
          style: const TextStyle(
              color: ColorSet.colorsWhite, fontWeight: FontWeight.bold),
        ),
      ),
      onDone: () => _onIntroEnd(context),

      /* controls/dots */
      controlsMargin: const EdgeInsets.fromLTRB(10.0, 10.0, 35.0, 10.0),
      // TODO: 這一行顏色被註解，因為這個方法不適用了，要看一下是哪裡改到怎麼加回來
      // color: ColorSet.colorsBlackOfOpacity80,
      dotsDecorator: const DotsDecorator(
        size: const Size(10.0, 10.0),
        color: ColorSet.colorsWhiteGrayOfOpacity80,
        activeColor: ColorSet.primaryColorsGreenOfOpacity80,
      ),
      dotsFlex: 1,
    );
  }
}
