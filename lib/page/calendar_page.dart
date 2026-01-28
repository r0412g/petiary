import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/database/event_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dateTimePicker;

class CalendarPage extends StatefulWidget {
  CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

/* Using for calendar event */
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}

/* Color extension */
extension HexColor on Color {
  // String to color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class _CalendarPageState extends State<CalendarPage> {
  final Future<String> _futureWaitingData = Future<String>.delayed(
    const Duration(seconds: 1),
    () => 'Data Loaded',
  );

  final formattedDateAndTime = DateFormat('yyyy-MM-dd HH:mm');
  final formattedDate = DateFormat('yyyy-MM-dd');
  DateTime startDatetime = DateTime.now();
  DateTime editStartDatetime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  DateTime editEndDateTime = DateTime.now();
  Color eventColor = Color(0xfff44336);
  Color editEventColor = Color(0xfff44336);
  CalendarDataSource _dataSource = EventDataSource(<Appointment>[]);
  bool isAllDay = false;
  bool editIsAllDay = false;
  bool calendarPageShowWeekNumber = false;
  bool calendarPageIs24hourSystem = true;
  int eventId = 1;
  int calendarPageFirstDayOfWeek = 7;

  FocusNode eventNameFocusNode = new FocusNode();
  FocusNode editEventNameFocusNode = new FocusNode();
  TextEditingController eventNameController = TextEditingController();
  TextEditingController editEventNameController = TextEditingController();

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }

  void _loadData(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      calendarPageFirstDayOfWeek = prefs.getInt('keyFirstDayOfWeek') ?? 7;
      calendarPageShowWeekNumber = prefs.getBool('keyShowWeekNumber') ?? false;
      calendarPageIs24hourSystem = prefs.getBool('keyIs24hourSystem') ?? true;
      eventId = prefs.getInt('keyEventId') ?? 1;
    });

    // Show events in database
    Future<List<Map<String, Object?>>> eventData = EventInfoDB.queryEvent();
    eventData.then((value) {
      for (dynamic event in value) {
        Appointment appointment = Appointment(
          id: event['id'],
          subject: event['name'],
          startTime: DateFormat('yyyy-MM-dd HH:mm').parse(event['startDate']),
          endTime: DateFormat('yyyy-MM-dd HH:mm').parse(event['endDate']),
          color: HexColor.fromHex(event['color']),
          isAllDay: event['isAllDay'] != 0,
        );
        _dataSource.appointments!.add(appointment);
        _dataSource
            .notifyListeners(CalendarDataSourceAction.add, [appointment]);
      }
    });
  }

  /* Clean up the controller and focus node when the widget is disposed */
  @override
  void dispose() {
    eventNameController.dispose();
    editEventNameController.dispose();
    eventNameFocusNode.dispose();
    editEventNameFocusNode.dispose();
    super.dispose();
  }

  /* Add event on calendar */
  void _addEvent() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        style: MyDialogTheme.dialogContentStyle,
                        textAlign: TextAlign.end,
                        textAlignVertical: TextAlignVertical.center,
                        controller: eventNameController,
                        focusNode: eventNameFocusNode,
                        cursorColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                        onEditingComplete: () {
                          eventNameFocusNode.unfocus();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Text(
                            '輸入活動名稱',
                            style: MyDialogTheme.dialogTitleStyle,
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '是否全天',
                            style: MyDialogTheme.dialogTitleStyle,
                          ),
                          Switch(
                              value: isAllDay,
                              inactiveThumbColor:
                                  ColorSet.colorsWhiteGrayOfOpacity80,
                              inactiveTrackColor:
                                  ColorSet.colorsWhiteGrayOfOpacity80,
                              activeThumbColor:
                                  ColorSet.colorsDarkBlueGreenOfOpacity80,
                              activeTrackColor:
                                  ColorSet.colorsWhiteGrayOfOpacity80,
                              onChanged: (value) {
                                setState(() {
                                  isAllDay = value;
                                });
                              }),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          isAllDay == false
                              ? Text(
                                  '開始時間',
                                  style: MyDialogTheme.dialogTitleStyle,
                                )
                              : Text(
                                  '開始日期',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                          // All day show date, not all day show date and time
                          isAllDay == false
                              ? Tooltip(
                                  message: '選擇開始時間',
                                  child: TextButton(
                                    onPressed: () {
                                      dateTimePicker.DatePicker
                                          .showDateTimePicker(
                                        context,
                                        currentTime: DateTime.now(),
                                        locale: dateTimePicker.LocaleType.tw,
                                        showTitleActions: true,
                                        onConfirm: (date) {
                                          setState(() {
                                            startDatetime = date;
                                            // Change end time to start time plus an hour
                                            endDateTime = startDatetime
                                                .add(const Duration(hours: 1));
                                          });
                                        },
                                      );
                                    },
                                    child: Text(
                                      formattedDateAndTime
                                          .format(startDatetime),
                                      style: MyDialogTheme.dialogContentStyle,
                                    ),
                                  ),
                                )
                              : Tooltip(
                                  message: '選擇開始日期',
                                  child: TextButton(
                                    onPressed: () {
                                      dateTimePicker.DatePicker.showDatePicker(
                                        context,
                                        currentTime: DateTime.now(),
                                        locale: dateTimePicker.LocaleType.tw,
                                        showTitleActions: true,
                                        minTime: DateTime(1971, 1, 1),
                                        maxTime: DateTime(2030, 12, 31),
                                        onConfirm: (date) {
                                          setState(() {
                                            startDatetime = date;
                                            // Change end date to start date plus one day
                                            endDateTime = startDatetime
                                                .add(const Duration(days: 1));
                                          });
                                        },
                                      );
                                    },
                                    child: Text(
                                      formattedDate.format(startDatetime),
                                      style: MyDialogTheme.dialogContentStyle,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          isAllDay == false
                              ? Text(
                                  '結束時間',
                                  style: MyDialogTheme.dialogTitleStyle,
                                )
                              : Text(
                                  '結束日期',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                          // All day show date, not all day show date and time
                          isAllDay == false
                              ? Tooltip(
                                  message: '選擇結束時間',
                                  child: TextButton(
                                      onPressed: () {
                                        dateTimePicker.DatePicker
                                            .showDateTimePicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          locale: dateTimePicker.LocaleType.tw,
                                          showTitleActions: true,
                                          onConfirm: (date) {
                                            setState(() {
                                              endDateTime = date;
                                            });
                                          },
                                        );
                                      },
                                      child: Text(
                                        formattedDateAndTime
                                            .format(endDateTime),
                                        style: MyDialogTheme.dialogContentStyle,
                                      )),
                                )
                              : Tooltip(
                                  message: '選擇結束日期',
                                  child: TextButton(
                                      onPressed: () {
                                        dateTimePicker.DatePicker
                                            .showDatePicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          locale: dateTimePicker.LocaleType.tw,
                                          showTitleActions: true,
                                          minTime: DateTime(1971, 1, 1),
                                          maxTime: DateTime(2030, 12, 31),
                                          onConfirm: (date) {
                                            setState(() {
                                              endDateTime = date;
                                            });
                                          },
                                        );
                                      },
                                      child: Text(
                                        formattedDate.format(endDateTime),
                                        style: MyDialogTheme.dialogContentStyle,
                                      )),
                                ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '選擇活動顏色',
                            style: MyDialogTheme.dialogTitleStyle,
                          ),
                        ],
                      ),
                      ColorPicker(
                        enableShadesSelection: false,
                        pickersEnabled: const <ColorPickerType, bool>{
                          ColorPickerType.primary: true,
                          ColorPickerType.accent: false,
                        },
                        color: eventColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            eventColor = color;
                          });
                        },
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
                      onPressed: () async {
                        // End date must late than start date
                        if (startDatetime.isAfter(endDateTime)) {
                          Fluttertoast.showToast(
                              msg: "開始時間不能比結束時間晚",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: ColorSet.colorsWhite,
                              textColor: ColorSet.colorsBlackOfOpacity80,
                              fontSize: 16.0);
                        } else {
                          // Show toast if user doesn't input event name
                          if (eventNameController.text == '') {
                            Fluttertoast.showToast(
                                msg: "請輸入事件名稱",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: ColorSet.colorsWhite,
                                textColor: ColorSet.colorsBlackOfOpacity80,
                                fontSize: 16.0);
                          } else {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            Appointment newEvent = Appointment(
                              id: prefs.getInt('keyEventId'),
                              subject: eventNameController.text,
                              startTime: startDatetime,
                              endTime: endDateTime,
                              color: eventColor,
                              isAllDay: isAllDay,
                            );

                            /* Add event to database */
                            EventInfoDB.insertEvent(
                              EventInfo(
                                name: eventNameController.text,
                                startDate: formattedDateAndTime
                                    .format(startDatetime)
                                    .toString(),
                                endDate: formattedDateAndTime
                                    .format(endDateTime)
                                    .toString(),
                                color: eventColor.toString(),
                                isAllDay: isAllDay == false ? 0 : 1,
                              ),
                            );

                            /* Add event to calendar */
                            _dataSource.appointments!.add(newEvent);
                            _dataSource.notifyListeners(
                                CalendarDataSourceAction.add, [newEvent]);

                            eventId += 1;
                            prefs.setInt('keyEventId', eventId);
                            Navigator.pop(context, 'OK');
                          }
                        }
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
                ]);
          });
        });
  }

  /* Show event details on dialog */
  void _onTapShowEventDetails(CalendarTapDetails showEventDetails) {
    if (showEventDetails.targetElement == CalendarElement.appointment) {
      Appointment showEvent = showEventDetails.appointments![0];
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(
                        height: 30.0,
                      ),
                      Container(
                        width: 115.0,
                        child: Stack(
                          children: <Widget>[
                            Text(
                              '${formattedDate.format(showEvent.startTime)}',
                              style: const TextStyle(
                                color: ColorSet.colorsBlackOfOpacity80,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Show day range if start date and end date are not same day
                            showEvent.endTime
                                        .difference(showEvent.startTime)
                                        .inDays ==
                                    0
                                ? const SizedBox()
                                : Positioned(
                                    left: 93.0,
                                    top: 0.0,
                                    child: Text(
                                      '+${showEvent.endTime.difference(showEvent.startTime).inDays + 1}',
                                      style: const TextStyle(
                                        color: ColorSet
                                            .colorsDarkBlueGreenOfOpacity80,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Text(
                        showEvent.subject,
                        style: const TextStyle(
                          color: ColorSet.colorsDarkBlueGreenOfOpacity80,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // All day show date, not all day show date and time
                      showEvent.isAllDay == true
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '開始日期',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                                Text(
                                  '${formattedDate.format(showEvent.startTime)}',
                                  style: MyDialogTheme.dialogContentStyle,
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '開始時間',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                                Text(
                                  '${formattedDateAndTime.format(showEvent.startTime)}',
                                  style: MyDialogTheme.dialogContentStyle,
                                ),
                              ],
                            ),
                      const Divider(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // All day show date, not all day show date and time
                      showEvent.isAllDay == true
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '結束日期',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                                Text(
                                  '${formattedDate.format(showEvent.endTime)}',
                                  style: MyDialogTheme.dialogContentStyle,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '結束時間',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                                Text(
                                  '${formattedDateAndTime.format(showEvent.endTime)}',
                                  style: MyDialogTheme.dialogContentStyle,
                                ),
                              ],
                            ),
                      const Divider(),
                      const SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),
              );
            });
          });
    }
  }

  /* Show edit or delete event on dialog */
  void _onLongPressEditOrDelete(CalendarLongPressDetails editOrDeleteDetails) {
    if (editOrDeleteDetails.targetElement == CalendarElement.appointment) {
      Appointment editOrDeleteEvent = editOrDeleteDetails.appointments![0];
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Tooltip(
                      message: '編輯活動',
                      child: TextButton.icon(
                          onPressed: () {
                            // Get event details on edit page
                            editEventNameController.text =
                                editOrDeleteEvent.subject;
                            editEventColor = editOrDeleteEvent.color;
                            editIsAllDay = editOrDeleteEvent.isAllDay;
                            editStartDatetime = editOrDeleteEvent.startTime;
                            editEndDateTime = editOrDeleteEvent.endTime;
                            _editEvent(editOrDeleteDetails);
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
                      message: '刪除事件',
                      child: TextButton.icon(
                          onPressed: () {
                            _deleteEvent(editOrDeleteDetails);
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
  }

  /* Edit event on alert dialog */
  void _editEvent(CalendarLongPressDetails editEventDetails) {
    Appointment editEvent = editEventDetails.appointments![0];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        style: MyDialogTheme.dialogContentStyle,
                        textAlign: TextAlign.end,
                        textAlignVertical: TextAlignVertical.center,
                        controller: editEventNameController,
                        focusNode: editEventNameFocusNode,
                        cursorColor: ColorSet.colorsDarkBlueGreenOfOpacity80,
                        onEditingComplete: () {
                          editEventNameFocusNode.unfocus();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Text(
                            '輸入活動名稱',
                            style: MyDialogTheme.dialogTitleStyle,
                          ),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '是否全天',
                            style: MyDialogTheme.dialogTitleStyle,
                          ),
                          Switch(
                              value: editIsAllDay,
                              inactiveThumbColor:
                                  ColorSet.colorsWhiteGrayOfOpacity80,
                              inactiveTrackColor:
                                  ColorSet.colorsWhiteGrayOfOpacity80,
                              activeThumbColor:
                                  ColorSet.colorsDarkBlueGreenOfOpacity80,
                              activeTrackColor:
                                  ColorSet.colorsWhiteGrayOfOpacity80,
                              onChanged: (value) {
                                setState(() {
                                  editIsAllDay = value;
                                });
                              }),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          editIsAllDay == false
                              ? Text(
                                  '開始時間',
                                  style: MyDialogTheme.dialogTitleStyle,
                                )
                              : Text(
                                  '開始日期',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                          // All day show date, not all day show date and time
                          editIsAllDay == false
                              ? Tooltip(
                                  message: '選擇開始時間',
                                  child: TextButton(
                                      onPressed: () {
                                        dateTimePicker.DatePicker
                                            .showDateTimePicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          locale: dateTimePicker.LocaleType.tw,
                                          showTitleActions: true,
                                          onConfirm: (date) {
                                            setState(() {
                                              editStartDatetime = date;
                                              // Change end time to start time plus an hour
                                              editEndDateTime =
                                                  editStartDatetime.add(
                                                      const Duration(hours: 1));
                                            });
                                          },
                                        );
                                      },
                                      child: Text(
                                        formattedDateAndTime
                                            .format(editStartDatetime),
                                        style: MyDialogTheme.dialogContentStyle,
                                      )),
                                )
                              : Tooltip(
                                  message: '選擇開始日期',
                                  child: TextButton(
                                    onPressed: () {
                                      dateTimePicker.DatePicker.showDatePicker(
                                        context,
                                        currentTime: DateTime.now(),
                                        locale: dateTimePicker.LocaleType.tw,
                                        showTitleActions: true,
                                        minTime: DateTime(1971, 1, 1),
                                        maxTime: DateTime(2030, 12, 31),
                                        onConfirm: (date) {
                                          setState(() {
                                            editStartDatetime = date;
                                            // Change end date to start date plus one day
                                            editEndDateTime = editStartDatetime
                                                .add(const Duration(days: 1));
                                          });
                                        },
                                      );
                                    },
                                    child: Text(
                                      formattedDate.format(editStartDatetime),
                                      style: MyDialogTheme.dialogContentStyle,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          editIsAllDay == false
                              ? Text(
                                  '結束時間',
                                  style: MyDialogTheme.dialogTitleStyle,
                                )
                              : Text(
                                  '結束日期',
                                  style: MyDialogTheme.dialogTitleStyle,
                                ),
                          // All day show date, not all day show date and time
                          editIsAllDay == false
                              ? Tooltip(
                                  message: '選擇結束時間',
                                  child: TextButton(
                                      onPressed: () {
                                        dateTimePicker.DatePicker
                                            .showDateTimePicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          locale: dateTimePicker.LocaleType.tw,
                                          showTitleActions: true,
                                          onConfirm: (date) {
                                            setState(() {
                                              editEndDateTime = date;
                                            });
                                          },
                                        );
                                      },
                                      child: Text(
                                        formattedDateAndTime
                                            .format(editEndDateTime),
                                        style: MyDialogTheme.dialogContentStyle,
                                      )),
                                )
                              : Tooltip(
                                  message: '選擇結束日期',
                                  child: TextButton(
                                      onPressed: () {
                                        dateTimePicker.DatePicker
                                            .showDatePicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          locale: dateTimePicker.LocaleType.tw,
                                          showTitleActions: true,
                                          minTime: DateTime(1971, 1, 1),
                                          maxTime: DateTime(2030, 12, 31),
                                          onConfirm: (date) {
                                            setState(() {
                                              editEndDateTime = date;
                                            });
                                          },
                                        );
                                      },
                                      child: Text(
                                        formattedDate.format(editEndDateTime),
                                        style: MyDialogTheme.dialogContentStyle,
                                      )),
                                ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '選擇活動顏色',
                            style: MyDialogTheme.dialogTitleStyle,
                          ),
                        ],
                      ),
                      ColorPicker(
                        enableShadesSelection: false,
                        pickersEnabled: const <ColorPickerType, bool>{
                          ColorPickerType.primary: true,
                          ColorPickerType.accent: false,
                        },
                        color: editEventColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            editEventColor = color;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                      Navigator.pop(context, 'Cancel');
                    },
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
                      onPressed: () async {
                        // end date must late than start date
                        if (editStartDatetime.isAfter(editEndDateTime)) {
                          Fluttertoast.showToast(
                              msg: "開始時間不能比結束時間晚",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: ColorSet.colorsWhite,
                              textColor: ColorSet.colorsBlackOfOpacity80,
                              fontSize: 16.0);
                        } else {
                          if (editEventNameController.text == '') {
                            Fluttertoast.showToast(
                                msg: "請輸入事件名稱",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: ColorSet.colorsWhite,
                                textColor: ColorSet.colorsBlackOfOpacity80,
                                fontSize: 16.0);
                          } else {
                            /* Delete event than add new one */
                            // Delete event in calendar
                            _dataSource.appointments!.removeAt(
                                _dataSource.appointments!.indexOf(editEvent));
                            _dataSource.notifyListeners(
                                CalendarDataSourceAction.remove, [editEvent]);
                            // Delete event in database
                            EventInfoDB.deleteEvent(
                                int.parse(editEvent.id.toString()));

                            // Add event to calendar
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            Appointment editNewEvent = Appointment(
                              id: prefs.getInt('keyEventId'),
                              subject: editEventNameController.text,
                              startTime: editStartDatetime,
                              endTime: editEndDateTime,
                              color: editEventColor,
                              isAllDay: editIsAllDay,
                            );
                            _dataSource.appointments!.add(editNewEvent);
                            _dataSource.notifyListeners(
                                CalendarDataSourceAction.add, [editNewEvent]);

                            // Add event to database
                            EventInfoDB.insertEvent(EventInfo(
                              name: editEventNameController.text,
                              startDate: formattedDateAndTime
                                  .format(editStartDatetime)
                                  .toString(),
                              endDate: formattedDateAndTime
                                  .format(editEndDateTime)
                                  .toString(),
                              color: editEventColor.toString(),
                              isAllDay: editIsAllDay == false ? 0 : 1,
                            ));

                            eventId += 1;
                            prefs.setInt('keyEventId', eventId);
                            // back to calendar page
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        }
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
                ]);
          });
        });
  }

  /* Delete event on calendar */
  void _deleteEvent(CalendarLongPressDetails deleteEventDetails) {
    Appointment deleteEvent = deleteEventDetails.appointments![0];
    setState(() {
      _dataSource.appointments!
          .removeAt(_dataSource.appointments!.indexOf(deleteEvent));
      _dataSource
          .notifyListeners(CalendarDataSourceAction.remove, [deleteEvent]);
    });
    EventInfoDB.deleteEvent(int.parse(deleteEvent.id.toString()));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _futureWaitingData,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
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
                            '行事曆',
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
                                    color:
                                        ColorSet.primaryColorsGreenOfOpacity80,
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
                                  margin: const EdgeInsets.only(
                                      top: 55.0, bottom: 17.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SfCalendar(
                                      view: CalendarView.week,
                                      headerDateFormat: 'yyy - MMM',
                                      firstDayOfWeek:
                                          calendarPageFirstDayOfWeek,
                                      minDate: DateTime(1971, 01, 01),
                                      maxDate: DateTime(2030, 12, 31),
                                      initialDisplayDate: DateTime.now(),
                                      headerHeight: 30,
                                      todayHighlightColor: ColorSet
                                          .colorsDarkBlueGreenOfOpacity80,
                                      cellBorderColor: ColorSet.colorsWhite,
                                      backgroundColor: ColorSet
                                          .primaryColorsGreenOfOpacity80,
                                      showDatePickerButton: true,
                                      showCurrentTimeIndicator: true,
                                      showWeekNumber:
                                          calendarPageShowWeekNumber,
                                      dataSource: _dataSource,
                                      onTap: _onTapShowEventDetails,
                                      onLongPress: _onLongPressEditOrDelete,
                                      headerStyle: const CalendarHeaderStyle(
                                        textStyle: const TextStyle(
                                          fontSize: 17.0,
                                          color:
                                              ColorSet.colorsBlackOfOpacity80,
                                        ),
                                      ),
                                      timeSlotViewSettings:
                                          TimeSlotViewSettings(
                                              timeIntervalHeight: 35.0,
                                              timeTextStyle: const TextStyle(
                                                color: ColorSet.colorsWhite,
                                              ),
                                              timeFormat:
                                                  calendarPageIs24hourSystem ==
                                                          true
                                                      ? 'HH'
                                                      : 'hh a'),
                                      weekNumberStyle: const WeekNumberStyle(
                                        backgroundColor: ColorSet
                                            .colorsDarkBlueGreenOfOpacity80,
                                        textStyle: const TextStyle(
                                            color: ColorSet.colorsWhite,
                                            fontSize: 15),
                                      ),
                                      selectionDecoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorSet
                                                .colorsDarkBlueGreenOfOpacity80,
                                            width: 2),
                                      ),
                                      todayTextStyle: const TextStyle(
                                        color: ColorSet.colorsWhite,
                                      ),
                                      viewHeaderStyle: const ViewHeaderStyle(
                                        dateTextStyle: const TextStyle(
                                          color: ColorSet.colorsWhite,
                                        ),
                                        dayTextStyle: const TextStyle(
                                          color: ColorSet.colorsWhite,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 540.0,
                                  child: Card(
                                    color:
                                        ColorSet.primaryColorsGreenOfOpacity80,
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
                          tooltip: '新增事件',
                          backgroundColor: ColorSet.colorsWhite,
                          child: const Icon(
                            Icons.add_outlined,
                            color: ColorSet.colorsDarkBlueGreenOfOpacity80,
                            size: 30.0,
                          ),
                          onPressed: () {
                            setState(() {
                              eventNameController.text = '';
                              eventColor = const Color(0xfff44336);
                              isAllDay = false;
                              startDatetime = DateTime.now();
                              endDateTime =
                                  DateTime.now().add(const Duration(hours: 1));
                              _addEvent();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
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
                            '行事曆',
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
                                    color:
                                        ColorSet.primaryColorsGreenOfOpacity80,
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
                                  margin: const EdgeInsets.only(
                                      top: 55.0, bottom: 17.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Text(
                                          '載入資料中',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: ColorSet.colorsWhite,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 25.0,
                                        ),
                                        const Center(
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 3.0,
                                            color: ColorSet
                                                .colorsWhiteGrayOfOpacity80,
                                            backgroundColor: ColorSet
                                                .colorsDarkBlueGreenOfOpacity80,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 540.0,
                                  child: Card(
                                    color:
                                        ColorSet.primaryColorsGreenOfOpacity80,
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
                          tooltip: '新增事件',
                          backgroundColor: ColorSet.colorsWhite,
                          child: const Icon(
                            Icons.add_outlined,
                            color: ColorSet.colorsDarkBlueGreenOfOpacity80,
                            size: 30.0,
                          ),
                          onPressed: () {
                            setState(() {
                              eventNameController.text = '';
                              eventColor = const Color(0xfff44336);
                              isAllDay = false;
                              startDatetime = DateTime.now();
                              endDateTime =
                                  DateTime.now().add(const Duration(hours: 1));
                              _addEvent();
                            });
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
      },
    );
  }
}
