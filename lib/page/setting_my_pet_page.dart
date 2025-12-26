import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/common/background_painter.dart';
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dateTimePicker;

class SettingMyPetPage extends StatefulWidget {
  SettingMyPetPage({Key? key}) : super(key: key);
  @override
  _SettingMyPetPageState createState() => _SettingMyPetPageState();
}

class _SettingMyPetPageState extends State<SettingMyPetPage> {
  bool settingPageIsNeutered = false;
  bool setIsExactDate = false;
  final formattedDate = DateFormat('yyyy-MM-dd');
  var settingPageImageByFile;
  String settingPageType = '';
  String settingPageBreeds = '';
  String settingPageImagePathByAssets = 'assets/images/default_image.png';
  String settingPageGender = '公';
  String settingPageBirthday =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  int settingPageAge = 0;

  FocusNode setNameFocusNode = new FocusNode();
  FocusNode setDateFocusNode = new FocusNode();
  FocusNode settingPageTypeFocusNode = new FocusNode();
  FocusNode settingPageBreedsFocusNode = new FocusNode();
  TextEditingController setTypeController = TextEditingController();
  TextEditingController setBreedsController = TextEditingController();
  TextEditingController setNameController = TextEditingController();
  TextEditingController setAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  _loadData(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString('keyPetImagePathByAssets') != '') {
        settingPageImagePathByAssets =
            prefs.getString('keyPetImagePathByAssets') ?? '';
      }
      if (prefs.getString('keyPetImagePathByFile') != '') {
        settingPageImageByFile =
            File(prefs.getString('keyPetImagePathByFile') ?? '');
      }

      if (prefs.getString('keyPetType') == '') {
        settingPageType = '請選擇';
      } else {
        settingPageType = prefs.getString('keyPetType') ?? '';
        setTypeController.text = prefs.getString('keyPetType') ?? '';
      }

      if (prefs.getString('keyPetBreeds') == '') {
        settingPageBreeds = '請選擇';
      } else {
        settingPageBreeds = prefs.getString('keyPetBreeds') ?? '';
        setBreedsController.text = prefs.getString('keyPetBreeds') ?? '';
      }

      settingPageGender = prefs.getString('keyPetGender') ?? '公';
      settingPageBirthday = prefs.getString('keyPetBirthday') ?? '未設定';

      settingPageIsNeutered = prefs.getBool('keyIsNeutered') ?? false;
      setIsExactDate = prefs.getBool('keyIsExactDate') ?? false;

      if (prefs.getString('keyPetName') == '未設定') {
        setNameController.text = '';
      } else {
        setNameController.text = prefs.getString('keyPetName') ?? '';
      }

