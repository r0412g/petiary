import 'dart:io';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/common/background_painter.dart';
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/models/pet_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingMyPetPage extends StatefulWidget {
  SettingMyPetPage({Key? key}) : super(key: key);
  @override
  _SettingMyPetPageState createState() => _SettingMyPetPageState();
}

class _SettingMyPetPageState extends State<SettingMyPetPage> {
  bool setIsNeutered = false;
  bool setIsExactDate = false;
  final formattedDate = DateFormat('yyyy-MM-dd');
  var setImageByFile;
  String setImagePathByAssets = 'assets/images/default_image.png';

  FocusNode setNameFocusNode = new FocusNode();
  FocusNode setDateFocusNode = new FocusNode();
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
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    setState(() {
      if (prefs.getString('keyPetImagePathByAssets') != '') {
        setImagePathByAssets = prefs.getString('keyPetImagePathByAssets') ?? '';
      }
      if (prefs.getString('keyPetImagePathByFile') != '') {
        setImageByFile = File(prefs.getString('keyPetImagePathByFile') ?? '');
      }

      setIsNeutered = prefs.getBool('keyIsNeutered') ?? false;
      setIsExactDate = prefs.getBool('keyIsExactDate') ?? false;
      setNameController.text = myPet.getName;
      myPet.setName(prefs.getString('keyPetName') ?? '');

      setAgeController.text = myPet.getAge;
    });
  }

  /* Clean up the controller when the widget is disposed */
  @override
  void dispose() {
    setTypeController.dispose();
    setBreedsController.dispose();
    setNameController.dispose();
    setAgeController.dispose();
    super.dispose();
  }

  void _confirmChanges() async {
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (setImagePathByAssets != '') {
      await prefs.setString('keyPetImagePathByAssets', setImagePathByAssets);
    }

    if (setImageByFile != null) {
      await prefs.setString('keyPetImagePathByFile', setImageByFile.path);
    }

    myPet.setName(setNameController.text);
    await prefs.setString('keyPetName', setNameController.text);

    await prefs.setBool('keyIsNeutered', setIsNeutered);
    myPet.setIsNeutered(setIsNeutered);
    await prefs.setBool('keyIsExactDate', setIsExactDate);
    myPet.setIsExactDate(setIsExactDate);

    // User doesn't know exact date
    if (myPet.getIsExactDate == false) {
      // User doesn't enter age
      if (setAgeController.text == '') {
        myPet.setAge('0');
        await prefs.setString('keyPetAge', '0');
      } else {
        myPet.setAge(setAgeController.text);
        await prefs.setString('keyPetAge', setAgeController.text);
      }
    }

    // User doesn't know exact date
    if (myPet.getIsExactDate == true) {
      // User doesn't choose date
      if (myPet.getBirthday ==
          formattedDate.format(DateTime.now()).toString()) {
        myPet.setAge('0');
        await prefs.setString('keyPetAge', '0');
        myPet.setBirthday(formattedDate.format(DateTime.now()).toString());
        await prefs.setString(
            'keyPetBirthday', formattedDate.format(DateTime.now()).toString());
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
      setImageByFile = pickedImage;
    });

    // Image selected then save
    if (pickedImage != null) {
      setImagePathByAssets = '';
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
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: setImageByFile.path,
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
        setImageByFile = croppedFile;
      });
      setImagePathByAssets = '';
      prefs.setString('keyPetImagePathByAssets', '');
    } else {
      Fluttertoast.showToast(
          msg: "您沒有剪裁相片",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: ColorSet.colorsWhite,
          textColor: ColorSet.colorsBlackOfOpacity80,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    var myPet = Provider.of<MyPetModel>(context);

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
                              right: 22.0, top: 20.0, bottom: 17.0),
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
                            margin: EdgeInsets.only(top: 20.0, bottom: 17.0),
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
                                            color:
                                                ColorSet.colorsBlackOfOpacity80,
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
                                              child: setImageByFile != null
                                                  ? Image.file(
                                                      File(setImageByFile.path),
                                                      fit: BoxFit.fill,
                                                      width: 125.0,
                                                      height: 125.0)
                                                  : Image.asset(
                                                      setImagePathByAssets,
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
                                                decoration:
                                                    InputDecoration.collapsed(
                                                        hintText: ''),
                                                icon: Icon(Icons
                                                    .keyboard_arrow_down_outlined),
                                                iconSize: 30.0,
                                                iconEnabledColor: ColorSet
                                                    .colorsDarkBlueGreenOfOpacity80,
                                                isExpanded: true,
                                                value: AllDataModel.petType,
                                                onChanged: (value) async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  setState(() {
                                                    AllDataModel.petType =
                                                        value;
                                                    myPet.setBreeds('請選擇');
                                                  });
                                                  AllDataModel.defaultBreeds
                                                      .clear();
                                                  myPet.setBreeds('');
                                                  setImageByFile = null;
                                                  await prefs.setString(
                                                      'keyPetBreeds', '');
                                                  /* Change Breeds List By Select Different Type */
                                                  switch (
                                                      AllDataModel.petType) {
                                                    case "狗狗":
                                                      myPet.setType('狗狗');
                                                      prefs.setString(
                                                          'keyPetType', '狗狗');
                                                      AllDataModel.defaultBreeds
                                                          .addAll(AllDataModel
                                                              .dogBreeds);
                                                      setImagePathByAssets =
                                                          'assets/images/default_dog.png';
                                                      break;
                                                    case "貓咪":
                                                      myPet.setType('貓咪');
                                                      prefs.setString(
                                                          'keyPetType', '貓咪');
                                                      AllDataModel.defaultBreeds
                                                          .addAll(AllDataModel
                                                              .catBreeds);
                                                      setImagePathByAssets =
                                                          'assets/images/default_cat.png';
                                                      break;
                                                    case "兔子":
                                                      myPet.setType('兔子');
                                                      prefs.setString(
                                                          'keyPetType', '兔子');
                                                      AllDataModel.defaultBreeds
                                                          .addAll(AllDataModel
                                                              .rabbitBreeds);
                                                      setImagePathByAssets =
                                                          'assets/images/default_rabbit.png';
                                                      break;
                                                    case "烏龜":
                                                      myPet.setType('烏龜');
                                                      prefs.setString(
                                                          'keyPetType', '烏龜');
                                                      AllDataModel.defaultBreeds
                                                          .addAll(AllDataModel
                                                              .turtleBreeds);
                                                      setImagePathByAssets =
                                                          'assets/images/default_turtle.png';
                                                      break;
                                                    case "其他":
                                                      AllDataModel.defaultBreeds
                                                          .add("自行輸入");
                                                      setImagePathByAssets =
                                                          'assets/images/default_image.png';
                                                      prefs.setString(
                                                          'keyPetImagePathByAssets',
                                                          'assets/images/default_image.png');
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  '自行輸入寵物類型'),
                                                              actions: <Widget>[
                                                                TextFormField(
                                                                  controller:
                                                                      setTypeController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    prefixIcon:
                                                                        Icon(Icons
                                                                            .pets),
                                                                    hintText:
                                                                        '請輸入寵物的類型',
                                                                  ),
                                                                ),
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            context,
                                                                            'Cancel'),
                                                                        child: const Text(
                                                                            '取消'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.pop(
                                                                              context,
                                                                              'OK');
                                                                          await prefs.setString(
                                                                              'keyPetType',
                                                                              setTypeController.text);
                                                                          setState(
                                                                              () {
                                                                            myPet.setType(setTypeController.text);
                                                                          });
                                                                        },
                                                                        child: const Text(
                                                                            '確定'),
                                                                      ),
                                                                    ]),
                                                              ],
                                                            );
                                                          });
                                                      break;
                                                    default:
                                                      AllDataModel.defaultBreeds
                                                          .clear();
                                                  }
                                                  AllDataModel.petBreeds = null;
                                                },
                                                items: <String>[
                                                  '狗狗',
                                                  '貓咪',
                                                  '兔子',
                                                  '烏龜',
                                                  '其他'
                                                ].map<DropdownMenuItem<String>>(
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
                                                  myPet.getType == ''
                                                      ? "請選擇"
                                                      : '${myPet.getType}',
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
                                                decoration:
                                                    InputDecoration.collapsed(
                                                        hintText: ''),
                                                icon: Icon(Icons
                                                    .keyboard_arrow_down_outlined),
                                                iconSize: 30.0,
                                                iconEnabledColor: ColorSet
                                                    .colorsDarkBlueGreenOfOpacity80,
                                                hint: Text(
                                                  myPet.getBreeds == ''
                                                      ? "請選擇"
                                                      : '${myPet.getBreeds}',
                                                  style: TextStyle(
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                  ),
                                                ),
                                                value: AllDataModel.petBreeds,
                                                isExpanded: true,
                                                onChanged:
                                                    (String? value) async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await prefs.setString(
                                                      'keyPetBreeds',
                                                      value.toString());
                                                  setState(() {
                                                    AllDataModel.petBreeds =
                                                        value;
                                                    myPet.setBreeds(
                                                        value.toString());
                                                  });
                                                  switch (value) {
                                                    case "自行輸入":
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  '自行輸入寵物品種'),
                                                              actions: <Widget>[
                                                                TextFormField(
                                                                  controller:
                                                                      setBreedsController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    prefixIcon:
                                                                        const Icon(
                                                                            Icons.pets),
                                                                    hintText:
                                                                        '請輸入寵物的品種',
                                                                  ),
                                                                ),
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            context,
                                                                            'Cancel'),
                                                                        child: const Text(
                                                                            '取消'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          SharedPreferences
                                                                              prefs =
                                                                              await SharedPreferences.getInstance();
                                                                          await prefs.setString(
                                                                              'keyPetBreeds',
                                                                              setBreedsController.text);
                                                                          Navigator.pop(
                                                                              context,
                                                                              'OK');
                                                                          setState(
                                                                              () {
                                                                            myPet.setBreeds(setBreedsController.text);
                                                                          });
                                                                        },
                                                                        child: const Text(
                                                                            '確定'),
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
                                                            String>>((breeds) {
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
                                          padding: EdgeInsets.only(
                                            left: 15.0,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: ForAllTheme.allRadius,
                                            color: ColorSet
                                                .colorsWhiteGrayOfOpacity80,
                                          ),
                                          child: TextField(
                                            style: TextStyle(
                                              color: ColorSet
                                                  .colorsBlackOfOpacity80,
                                            ),
                                            textAlign: TextAlign.end,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            focusNode: setNameFocusNode,
                                            cursorColor:
                                                ColorSet.colorsBlackOfOpacity80,
                                            controller: setNameController,
                                            onEditingComplete: () {
                                              setNameFocusNode.unfocus();
                                            },
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: const Text(
                                                '輸入寵物姓名',
                                                style: TextStyle(
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                    fontSize: 17.0,
                                                    letterSpacing: 2.0),
                                              ),
                                              prefixIconConstraints:
                                                  BoxConstraints(
                                                      minWidth: 0,
                                                      minHeight: 0),
                                              contentPadding: EdgeInsets.only(
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
                                            borderRadius: ForAllTheme.allRadius,
                                            color: ColorSet
                                                .colorsWhiteGrayOfOpacity80,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Text(
                                                '選擇性別',
                                                style: TextStyle(
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
                                                    myPet.getGender == '公'
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
                                                  [
                                                    ColorSet
                                                        .colorsDarkBlueGreenOfOpacity80
                                                  ],
                                                  [
                                                    ColorSet
                                                        .colorsDarkBlueGreenOfOpacity80
                                                  ]
                                                ],
                                                onToggle: (index) async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  switch (index) {
                                                    case 0:
                                                      myPet.setGender('公');
                                                      await prefs.setString(
                                                          'keyPetGender', '公');
                                                      break;
                                                    case 1:
                                                      myPet.setGender('母');
                                                      await prefs.setString(
                                                          'keyPetGender', '母');
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
                                            borderRadius: ForAllTheme.allRadius,
                                            color: ColorSet
                                                .colorsWhiteGrayOfOpacity80,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              const Text(
                                                '年齡/生日',
                                                style: TextStyle(
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
                                                  activeColor: ColorSet
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
                                                      myPet.setBirthday(
                                                          formattedDate
                                                              .format(DateTime
                                                                  .now())
                                                              .toString());
                                                    }
                                                  }),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15.0),
                                        Container(
                                          width: 250.0,
                                          height: 40.0,
                                          padding: EdgeInsets.only(
                                            left: 15.0,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: ForAllTheme.allRadius,
                                            color: ColorSet
                                                .colorsWhiteGrayOfOpacity80,
                                          ),
                                          child: setIsExactDate == true
                                              ? Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: const Text(
                                                        '選擇生日',
                                                        style: TextStyle(
                                                            color: ColorSet
                                                                .colorsBlackOfOpacity80,
                                                            fontSize: 17.0,
                                                            letterSpacing: 2.0),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Tooltip(
                                                        message: '選擇日期',
                                                        child: TextButton(
                                                          onPressed: () {
                                                            DatePicker
                                                                .showDatePicker(
                                                              context,
                                                              currentTime:
                                                                  DateTime
                                                                      .now(),
                                                              locale:
                                                                  LocaleType.tw,
                                                              showTitleActions:
                                                                  true,
                                                              minTime: DateTime(
                                                                  1971, 1, 1),
                                                              maxTime: DateTime(
                                                                  2030, 12, 31),
                                                              onConfirm:
                                                                  (date) async {
                                                                int birthdayAge =
                                                                    DateTime.now()
                                                                            .year -
                                                                        date.year;
                                                                SharedPreferences
                                                                    prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                await prefs.setString(
                                                                    'keyPetBirthday',
                                                                    formattedDate
                                                                        .format(
                                                                            date));
                                                                await prefs.setString(
                                                                    'keyPetAge',
                                                                    birthdayAge
                                                                        .toString());
                                                                setState(() {
                                                                  myPet.setBirthday(
                                                                      formattedDate
                                                                          .format(
                                                                              date));
                                                                  myPet.setAge(
                                                                      birthdayAge
                                                                          .toString());
                                                                });
                                                              },
                                                              theme:
                                                                  DatePickerTheme(
                                                                cancelStyle:
                                                                    const TextStyle(
                                                                        color: Colors
                                                                            .redAccent),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            myPet.getBirthday ==
                                                                    ''
                                                                ? formattedDate
                                                                    .format(
                                                                        DateTime
                                                                            .now())
                                                                    .toString()
                                                                : myPet
                                                                    .getBirthday,
                                                            style: TextStyle(
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
                                                  style: TextStyle(
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  focusNode: setDateFocusNode,
                                                  cursorColor: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  controller: setAgeController,
                                                  onEditingComplete: () {
                                                    setDateFocusNode.unfocus();
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    prefixIcon: const Text(
                                                      '輸入年齡',
                                                      style: TextStyle(
                                                          color: ColorSet
                                                              .colorsBlackOfOpacity80,
                                                          fontSize: 17.0,
                                                          letterSpacing: 2.0),
                                                    ),
                                                    prefixIconConstraints:
                                                        BoxConstraints(
                                                            minWidth: 0,
                                                            minHeight: 0),
                                                    suffixText: '歲',
                                                    suffixStyle: TextStyle(
                                                        color: ColorSet
                                                            .colorsBlackOfOpacity80,
                                                        fontSize: 17.0,
                                                        letterSpacing: 2.0),
                                                    contentPadding:
                                                        EdgeInsets.only(
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
                                            borderRadius: ForAllTheme.allRadius,
                                            color: ColorSet
                                                .colorsWhiteGrayOfOpacity80,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              const Text(
                                                '是否結紮',
                                                style: TextStyle(
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                    fontSize: 17.0,
                                                    letterSpacing: 2.0),
                                              ),
                                              const SizedBox(
                                                width: 5.0,
                                              ),
                                              Switch(
                                                value: setIsNeutered,
                                                inactiveThumbColor: ColorSet
                                                    .colorsWhiteGrayOfOpacity80,
                                                inactiveTrackColor:
                                                    ColorSet.colorsWhite,
                                                activeColor: ColorSet
                                                    .colorsDarkBlueGreenOfOpacity80,
                                                activeTrackColor:
                                                    ColorSet.colorsWhite,
                                                onChanged: (value) {
                                                  setState(() {
                                                    setIsNeutered = value;
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
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
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
                                    color:
                                        ColorSet.colorsDarkBlueGreenOfOpacity80,
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      _confirmChanges();
                                    },
                                    child: Text(
                                      '完成',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
                          margin: EdgeInsets.only(
                              left: 22.0, top: 20.0, bottom: 17.0),
                          shape: MyCardTheme.cardsForRightShapeBorder,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
