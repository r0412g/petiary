import 'dart:io';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  bool setImageSelected = false;
  final formattedDate = DateFormat('yyyy-MM-dd');
  var setImage;

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

  void _confirmChanges(context) async {
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();

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
      if (myPet.getBirthday == '尚未設定') {
        myPet.setAge('0');
        await prefs.setString('keyPetAge', '0');
        myPet.setBirthday('尚未設定');
        await prefs.setString('keyPetBirthday', '尚未設定');
      }
    }

    Navigator.of(context).pop();

    Fluttertoast.showToast(
        msg: "修改完成!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  /* Select Pet Image On User Device */
  Future<Null> _pickImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MyPetModel myPet = Provider.of<MyPetModel>(context, listen: false);
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setImage = pickedImage;

    // Image selected then save
    if (setImage != null) {
      setImageSelected = true;
      await prefs.setString('keyPetImagePath', setImage.path);
      setState(() {
        myPet.setImagePath(setImage.path);
      });
      _cropImage();
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
      sourcePath: setImage.path,
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
      setImage = croppedFile;
      await prefs.setString('keyPetImagePath', setImage.path);
      setState(() {
        myPet.setImagePath(setImage.path);
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

  @override
  Widget build(BuildContext context) {
    var myPet = Provider.of<MyPetModel>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorSet.primaryColors,
          title: Text('編輯我的寵物'),
          actions: <Widget>[
            IconButton(
                tooltip: '確認更改',
                onPressed: () {
                  _confirmChanges(context);
                },
                icon: Icon(Icons.check)),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              color: ColorSet.primaryLightColors,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      myPet.getImagePath != ''
                          ? Image.file(File(myPet.getImagePath),
                              fit: BoxFit.fill, width: 125.0, height: 125.0)
                          : Image.asset(AllDataModel.defaultImage,
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
                                    color: ColorSet.secondaryColors,
                                  ),
                                  label: Text('選擇相片',
                                      style: TextStyle(
                                        color: ColorSet.secondaryColors,
                                      ))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    child: TextField(
                      focusNode: setNameFocusNode,
                      cursorColor: ColorSet.primaryLightColors,
                      controller: setNameController,
                      onEditingComplete: () {
                        setNameFocusNode.unfocus();
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.pets,
                              color: ColorSet.primaryLightColors),
                          labelText: '寵物名字',
                          labelStyle: TextStyle(color: Colors.black38),
                          hintText: '請輸入寵物名字'),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ToggleSwitch(
                    minWidth: 90.0,
                    initialLabelIndex: myPet.getGender == '男' ? 0 : 1,
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
                          myPet.setGender('男');
                          await prefs.setString('keyPetGender', '男');
                          break;
                        case 1:
                          myPet.setGender('女');
                          await prefs.setString('keyPetGender', '女');
                          break;
                      }
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: ColorSet.thirdColors,
                      value: AllDataModel.petType,
                      onChanged: (value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          AllDataModel.petType = value;
                          myPet.setBreeds('請選擇');
                        });
                        AllDataModel.defaultBreeds.clear();
                        myPet.setBreeds('');
                        await prefs.setString('keyPetBreeds', '');
                        /* Change Breeds List By Select Different Type */
                        switch (AllDataModel.petType) {
                          case "狗狗":
                            myPet.setType('狗狗');
                            prefs.setString('keyPetType', '狗狗');
                            AllDataModel.defaultBreeds
                                .addAll(AllDataModel.dogBreeds);
                            break;
                          case "貓咪":
                            myPet.setType('貓咪');
                            prefs.setString('keyPetType', '貓咪');
                            AllDataModel.defaultBreeds
                                .addAll(AllDataModel.catBreeds);
                            break;
                          case "兔子":
                            myPet.setType('兔子');
                            prefs.setString('keyPetType', '兔子');
                            AllDataModel.defaultBreeds
                                .addAll(AllDataModel.rabbitBreeds);
                            break;
                          case "烏龜":
                            myPet.setType('烏龜');
                            prefs.setString('keyPetType', '烏龜');
                            AllDataModel.defaultBreeds
                                .addAll(AllDataModel.turtleBreeds);
                            break;
                          case "其他":
                            AllDataModel.defaultBreeds.add("自行輸入");
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('自行輸入寵物類型'),
                                    actions: <Widget>[
                                      TextFormField(
                                        controller: setTypeController,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.pets),
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
                                              onPressed: () async {
                                                Navigator.pop(context, 'OK');
                                                await prefs.setString(
                                                    'keyPetType',
                                                    setTypeController.text);
                                                setState(() {
                                                  myPet.setType(
                                                      setTypeController.text);
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
                            AllDataModel.defaultBreeds.clear();
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
                      hint: Text(
                        myPet.getType == '' ? "選擇寵物類型" : '${myPet.getType}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    child: DropdownButton(
                      hint: Text(
                        myPet.getBreeds == ''
                            ? "選擇寵物品種(花色)"
                            : '${myPet.getBreeds}',
                      ),
                      value: AllDataModel.petBreeds,
                      isExpanded: true,
                      dropdownColor: ColorSet.thirdColors,
                      onChanged: (String? value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('keyPetBreeds', value.toString());
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
                                    title: const Text('自行輸入寵物品種(花色)'),
                                    actions: <Widget>[
                                      TextFormField(
                                        controller: setBreedsController,
                                        decoration: const InputDecoration(
                                          prefixIcon: const Icon(Icons.pets),
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
                                                    setBreedsController.text);
                                                Navigator.pop(context, 'OK');
                                                setState(() {
                                                  myPet.setBreeds(
                                                      setBreedsController.text);
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
                      items: AllDataModel.defaultBreeds
                          .map<DropdownMenuItem<String>>((breeds) {
                        return DropdownMenuItem<String>(
                          value: breeds,
                          child: new Text(breeds),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    child: SwitchListTile(
                        title: Text('寵物是否結紮?'),
                        subtitle: setIsNeutered == false
                            ? const Text('否')
                            : const Text('是'),
                        value: setIsNeutered,
                        activeColor: ColorSet.primaryLightColors,
                        onChanged: (value) {
                          setState(() {
                            setIsNeutered = value;
                          });
                        }),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    color: ColorSet.thirdColors,
                    width: 250.0,
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                            title: Text('寵物確切生日?'),
                            subtitle: setIsExactDate == true
                                ? const Text('是')
                                : const Text('否'),
                            value: setIsExactDate,
                            activeColor: ColorSet.primaryLightColors,
                            onChanged: (value) {
                              setState(() {
                                setIsExactDate = value;
                              });
                              /* Reset value while switch on changed */
                              if (setIsExactDate == false) {
                                setAgeController.text = '';
                              } else {
                                myPet.setBirthday('尚未設定');
                              }
                            }),
                        setIsExactDate == true
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
                                      showTitleActions: true,
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
                                  child: Text(myPet.getBirthday == '尚未設定'
                                      ? '點擊選擇寵物生日'
                                      : myPet.getBirthday),
                                ),
                              )
                            : Container(
                                width: 150.0,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  focusNode: setDateFocusNode,
                                  cursorColor: ColorSet.primaryLightColors,
                                  controller: setAgeController,
                                  onEditingComplete: () {
                                    setDateFocusNode.unfocus();
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
                ],
              ),
              shape: MyCardTheme.cardShapeBorder,
              margin: MyCardTheme.cardMargin,
            ),
          ),
        ));
  }
}
