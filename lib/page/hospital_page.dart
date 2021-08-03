import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/database/medical_db.dart';

class HospitalPage extends StatefulWidget {
  HospitalPage({Key? key}) : super(key: key);

  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
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
  final formattedDate = DateFormat('yyyy-MM-dd');
  DateTime medicalDate = DateTime.now();
  DateTime editMedicalDate = DateTime.now();
  bool isMedicine = false;
  bool editIsMedicine = false;
  List<MedicalRecords> medicalRecordsList = [];

  /* Clean up the controller when the widget is disposed */
  @override
  void dispose() {
    medicineController.dispose();
    weightController.dispose();
    remarkController.dispose();
    editMedicineController.dispose();
    editWeightController.dispose();
    editRemarkController.dispose();
    super.dispose();
  }

  /* Add medical records in database and refresh listView */
  void _addMedicalRecords() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, _setState) {
            return AlertDialog(
                title: Container(
                  color: ColorSet.secondaryColors,
                  alignment: Alignment.center,
                  child: const Text('新增就醫紀錄'),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          const Text('日期：'),
                          Tooltip(
                            message: '選擇就醫日期',
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
                                  theme: const DatePickerTheme(
                                    cancelStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                );
                              },
                              child: Text(
                                '${formattedDate.format(medicalDate)}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        focusNode: weightFocusNode,
                        cursorColor: ColorSet.primaryLightColors,
                        onEditingComplete: () {
                          weightFocusNode.unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: '體重',
                          suffixText: 'kg',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.primaryColors,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.secondaryDarkColors,
                            ),
                          ),
                          hintText: '請輸入體重',
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SwitchListTile(
                          title: const Text('拿藥?'),
                          subtitle: isMedicine == true
                              ? const Text('是')
                              : const Text('否'),
                          value: isMedicine,
                          activeColor: ColorSet.primaryLightColors,
                          onChanged: (value) {
                            _setState(() {
                              isMedicine = value;
                              if (isMedicine == false)
                                medicineController.text = '';
                            });
                          }),
                      isMedicine == true
                          ? TextFormField(
                              controller: medicineController,
                              focusNode: medicineFocusNode,
                              cursorColor: ColorSet.primaryLightColors,
                              onEditingComplete: () {
                                medicineFocusNode.unfocus();
                              },
                              decoration: InputDecoration(
                                labelText: '藥物',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: ColorSet.primaryColors,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: ColorSet.secondaryDarkColors,
                                  ),
                                ),
                                hintText: '請輸入藥物相關資訊',
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: remarkController,
                        keyboardType: TextInputType.multiline,
                        focusNode: remarkFocusNode,
                        cursorColor: ColorSet.primaryLightColors,
                        onEditingComplete: () {
                          remarkFocusNode.unfocus();
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 50.0, horizontal: 10.0),
                          labelText: '備註',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.primaryColors,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.secondaryDarkColors,
                            ),
                          ),
                          hintText: '請輸入備註',
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      // user choose have medicine but didn't enter text
                      if (isMedicine == true && medicineController.text == '') {
                        isMedicine = false;
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
                    child: const Text('確定'),
                  ),
                ]);
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
            return Dialog(
              backgroundColor: ColorSet.secondaryColors,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                            ['date'],
                        style: const TextStyle(fontSize: 25.0),
                      ),
                      const Divider(
                        color: ColorSet.secondaryDarkColors,
                        height: 35.0,
                        thickness: 3.0,
                        indent: 30.0,
                        endIndent: 30.0,
                      ),
                      showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                                  ['weight'] ==
                              0.0
                          ? const Text(
                              '體重：無資料',
                              style: const TextStyle(fontSize: 17.0),
                            )
                          : Text(
                              '體重：${showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]['weight']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                                  ['medicine'] ==
                              ''
                          ? const Text(
                              '藥物：沒拿藥',
                              style: const TextStyle(fontSize: 17.0),
                            )
                          : Text(
                              '藥物：${showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]['medicine']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]
                                  ['remark'] ==
                              ''
                          ? const Text(
                              '備註：無',
                              style: const TextStyle(fontSize: 17.0),
                            )
                          : Text(
                              '備註：${showMedicalDetailsSnapshot.data[showMedicalDetailsIndex]['remark']}',
                              style: const TextStyle(fontSize: 17.0),
                            ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
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
              backgroundColor: ColorSet.secondaryColors,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(
                        height: 20.0,
                      ),
                      Tooltip(
                        message: '編輯事件',
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
                              Icons.edit_outlined,
                              color: Colors.black,
                            ),
                            label: const Text(
                              '編輯',
                              style: const TextStyle(color: Colors.black),
                            )),
                      ),
                      Tooltip(
                        message: '刪除事件',
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
                              Icons.delete_forever_outlined,
                              color: Colors.black,
                            ),
                            label: const Text(
                              '刪除',
                              style: const TextStyle(color: Colors.black),
                            )),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
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
                title: Container(
                  color: ColorSet.secondaryColors,
                  alignment: Alignment.center,
                  child: const Text('編輯就醫紀錄'),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          const Text('日期：'),
                          Tooltip(
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
                                  theme: const DatePickerTheme(
                                    cancelStyle: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                );
                              },
                              child: Text(
                                '${formattedDate.format(editMedicalDate)}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: editWeightController,
                        keyboardType: TextInputType.number,
                        focusNode: editWeightFocusNode,
                        cursorColor: ColorSet.primaryLightColors,
                        onEditingComplete: () {
                          editWeightFocusNode.unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: '體重',
                          suffixText: 'kg',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.primaryColors,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.secondaryDarkColors,
                            ),
                          ),
                          hintText: '更改體重',
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SwitchListTile(
                          title: const Text('拿藥?'),
                          subtitle: editIsMedicine == true
                              ? const Text('是')
                              : const Text('否'),
                          value: editIsMedicine,
                          activeColor: ColorSet.primaryLightColors,
                          onChanged: (value) {
                            _setState(() {
                              editIsMedicine = value;
                              if (editIsMedicine == false)
                                editMedicineController.text = '';
                            });
                          }),
                      editIsMedicine == true
                          ? TextFormField(
                              controller: editMedicineController,
                              focusNode: editMedicineFocusNode,
                              cursorColor: ColorSet.primaryLightColors,
                              onEditingComplete: () {
                                editMedicineFocusNode.unfocus();
                              },
                              decoration: InputDecoration(
                                labelText: '藥物',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: ColorSet.primaryColors,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: ColorSet.secondaryDarkColors,
                                  ),
                                ),
                                hintText: '更改藥物相關資訊',
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: editRemarkController,
                        keyboardType: TextInputType.multiline,
                        focusNode: editRemarkFocusNode,
                        cursorColor: ColorSet.primaryLightColors,
                        onEditingComplete: () {
                          editRemarkFocusNode.unfocus();
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 50.0, horizontal: 10.0),
                          labelText: '備註',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.primaryColors,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                              color: ColorSet.secondaryDarkColors,
                            ),
                          ),
                          hintText: '更改備註',
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('取消'),
                  ),
                  TextButton(
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
                    child: const Text('確定'),
                  ),
                ]);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
          child: FutureBuilder(
        future: MedicalInfoDB.queryMedicalRecords(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data?.length == 0) {
            return const Center(child: const Text('沒有醫療紀錄'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: const CircularProgressIndicator(
                color: ColorSet.secondaryColors,
                backgroundColor: ColorSet.primaryLightColors,
              ),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Card(
                  shadowColor: ColorSet.primaryColors,
                  margin: const EdgeInsets.all(7.0),
                  child: ListTile(
                    leading: Text('${snapshot.data[index]['date']}'),
                    title: snapshot.data[index]['medicine'] == ''
                        ? const Text(
                            '沒拿藥',
                            style: TextStyle(fontSize: 15.0),
                          )
                        : Text(
                            '${snapshot.data[index]['medicine']}',
                            style: TextStyle(fontSize: 15.0),
                          ),
                    trailing: snapshot.data[index]['weight'] == 0.0
                        ? const Text('沒量體重')
                        : Text('${snapshot.data[index]['weight']}kg'),
                    onTap: () {
                      _onTapShowMedicalDetails(snapshot, index);
                    },
                    onLongPress: () {
                      _onLongPressEditOrDelete(snapshot, index);
                    },
                  ),
                );
              });
        },
      )),
      floatingActionButton: FloatingActionButton(
        tooltip: '新增醫療紀錄',
        backgroundColor: ColorSet.secondaryColors,
        onPressed: () {
          /* Initial value in add medical records page */
          medicalDate = DateTime.now();
          medicineController.text = '';
          weightController.text = '';
          remarkController.text = '';
          isMedicine = false;
          _addMedicalRecords();
        },
        child: const Icon(
          Icons.add_outlined,
          color: ColorSet.primaryColors,
        ),
      ),
    );
  }
}