      setAgeController.text = (prefs.getInt('keyPetAge') ?? 0).toString();
    });
  }

  /* Clean up the controller and focus node when the widget is disposed */
  @override
  void dispose() {
    setTypeController.dispose();
    setBreedsController.dispose();
    setNameController.dispose();
    setAgeController.dispose();
    setNameFocusNode.dispose();
    setDateFocusNode.dispose();
    settingPageTypeFocusNode.dispose();
    settingPageBreedsFocusNode.dispose();
    super.dispose();
  }

  /* Save info when user click confirm button */
  void _confirmChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save image depends on user select photo or default image
    if (settingPageImagePathByAssets != '') {
      await prefs.setString(
          'keyPetImagePathByAssets', settingPageImagePathByAssets);
    }
    if (settingPageImageByFile != null) {
      await prefs.setString(
          'keyPetImagePathByFile', settingPageImageByFile.path);
    }

    // Save pet name
    if (setNameController.text != '') {
      await prefs.setString('keyPetName', setNameController.text);
    } else {
      await prefs.setString('keyPetName', '未設定');
    }

    // Save pet type
    await prefs.setString('keyPetType', settingPageType);
    // Save pet breeds
    await prefs.setString('keyPetBreeds', settingPageBreeds);
    // Save user choose input age or select date
    await prefs.setBool('keyIsExactDate', setIsExactDate);
    // Save is neutered or not
    await prefs.setBool('keyIsNeutered', settingPageIsNeutered);

    // Save pet gender
    if (settingPageGender == '公') {
      await prefs.setString('keyPetGender', '公');
    } else {
      await prefs.setString('keyPetGender', '母');
    }

    // User doesn't know exact date
    if (setIsExactDate == false) {
      // User doesn't input age
      if (setAgeController.text == '') {
        await prefs.setInt('keyPetAge', 0);
      } else {
        await prefs.setInt('keyPetAge', int.parse(setAgeController.text));
      }
    }
    // User know exact date
    else {
      // User doesn't choose date
      if (settingPageBirthday ==
          formattedDate.format(DateTime.now()).toString()) {
        await prefs.setInt('keyPetAge', 0);
        await prefs.setString(
            'keyPetBirthday', formattedDate.format(DateTime.now()).toString());
      } else {
        await prefs.setInt('keyPetAge', settingPageAge);
        await prefs.setString('keyPetBirthday', settingPageBirthday);
      }
    }

    Navigator.of(context).pop();

    Fluttertoast.showToast(
        msg: "修改完成!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: ColorSet.colorsWhite,
        textColor: ColorSet.colorsBlackOfOpacity80,
        fontSize: 16.0);
  }

  /* Select Pet Image On User Device */
  Future<Null> _pickImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      settingPageImageByFile = pickedImage;
    });

    // If image selected, then go to crop image
    if (pickedImage != null) {
      settingPageImagePathByAssets = '';
      prefs.setString('keyPetImagePathByAssets', '');
      // DEFER: Need to fix toolbar problem
      // _cropImage();
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

  // DEFER: Need to fix toolbar problem
  /*
  /* Crop Pet Image By User Selected */
  Future<Null> _cropImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: settingPageImageByFile.path,
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
      settingPageImageByFile = croppedFile;
    });
    settingPageImagePathByAssets = '';
    prefs.setString('keyPetImagePathByAssets', '');
  }

   */

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
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 50.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    '設定',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: ColorSet.colorsBlackOfOpacity80,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 600.0,
                          child: Card(
                            color: ColorSet.primaryColorsGreenOfOpacity80,
                            margin: EdgeInsets.only(
                                right: 22.0, top: 55.0, bottom: 17.0),
                            shape: MyCardTheme.cardsForLeftShapeBorder,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300.0,
                        height: 600.0,
                        child: Stack(
                          children: <Widget>[
                            Card(
                              color: ColorSet.primaryColorsGreenOfOpacity80,
                              margin: EdgeInsets.only(top: 55.0, bottom: 17.0),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    25.0, 25.0, 25.0, 65.0),
                                child: Stack(
                                  children: <Widget>[
                                    SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            '編輯基本資料',
                                            style: TextStyle(
                                              letterSpacing: 1.0,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w500,
                                              color: ColorSet
                                                  .colorsBlackOfOpacity80,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 35.0,
                                          ),
                                          Container(
                                            width: 125.0,
                                            height: 125.0,
                                            alignment: Alignment.center,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                    width: 3.0),
                                                borderRadius:
                                                    ForAllTheme.allRadius,
                                              ),
                                            ),
                                            child: GestureDetector(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(7.0),
                                                child: settingPageImageByFile !=
                                                        null
                                                    ? Image.file(
                                                        File(
                                                            settingPageImageByFile
                                                                .path),
                                                        fit: BoxFit.fill,
                                                        width: 125.0,
                                                        height: 125.0)
                                                    : Image.asset(
                                                        settingPageImagePathByAssets,
                                                        fit: BoxFit.fill,
                                                        width: 125.0,
                                                        height: 125.0),
                                              ),
                                              onTap: () {
                                                // pick pet image on phone
                                                _pickImage();
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 15.0),
                                          Container(
                                            width: 250.0,
                                            height: 40.0,
                                            alignment: Alignment.center,
                                            decoration: ShapeDecoration(
                                                color: ColorSet
                                                    .colorsWhiteGrayOfOpacity80,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                            child: DropdownButtonHideUnderline(
                                              child: ButtonTheme(
                                                alignedDropdown: true,
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 5.0,
                                                  ),
                                                  menuMaxHeight: 250.0,
                                                  decoration:
                                                      InputDecoration.collapsed(
                                                          hintText: ''),
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_down_outlined),
                                                  iconSize: 30.0,
                                                  iconEnabledColor: ColorSet
                                                      .colorsDarkBlueGreenOfOpacity80,
                                                  isExpanded: true,
                                                  initialValue:
                                                      AllDataModel.petType,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      AllDataModel.petType =
                                                          value;
                                                      // Reset breeds content
                                                      settingPageBreeds = '請選擇';
                                                      // Clear breeds list
                                                      AllDataModel.defaultBreeds
                                                          .clear();
                                                    });
                                                    // Set image path to null for using default image
                                                    settingPageImageByFile =
                                                        null;
                                                    // Change breeds list and default image by select different type
                                                    switch (
                                                        AllDataModel.petType) {
                                                      case "狗狗":
                                                        settingPageType = '狗狗';
                                                        AllDataModel
                                                            .defaultBreeds
                                                            .addAll(AllDataModel
                                                                .dogBreeds);
                                                        settingPageImagePathByAssets =
                                                            'assets/images/default_dog.png';
                                                        break;
                                                      case "貓咪":
                                                        settingPageType = '貓咪';
                                                        AllDataModel
                                                            .defaultBreeds
                                                            .addAll(AllDataModel
                                                                .catBreeds);
                                                        settingPageImagePathByAssets =
                                                            'assets/images/default_cat.png';
                                                        break;
                                                      case "兔子":
                                                        settingPageType = '兔子';
                                                        AllDataModel
                                                            .defaultBreeds
                                                            .addAll(AllDataModel
                                                                .rabbitBreeds);
                                                        settingPageImagePathByAssets =
                                                            'assets/images/default_rabbit.png';
                                                        break;
                                                      case "烏龜":
                                                        settingPageType = '烏龜';
                                                        AllDataModel
                                                            .defaultBreeds
                                                            .addAll(AllDataModel
                                                                .turtleBreeds);
                                                        settingPageImagePathByAssets =
                                                            'assets/images/default_turtle.png';
                                                        break;
                                                      case "其他":
                                                        AllDataModel
                                                            .defaultBreeds
                                                            .add("其他");
                                                        settingPageImagePathByAssets =
                                                            'assets/images/default_image.png';
                                                        // Show dialog for user to input custom type
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      const Text(
                                                                        '其他',
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ColorSet.colorsBlackOfOpacity80,
                                                                          fontSize:
                                                                              17.0,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            30.0,
                                                                      ),
                                                                      TextField(
                                                                        style: MyDialogTheme
                                                                            .dialogContentStyle,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        textAlignVertical:
                                                                            TextAlignVertical.center,
                                                                        controller:
                                                                            setTypeController,
                                                                        focusNode:
                                                                            settingPageTypeFocusNode,
                                                                        cursorColor:
                                                                            ColorSet.primaryColorsGreenOfOpacity80,
                                                                        onEditingComplete:
                                                                            () {
                                                                          settingPageTypeFocusNode
                                                                              .unfocus();
                                                                        },
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          border:
                                                                              InputBorder.none,
                                                                          hintText:
                                                                              '請自行輸入寵物類型',
                                                                          hintStyle:
                                                                              const TextStyle(color: ColorSet.colorsGrayOfOpacity80),
                                                                        ),
                                                                      ),
                                                                      const Divider(),
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: <Widget>[
                                                                  Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: <Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            // If user doesn't input custom type, then set no content
                                                                            settingPageType =
                                                                                '';
                                                                            Navigator.pop(context,
                                                                                'Cancel');
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            '取消',
                                                                            style: const TextStyle(
                                                                                color: ColorSet.colorsGrayOfOpacity80,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 13.0,
                                                                                letterSpacing: 2.0),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              34.0,
                                                                          width:
                                                                              50.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.rectangle,
                                                                            borderRadius:
                                                                                ForAllTheme.allRadius,
                                                                            color:
                                                                                ColorSet.primaryColorsGreenOfOpacity80,
                                                                          ),
                                                                          child:
                                                                              TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context, 'OK');
                                                                              setState(() {
                                                                                settingPageType = setTypeController.text;
                                                                              });
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              '完成',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(color: ColorSet.colorsWhite, fontWeight: FontWeight.bold, fontSize: 13.0, letterSpacing: 2.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ],
                                                              );
                                                            });
                                                        break;
                                                      default:
                                                        AllDataModel
                                                            .defaultBreeds
                                                            .clear();
                                                        break;
                                                    }
                                                    AllDataModel.petBreeds =
                                                        null;
                                                  },
                                                  items: <String>[
                                                    '狗狗',
                                                    '貓咪',
                                                    '兔子',
                                                    '烏龜',
                                                    '其他'
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String type) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: type,
                                                      child: new Text(
                                                        type,
                                                        style: TextStyle(
                                                          color: ColorSet
                                                              .colorsBlackOfOpacity80,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  hint: Text(
                                                    settingPageType,
                                                    style: TextStyle(
                                                      color: ColorSet
                                                          .colorsBlackOfOpacity80,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15.0),
                                          Container(
                                            width: 250.0,
                                            height: 40.0,
                                            alignment: Alignment.center,
                                            decoration: ShapeDecoration(
                                              color: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    ForAllTheme.allRadius,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: ButtonTheme(
                                                alignedDropdown: true,
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 5.0,
                                                  ),
                                                  menuMaxHeight: 250.0,
                                                  decoration:
                                                      InputDecoration.collapsed(
                                                          hintText: ''),
                                                  icon: const Icon(Icons
                                                      .keyboard_arrow_down_outlined),
                                                  iconSize: 30.0,
                                                  iconEnabledColor: ColorSet
                                                      .colorsDarkBlueGreenOfOpacity80,
                                                  hint: Text(
                                                    settingPageBreeds,
                                                    style: TextStyle(
                                                      color: ColorSet
                                                          .colorsBlackOfOpacity80,
                                                    ),
                                                  ),
                                                  initialValue:
                                                      AllDataModel.petBreeds,
                                                  isExpanded: true,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      AllDataModel.petBreeds =
                                                          value;
                                                      settingPageBreeds =
                                                          value.toString();
                                                    });
                                                    switch (value) {
                                                      case "其他":
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              // Show dialog for user to input custom breeds
                                                              return AlertDialog(
                                                                content:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      const Text(
                                                                        '其他',
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ColorSet.colorsBlackOfOpacity80,
                                                                          fontSize:
                                                                              17.0,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            30.0,
                                                                      ),
                                                                      TextFormField(
                                                                        style: MyDialogTheme
                                                                            .dialogContentStyle,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        textAlignVertical:
                                                                            TextAlignVertical.center,
                                                                        controller:
                                                                            setBreedsController,
                                                                        focusNode:
                                                                            settingPageBreedsFocusNode,
                                                                        cursorColor:
                                                                            ColorSet.primaryColorsGreenOfOpacity80,
                                                                        onEditingComplete:
                                                                            () {
                                                                          settingPageBreedsFocusNode
                                                                              .unfocus();
                                                                        },
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          border:
                                                                              InputBorder.none,
                                                                          hintText:
                                                                              '請自行輸入寵物品種',
                                                                          hintStyle:
                                                                              const TextStyle(color: ColorSet.colorsGrayOfOpacity80),
                                                                        ),
                                                                      ),
                                                                      const Divider(),
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: <Widget>[
                                                                  Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: <Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            settingPageBreeds =
                                                                                '';
                                                                            Navigator.pop(context,
                                                                                'Cancel');
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            '取消',
                                                                            style: const TextStyle(
                                                                                color: ColorSet.colorsGrayOfOpacity80,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 13.0,
                                                                                letterSpacing: 2.0),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              34.0,
                                                                          width:
                                                                              50.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.rectangle,
                                                                            borderRadius:
                                                                                ForAllTheme.allRadius,
                                                                            color:
                                                                                ColorSet.primaryColorsGreenOfOpacity80,
                                                                          ),
                                                                          child:
                                                                              TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              settingPageBreeds = '';
                                                                              Navigator.pop(context, 'OK');
                                                                              setState(() {
                                                                                settingPageBreeds = setBreedsController.text;
                                                                              });
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              '完成',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(color: ColorSet.colorsWhite, fontWeight: FontWeight.bold, fontSize: 13.0, letterSpacing: 2.0),
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
                                                  items: AllDataModel
                                                      .defaultBreeds
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (breeds) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: breeds,
                                                      child: new Text(
                                                        breeds,
                                                        style: TextStyle(
                                                          color: ColorSet
                                                              .colorsBlackOfOpacity80,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15.0),
                                          Container(
                                            width: 250.0,
                                            height: 40.0,
                                            padding: const EdgeInsets.only(
                                              left: 15.0,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  ForAllTheme.allRadius,
                                              color: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: ColorSet
                                                    .colorsBlackOfOpacity80,
                                              ),
                                              textAlign: TextAlign.end,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              focusNode: setNameFocusNode,
                                              cursorColor: ColorSet
                                                  .colorsBlackOfOpacity80,
                                              controller: setNameController,
                                              onEditingComplete: () {
                                                setNameFocusNode.unfocus();
                                              },
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                prefixIcon: const Text(
                                                  '輸入寵物姓名',
                                                  style: const TextStyle(
                                                      color: ColorSet
                                                          .colorsBlackOfOpacity80,
                                                      fontSize: 17.0,
                                                      letterSpacing: 2.0),
                                                ),
                                                prefixIconConstraints:
                                                    const BoxConstraints(
                                                        minWidth: 0,
                                                        minHeight: 0),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                  bottom: 10.0,
                                                  right: 35.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15.0),
                                          Container(
                                            width: 250.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  ForAllTheme.allRadius,
                                              color: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                const Text(
                                                  '選擇性別',
                                                  style: const TextStyle(
                                                      color: ColorSet
                                                          .colorsBlackOfOpacity80,
                                                      fontSize: 17.0,
                                                      letterSpacing: 2.0),
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                ToggleSwitch(
                                                  minWidth: 30.0,
                                                  minHeight: 20.0,
                                                  initialLabelIndex:
                                                      settingPageGender == '公'
                                                          ? 0
                                                          : 1,
                                                  cornerRadius: 20.0,
                                                  inactiveBgColor:
                                                      ColorSet.colorsWhite,
                                                  borderColor: [
                                                    ColorSet.colorsWhite,
                                                  ],
                                                  borderWidth: 2.0,
                                                  totalSwitches: 2,
                                                  fontSize: 15.0,
                                                  customTextStyles: [
                                                    const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          ColorSet.colorsWhite,
                                                    ),
                                                    const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          ColorSet.colorsWhite,
                                                    ),
                                                  ],
                                                  labels: ['公', '母'],
                                                  activeBgColors: [
                                                    [
                                                      ColorSet
                                                          .colorsDarkBlueGreenOfOpacity80
                                                    ],
                                                    [
                                                      ColorSet
                                                          .colorsDarkBlueGreenOfOpacity80
                                                    ]
                                                  ],
                                                  onToggle: (index) {
                                                    switch (index) {
                                                      case 0:
                                                        settingPageGender = '公';
                                                        break;
                                                      case 1:
                                                        settingPageGender = '母';
                                                        break;
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 15.0),
                                          Container(
                                            width: 250.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  ForAllTheme.allRadius,
                                              color: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                const Text(
                                                  '年齡/生日',
                                                  style: const TextStyle(
                                                      color: ColorSet
                                                          .colorsBlackOfOpacity80,
                                                      fontSize: 17.0,
                                                      letterSpacing: 2.0),
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                Switch(
                                                    value: setIsExactDate,
                                                    inactiveThumbColor: ColorSet
                                                        .colorsWhiteGrayOfOpacity80,
                                                    inactiveTrackColor:
                                                        ColorSet.colorsWhite,
                                                    activeThumbColor: ColorSet
                                                        .colorsDarkBlueGreenOfOpacity80,
                                                    activeTrackColor:
                                                        ColorSet.colorsWhite,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        setIsExactDate = value;
                                                      });
                                                      /* Reset value while switch on changed */
                                                      if (setIsExactDate ==
                                                          false) {
                                                        setAgeController.text =
                                                            '';
                                                      } else {
                                                        settingPageBirthday =
                                                            formattedDate
                                                                .format(DateTime
                                                                    .now())
                                                                .toString();
                                                      }
                                                    }),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 15.0),
                                          Container(
                                            width: 250.0,
                                            height: 40.0,
                                            padding: const EdgeInsets.only(
                                              left: 15.0,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  ForAllTheme.allRadius,
                                              color: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                            ),
                                            child: setIsExactDate == true
                                                ? Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: const Text(
                                                          '選擇生日',
                                                          style: const TextStyle(
                                                              color: ColorSet
                                                                  .colorsBlackOfOpacity80,
                                                              fontSize: 17.0,
                                                              letterSpacing:
                                                                  2.0),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Tooltip(
                                                          message: '選擇日期',
                                                          child: TextButton(
                                                            onPressed: () {
                                                              dateTimePicker
                                                                      .DatePicker
                                                                  .showDatePicker(
                                                                context,
                                                                currentTime:
                                                                    DateTime
                                                                        .now(),
                                                                locale:
                                                                    dateTimePicker
                                                                        .LocaleType
                                                                        .tw,
                                                                showTitleActions:
                                                                    true,
                                                                minTime:
                                                                    DateTime(
                                                                        1971,
                                                                        1,
                                                                        1),
                                                                maxTime:
                                                                    DateTime(
                                                                        2030,
                                                                        12,
                                                                        31),
                                                                onConfirm:
                                                                    (date) {
                                                                  settingPageAge =
                                                                      DateTime.now()
                                                                              .year -
                                                                          date.year;
                                                                  setState(() {
                                                                    settingPageBirthday =
                                                                        formattedDate
                                                                            .format(date);
                                                                  });
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                              settingPageBirthday,
                                                              style:
                                                                  const TextStyle(
                                                                color: ColorSet
                                                                    .colorsBlackOfOpacity80,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : TextField(
                                                    style: const TextStyle(
                                                      color: ColorSet
                                                          .colorsBlackOfOpacity80,
                                                    ),
                                                    textAlign: TextAlign.end,
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    focusNode: setDateFocusNode,
                                                    cursorColor: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                    controller:
                                                        setAgeController,
                                                    onEditingComplete: () {
                                                      setDateFocusNode
                                                          .unfocus();
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      prefixIcon: const Text(
                                                        '輸入年齡',
                                                        style: const TextStyle(
                                                            color: ColorSet
                                                                .colorsBlackOfOpacity80,
                                                            fontSize: 17.0,
                                                            letterSpacing: 2.0),
                                                      ),
                                                      prefixIconConstraints:
                                                          const BoxConstraints(
                                                              minWidth: 0,
                                                              minHeight: 0),
                                                      suffixText: '歲',
                                                      suffixStyle: const TextStyle(
                                                          color: ColorSet
                                                              .colorsBlackOfOpacity80,
                                                          fontSize: 17.0,
                                                          letterSpacing: 2.0),
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                        bottom: 10.0,
                                                        right: 35.0,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 15.0),
                                          Container(
                                            width: 250.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  ForAllTheme.allRadius,
                                              color: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                const Text(
                                                  '是否結紮',
                                                  style: const TextStyle(
                                                      color: ColorSet
                                                          .colorsBlackOfOpacity80,
                                                      fontSize: 17.0,
                                                      letterSpacing: 2.0),
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                Switch(
                                                  value: settingPageIsNeutered,
                                                  inactiveThumbColor: ColorSet
                                                      .colorsWhiteGrayOfOpacity80,
                                                  inactiveTrackColor:
                                                      ColorSet.colorsWhite,
                                                  activeThumbColor: ColorSet
                                                      .colorsDarkBlueGreenOfOpacity80,
                                                  activeTrackColor:
                                                      ColorSet.colorsWhite,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      settingPageIsNeutered =
                                                          value;
                                                    });
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20.0,
                              bottom: 27.0,
                              child: Row(
                                children: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      '取消',
                                      style: const TextStyle(
                                          color: ColorSet.colorsWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0,
                                          letterSpacing: 2.0),
                                    ),
                                  ),
                                  Container(
                                    height: 34.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: ForAllTheme.allRadius,
                                      color: ColorSet
                                          .colorsDarkBlueGreenOfOpacity80,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        _confirmChanges();
                                      },
                                      child: const Text(
                                        '完成',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: ColorSet.colorsWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                            letterSpacing: 2.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 600.0,
                          child: Card(
                            color: ColorSet.primaryColorsGreenOfOpacity80,
                            margin: const EdgeInsets.only(
                                left: 22.0, top: 55.0, bottom: 17.0),
                            shape: MyCardTheme.cardsForRightShapeBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
