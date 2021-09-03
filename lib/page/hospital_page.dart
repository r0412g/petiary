import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/common/data.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/database/medical_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HospitalPage extends StatefulWidget {
  HospitalPage({Key? key}) : super(key: key);

  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  final formattedDate = DateFormat('yyyy-MM-dd');
  DateTime medicalDate = DateTime.now();
  DateTime editMedicalDate = DateTime.now();
  bool isMedicine = false;
  bool editIsMedicine = false;
  List<MedicalRecords> medicalRecordsList = [];

  FocusNode medicineFocusNode = new FocusNode();
  FocusNode weightFocusNode = new FocusNode();
  FocusNode remarkFocusNode = new FocusNode();
  FocusNode editMedicineFocusNode = new FocusNode();
  FocusNode editWeightFocusNode = new FocusNode();
  FocusNode editRemarkFocusNode = new FocusNode();
  TextEditingController medicineController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController editMedicineController = TextEditingController();
  TextEditingController editWeightController = TextEditingController();
  TextEditingController editRemarkController = TextEditingController();

  @override
  void initState() {
    _addDefaultMedicalRecords();
    super.initState();
  }

  /* Add default medical records when user using app at first time */
  void _addDefaultMedicalRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkHospitalPage = prefs.getBool('keyCheckHospitalPage') ?? false;
    if (checkHospitalPage == false) {
      if (AllDataModel.checkFirstSeen == false) {
        setState(() {
          MedicalInfoDB.insertMedicalRecords(
            MedicalRecords(
              date: formattedDate.format(DateTime.now()).toString(),
              isMedicine: 1,
              medicine: '驅蟲藥',
              weight: 10.0,
              remark: '體重過重 要注意飲食',
            ),
          );
        });
      }
      prefs.setBool('keyCheckHospitalPage', true);
    }
  }

  /* Clean up the controller and focus node when the widget is disposed */
  @override
  void dispose() {
    medicineController.dispose();
    weightController.dispose();
    remarkController.dispose();
    editMedicineController.dispose();
    editWeightController.dispose();
    editRemarkController.dispose();
    medicineFocusNode.dispose();
    weightFocusNode.dispose();
    remarkFocusNode.dispose();
    editMedicineFocusNode.dispose();
    editWeightFocusNode.dispose();
    editRemarkFocusNode.dispose();
    super.dispose();
  }

  /* Add medical records in database and refresh listView */
  void _addMedicalRecords() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, _setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 40.0,
                    ),
                    const Text(
                      '新增就醫紀錄',
                      style: const TextStyle(
                        color: ColorSet.colorsBlackOfOpacity80,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '就診日期',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        Flexible(
                          child: Tooltip(
                            message: '選擇就診日期',
                            child: TextButton(
                              onPressed: () {
                                DatePicker.showDatePicker(
                                  context,
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.tw,
                                  showTitleActions: true,
                                  onConfirm: (date) {
                                    _setState(() {
                                      medicalDate = date;
                                    });
                                  },
                                );
                              },
                              child: Text(
                                '${formattedDate.format(medicalDate)}',
                                style: MyDialogTheme.dialogContentStyle,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Divider(),
                    TextField(
                      style: MyDialogTheme.dialogContentStyle,
                      textAlign: TextAlign.end,
                      textAlignVertical: TextAlignVertical.center,
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      focusNode: weightFocusNode,
                      cursorColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                      onEditingComplete: () {
                        weightFocusNode.unfocus();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Text(
                          '體重',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixText: 'kg',
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '是否拿藥',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        Switch(
                            value: isMedicine,
                            inactiveThumbColor:
                                ColorSet.colorsWhiteGrayOfOpacity80,
                            inactiveTrackColor:
                                ColorSet.colorsWhiteGrayOfOpacity80,
                            activeColor:
                                ColorSet.colorsDarkBlueGreenOfOpacity80,
                            activeTrackColor:
                                ColorSet.colorsWhiteGrayOfOpacity80,
                            onChanged: (value) {
                              _setState(() {
                                isMedicine = value;
                                if (isMedicine == false)
                                  medicineController.text = '';
                              });
                            }),
                      ],
                    ),
                    const Divider(),
                    isMedicine == true
                        ? Column(
                            children: <Widget>[
                              TextField(
                                style: MyDialogTheme.dialogContentStyle,
                                textAlign: TextAlign.end,
                                textAlignVertical: TextAlignVertical.center,
                                controller: medicineController,
                                focusNode: medicineFocusNode,
                                cursorColor:
                                    ColorSet.colorsDarkBlueGreenOfOpacity80,
                                onEditingComplete: () {
                                  medicineFocusNode.unfocus();
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Text(
                                    '藥物',
                                    style: MyDialogTheme.dialogTitleStyle,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 0, minHeight: 0),
                                ),
                              ),
                              const Divider(),
                            ],
                          )
                        : Container(),
                    TextField(
                      style: MyDialogTheme.dialogContentStyle,
                      textAlign: TextAlign.end,
                      textAlignVertical: TextAlignVertical.center,
                      controller: remarkController,
                      keyboardType: TextInputType.multiline,
                      focusNode: remarkFocusNode,
                      cursorColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                      onEditingComplete: () {
                        remarkFocusNode.unfocus();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Text(
                          '新增備註',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text(
                    '取消',
                    style: const TextStyle(
                        color: ColorSet.colorsBlackOfOpacity80,
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
                    color: ColorSet.colorsDarkBlueGreenOfOpacity80,
                  ),
                  child: TextButton(
                    onPressed: () {
                      // user choose have medicine but didn't enter text
                      if (isMedicine == true && medicineController.text == '') {
                        medicineController.text = '無紀錄藥物';
                      }
                      MedicalRecords newMedicalRecords = MedicalRecords(
                        date: formattedDate.format(medicalDate),
                        isMedicine: isMedicine == false ? 0 : 1,
                        medicine: medicineController.text,
                        weight: double.tryParse(weightController.text) ?? 0.0,
                        remark: remarkController.text,
                      );
                      setState(() {
                        MedicalInfoDB.insertMedicalRecords(
                          newMedicalRecords,
                        );
                        Navigator.pop(context, 'OK');
                      });
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
            );
          });
        });
  }

  /* Show medical record details on dialog */
  void _onTapShowMedicalDetails(
      AsyncSnapshot showMedicalDetailsSnapshot, int showMedicalDetailsIndex) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, _setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                          ['date'],
                      style: const TextStyle(
                        color: ColorSet.colorsBlackOfOpacity80,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '體重',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                                    ['weight'] ==
                                0.0
                            ? Text(
                                '無紀錄體重',
                                style: MyDialogTheme.dialogContentStyle,
                              )
                            : Text(
                                '${showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]['weight']} kg',
                                style: MyDialogTheme.dialogContentStyle,
                              ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '藥物',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                                    ['isMedicine'] ==
                                0
                            ? Text(
                                '沒拿藥',
                                style: MyDialogTheme.dialogContentStyle,
                              )
                            : Text(
                                '${showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]['medicine']}',
                                style: MyDialogTheme.dialogContentStyle,
                              ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '備註',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                                    ['remark'] ==
                                ''
                            ? Text(
                                '無',
                                style: MyDialogTheme.dialogContentStyle,
                              )
                            : Container(
                                // 50% of screen width
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  '${showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]['remark']}',
                                  style: MyDialogTheme.dialogContentStyle,
                                  softWrap: true,
                                ),
                              ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 40.0,
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  /* Show edit or delete medical records on dialog */
  void _onLongPressEditOrDelete(
      AsyncSnapshot editOrDeleteSnapshot, int editOrDeleteIndex) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, _setState) {
            return Dialog(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Tooltip(
                    message: '編輯就醫紀錄',
                    child: TextButton.icon(
                        onPressed: () {
                          // Get medical records details on edit page
                          editMedicalDate = formattedDate.parse(
                              editOrDeleteSnapshot.data[editOrDeleteIndex]
                                  ['date']);
                          editOrDeleteSnapshot.data[editOrDeleteIndex]
                                      ['isMedicine'] ==
                                  0
                              ? editIsMedicine = false
                              : editIsMedicine = true;
                          editMedicineController.text = editOrDeleteSnapshot
                              .data[editOrDeleteIndex]['medicine'];
                          editWeightController.text = editOrDeleteSnapshot
                              .data[editOrDeleteIndex]['weight']
                              .toString();
                          editRemarkController.text = editOrDeleteSnapshot
                              .data[editOrDeleteIndex]['remark'];

                          // edit medical records
                          _editMedicalRecords(
                              editOrDeleteSnapshot, editOrDeleteIndex);
                        },
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: ColorSet.colorsGrayOfOpacity80,
                        ),
                        label: const Text(
                          '編輯',
                          style: const TextStyle(
                              color: ColorSet.colorsGrayOfOpacity80),
                        )),
                  ),
                  Tooltip(
                    message: '刪除就醫紀錄',
                    child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            // delete medical records in database
                            MedicalInfoDB.deleteMedicalRecords(
                                editOrDeleteSnapshot.data[editOrDeleteIndex]
                                    ['id']);
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: ColorSet.colorsGrayOfOpacity80,
                        ),
                        label: const Text(
                          '刪除',
                          style: const TextStyle(
                              color: ColorSet.colorsGrayOfOpacity80),
                        )),
                  ),
                ],
              ),
            );
          });
        });
  }

  /* Edit medical records on dialog */
  void _editMedicalRecords(
      AsyncSnapshot editMedicalRecordsSnapshot, int editMedicalRecordsIndex) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, _setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 40.0,
                    ),
                    const Text(
                      '編輯就醫紀錄',
                      style: const TextStyle(
                        color: ColorSet.colorsBlackOfOpacity80,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '就診日期',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        Flexible(
                          child: Tooltip(
                            message: '更改就醫日期',
                            child: TextButton(
                              onPressed: () {
                                DatePicker.showDatePicker(
                                  context,
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.tw,
                                  showTitleActions: true,
                                  onConfirm: (date) {
                                    _setState(() {
                                      editMedicalDate = date;
                                    });
                                  },
                                );
                              },
                              child: Text(
                                '${formattedDate.format(editMedicalDate)}',
                                style: MyDialogTheme.dialogContentStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextField(
                      style: MyDialogTheme.dialogContentStyle,
                      textAlign: TextAlign.end,
                      textAlignVertical: TextAlignVertical.center,
                      controller: editWeightController,
                      keyboardType: TextInputType.number,
                      focusNode: editWeightFocusNode,
                      cursorColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                      onEditingComplete: () {
                        editWeightFocusNode.unfocus();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Text(
                          '體重',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixText: 'kg',
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '是否拿藥',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        Switch(
                            value: editIsMedicine,
                            inactiveThumbColor:
                                ColorSet.colorsWhiteGrayOfOpacity80,
                            inactiveTrackColor:
                                ColorSet.colorsWhiteGrayOfOpacity80,
                            activeColor:
                                ColorSet.colorsDarkBlueGreenOfOpacity80,
                            activeTrackColor:
                                ColorSet.colorsWhiteGrayOfOpacity80,
                            onChanged: (value) {
                              _setState(() {
                                editIsMedicine = value;
                                if (editIsMedicine == false)
                                  editMedicineController.text = '';
                              });
                            }),
                      ],
                    ),
                    const Divider(),
                    editIsMedicine == true
                        ? Column(
                            children: <Widget>[
                              TextField(
                                style: MyDialogTheme.dialogContentStyle,
                                textAlign: TextAlign.end,
                                textAlignVertical: TextAlignVertical.center,
                                controller: editMedicineController,
                                focusNode: editMedicineFocusNode,
                                cursorColor:
                                    ColorSet.colorsDarkBlueGreenOfOpacity80,
                                onEditingComplete: () {
                                  editMedicineFocusNode.unfocus();
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Text(
                                    '藥物',
                                    style: MyDialogTheme.dialogTitleStyle,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 0, minHeight: 0),
                                ),
                              ),
                              const Divider(),
                            ],
                          )
                        : Container(),
                    TextField(
                      style: MyDialogTheme.dialogContentStyle,
                      textAlign: TextAlign.end,
                      textAlignVertical: TextAlignVertical.center,
                      controller: editRemarkController,
                      keyboardType: TextInputType.multiline,
                      focusNode: editRemarkFocusNode,
                      cursorColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                      onEditingComplete: () {
                        editRemarkFocusNode.unfocus();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Text(
                          '編輯備註',
                          style: MyDialogTheme.dialogTitleStyle,
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text(
                    '取消',
                    style: const TextStyle(
                        color: ColorSet.colorsBlackOfOpacity80,
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
                    color: ColorSet.colorsDarkBlueGreenOfOpacity80,
                  ),
                  child: TextButton(
                    onPressed: () {
                      // user choose have medicine but didn't enter text
                      if (editIsMedicine == true &&
                          editMedicineController.text == '') {
                        editIsMedicine = false;
                      }
                      MedicalRecords editMedicalRecords = MedicalRecords(
                        date: formattedDate.format(editMedicalDate),
                        isMedicine: editIsMedicine == false ? 0 : 1,
                        medicine: editMedicineController.text,
                        weight:
                            double.tryParse(editWeightController.text) ?? 0.0,
                        remark: editRemarkController.text,
                      );
                      setState(() {
                        // update medical records in database
                        MedicalInfoDB.updateMedicalRecords(
                            editMedicalRecords,
                            editMedicalRecordsSnapshot
                                .data[editMedicalRecordsIndex]['id']);

                        // back to hospital page
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      });
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
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      '就醫紀錄',
                      style: const TextStyle(
                        letterSpacing: 1.0,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: ColorSet.colorsBlackOfOpacity80,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 540.0,
                            child: Card(
                              color: ColorSet.primaryColorsGreenOfOpacity80,
                              margin: const EdgeInsets.only(
                                  right: 22.0, top: 55.0, bottom: 17.0),
                              shape: MyCardTheme.cardsForLeftShapeBorder,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 300.0,
                          height: 540.0,
                          child: Card(
                            color: ColorSet.primaryColorsGreenOfOpacity80,
                            margin:
                                const EdgeInsets.only(top: 55.0, bottom: 17.0),
                            child: Column(
                              children: <Widget>[
                                const Spacer(flex: 1),
                                Expanded(
                                  flex: 10,
                                  child: FutureBuilder(
                                      future:
                                          MedicalInfoDB.queryMedicalRecords(),
                                      builder:
                                          (context, AsyncSnapshot snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.data?.length == 0) {
                                          return const Center(
                                              child: const Text('沒有醫療紀錄'));
                                        }
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child:
                                                const CircularProgressIndicator(
                                              color: ColorSet
                                                  .colorsWhiteGrayOfOpacity80,
                                              backgroundColor: ColorSet
                                                  .colorsDarkBlueGreenOfOpacity80,
                                            ),
                                          );
                                        }
                                        return ListView.builder(
                                            padding: const EdgeInsets.only(
                                                right: 15.0, left: 15.0),
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                child: Container(
                                                  height: 50.0,
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          3.0, 7.0, 3.0, 7.0),
                                                  child: ListTile(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    tileColor: ColorSet
                                                        .colorsWhiteGrayOfOpacity80,
                                                    leading: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          '${snapshot.data[index]['date']}',
                                                          style:
                                                              const TextStyle(
                                                            color: ColorSet
                                                                .colorsBlackOfOpacity80,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    title: snapshot.data[index]
                                                                ['weight'] ==
                                                            0.0
                                                        ? const Text(
                                                            '沒量體重',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15.0,
                                                              color: ColorSet
                                                                  .colorsBlackOfOpacity80,
                                                            ),
                                                          )
                                                        : Text(
                                                            '${snapshot.data[index]['weight']} kg',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15.0,
                                                              color: ColorSet
                                                                  .colorsBlackOfOpacity80,
                                                            ),
                                                          ),
                                                    onTap: () {
                                                      _onTapShowMedicalDetails(
                                                          snapshot, index);
                                                    },
                                                    onLongPress: () {
                                                      _onLongPressEditOrDelete(
                                                          snapshot, index);
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                      }),
                                ),
                                const Spacer(flex: 1),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 540.0,
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
                Positioned(
                  right: 20.0,
                  bottom: 40.0,
                  child: FloatingActionButton(
                    tooltip: '新增醫療紀錄',
                    backgroundColor: ColorSet.colorsWhite,
                    child: const Icon(
                      Icons.add_outlined,
                      color: ColorSet.colorsDarkBlueGreenOfOpacity80,
                      size: 30.0,
                    ),
                    onPressed: () {
                      /* Initial value in add medical records page */
                      medicalDate = DateTime.now();
                      medicineController.text = '';
                      weightController.text = '';
                      remarkController.text = '';
                      isMedicine = false;
                      _addMedicalRecords();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
