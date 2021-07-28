import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:pet_diary/database/event_db.dart';
import 'package:pet_diary/models/setting_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

/* Database */
class DB {
  static void addEvent(String name, String startDate, String endDate,
      String color, int isAllDay) async {
    final newEvent = EventInfo(
      name: name,
      startDate: startDate,
      endDate: endDate,
      color: color,
      isAllDay: isAllDay,
    );
    await EventInfoDB.insertEvent(newEvent);
  }
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

  // Color to String
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class _CalendarPageState extends State<CalendarPage> {
  FocusNode eventNameFocusNode = new FocusNode();
  FocusNode editEventNameFocusNode = new FocusNode();
  TextEditingController eventNameController = TextEditingController();
  TextEditingController editEventNameController = TextEditingController();
  final formattedDateAndTime = DateFormat('yyyy-MM-dd HH:mm');
  final formattedDate = DateFormat('yyyy-MM-dd');
  DateTime startDatetime = DateTime.now();
  DateTime editStartDatetime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  DateTime editEndDateTime = DateTime.now();
  Color eventColor = Color(0xfff44336);
  Color editEventColor = Color(0xfff44336);
  bool isAllDay = false;
  bool editIsAllDay = false;
  CalendarDataSource _dataSource = EventDataSource(<Appointment>[]);
  int eventId = 1;

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }

  _loadData(context) async {
    SettingModel mySet = Provider.of<SettingModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mySet.setFirstDayOfWeek(prefs.getInt('keyFirstDayOfWeek') ?? 7);
      mySet.setShowWeekNumber(prefs.getBool('keyShowWeekNumber') ?? false);
      mySet.setIs24hourSystem(prefs.getBool('keyIs24hourSystem') ?? true);
    });
    eventId = prefs.getInt('keyEventId') ?? 1;

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

  /* Clean up the controller when the widget is disposed */
  @override
  void dispose() {
    eventNameController.dispose();
    editEventNameController.dispose();
    super.dispose();
  }

  /* Add event on calendar */
  _addEvent() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: Container(
                  color: ColorSet.secondaryColors,
                  alignment: Alignment.center,
                  child: const Text('新增事件'),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: eventNameController,
                        focusNode: eventNameFocusNode,
                        cursorColor: ColorSet.primaryLightColors,
                        onEditingComplete: () {
                          eventNameFocusNode.unfocus();
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.event_note_outlined,
                              color: ColorSet.primaryLightColors),
                          hintText: '點擊輸入事件名稱',
                        ),
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
                        heading: Text(
                          '選擇事件顏色',
                          style: TextStyle(
                              fontSize: 15.0,
                              backgroundColor: ColorSet.secondaryColors),
                        ),
                      ),
                      SwitchListTile(
                          title: Text('整天?'),
                          subtitle: isAllDay == true
                              ? const Text('是')
                              : const Text('否'),
                          value: isAllDay,
                          activeColor: ColorSet.primaryLightColors,
                          onChanged: (value) {
                            setState(() {
                              isAllDay = value;
                            });
                          }),
                      Row(
                        children: <Widget>[
                          isAllDay == false ? Text('開始時間：') : Text('開始日期：'),
                          // All day show date, not all day show date and time
                          isAllDay == false
                              ? Container(
                                  child: Expanded(
                                    child: Tooltip(
                                      message: '選擇開始時間',
                                      child: TextButton.icon(
                                          onPressed: () {
                                            DatePicker.showDateTimePicker(
                                              context,
                                              currentTime: DateTime.now(),
                                              locale: LocaleType.tw,
                                              showTitleActions: true,
                                              onConfirm: (date) {
                                                setState(() {
                                                  startDatetime = date;
                                                  // Change end time to start time plus an hour
                                                  endDateTime = startDatetime
                                                      .add(Duration(hours: 1));
                                                });
                                              },
                                              theme: DatePickerTheme(
                                                cancelStyle: const TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.calendar_today,
                                              color:
                                                  ColorSet.primaryLightColors),
                                          label: Text(
                                            formattedDateAndTime
                                                .format(startDatetime),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Expanded(
                                      child: Tooltip(
                                    message: '選擇開始日期',
                                    child: TextButton.icon(
                                      onPressed: () {
                                        DatePicker.showDatePicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          locale: LocaleType.tw,
                                          showTitleActions: true,
                                          minTime: DateTime(1971, 1, 1),
                                          maxTime: DateTime(2030, 12, 31),
                                          onConfirm: (date) {
                                            setState(() {
                                              startDatetime = date;
                                              // Change end date to start date plus one day
                                              endDateTime = startDatetime
                                                  .add(Duration(days: 1));
                                            });
                                          },
                                          theme: DatePickerTheme(
                                            cancelStyle: const TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.calendar_today,
                                          color: ColorSet.primaryLightColors),
                                      label: Text(
                                        formattedDate.format(startDatetime),
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  )),
                                ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          isAllDay == false ? Text('結束時間：') : Text('結束日期：'),
                          // All day show date, not all day show date and time
                          isAllDay == false
                              ? Container(
                                  child: Expanded(
                                    child: Tooltip(
                                      message: '選擇結束時間',
                                      child: TextButton.icon(
                                          onPressed: () {
                                            DatePicker.showDateTimePicker(
                                              context,
                                              currentTime: DateTime.now(),
                                              locale: LocaleType.tw,
                                              showTitleActions: true,
                                              onConfirm: (date) {
                                                setState(() {
                                                  endDateTime = date;
                                                });
                                              },
                                              theme: DatePickerTheme(
                                                cancelStyle: const TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.calendar_today,
                                              color:
                                                  ColorSet.primaryLightColors),
                                          label: Text(
                                            formattedDateAndTime
                                                .format(endDateTime),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Expanded(
                                      child: Tooltip(
                                    message: '選擇結束日期',
                                    child: TextButton.icon(
                                        onPressed: () {
                                          DatePicker.showDatePicker(
                                            context,
                                            currentTime: DateTime.now(),
                                            locale: LocaleType.tw,
                                            showTitleActions: true,
                                            minTime: DateTime(1971, 1, 1),
                                            maxTime: DateTime(2030, 12, 31),
                                            onConfirm: (date) {
                                              setState(() {
                                                endDateTime = date;
                                              });
                                            },
                                            theme: DatePickerTheme(
                                              cancelStyle: const TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.calendar_today,
                                            color: ColorSet.primaryLightColors),
                                        label: Text(
                                          formattedDate.format(endDateTime),
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )),
                                  )),
                                ),
                        ],
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
                    onPressed: () async {
                      if (eventNameController.text == '') {
                        Fluttertoast.showToast(
                            msg: "請輸入事件名稱",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
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
                        DB.addEvent(
                          eventNameController.text,
                          formattedDateAndTime.format(startDatetime).toString(),
                          formattedDateAndTime.format(endDateTime).toString(),
                          eventColor.toHex(),
                          isAllDay == false ? 0 : 1,
                        );

                        /* Add event to calendar */
                        _dataSource.appointments!.add(newEvent);
                        _dataSource.notifyListeners(
                            CalendarDataSourceAction.add, [newEvent]);

                        eventId += 1;
                        prefs.setInt('keyEventId', eventId);
                        Navigator.pop(context, 'OK');
                      }
                    },
                    child: const Text('確定'),
                  ),
                ]);
          });
        });
  }

  /* Show event details on dialog */
  _onTapShowEventDetails(CalendarTapDetails showEventDetails) {
    if (showEventDetails.targetElement == CalendarElement.appointment) {
      Appointment showEvent = showEventDetails.appointments![0];
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                backgroundColor: showEvent.color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: SingleChildScrollView(
                  child: Card(
                    margin: EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          showEvent.subject,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        // All day show date, not all day show date and time
                        showEvent.isAllDay == true
                            ? Text(
                                '開始日期：${formattedDate.format(showEvent.startTime)}',
                                style: TextStyle(fontSize: 15.0),
                              )
                            : Text(
                                '開始時間：${formattedDateAndTime.format(showEvent.startTime)}',
                                style: TextStyle(fontSize: 15.0),
                              ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        // All day show date, not all day show date and time
                        showEvent.isAllDay == true
                            ? Text(
                                '結束日期：${formattedDate.format(showEvent.endTime)}',
                                style: TextStyle(fontSize: 15.0),
                              )
                            : Text(
                                '結束時間：${formattedDateAndTime.format(showEvent.endTime)}',
                                style: TextStyle(fontSize: 15.0),
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
  }

  /* Show edit or delete event on dialog */
  _onLongPressEditOrDelete(CalendarLongPressDetails editOrDeleteDetails) {
    if (editOrDeleteDetails.targetElement == CalendarElement.appointment) {
      Appointment editOrDeleteEvent = editOrDeleteDetails.appointments![0];
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                backgroundColor: editOrDeleteEvent.color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: SingleChildScrollView(
                  child: Card(
                    margin: EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    color: Colors.white,
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
                                // Get event details on edit page
                                editEventNameController.text =
                                    editOrDeleteEvent.subject;
                                editEventColor = editOrDeleteEvent.color;
                                editIsAllDay = editOrDeleteEvent.isAllDay;
                                editStartDatetime = editOrDeleteEvent.startTime;
                                editEndDateTime = editOrDeleteEvent.endTime;
                                _editEvent(editOrDeleteDetails);
                              },
                              icon: Icon(
                                Icons.edit_outlined,
                                color: Colors.black,
                              ),
                              label: Text(
                                '編輯',
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        Tooltip(
                          message: '刪除事件',
                          child: TextButton.icon(
                              onPressed: () {
                                _deleteEvent(editOrDeleteDetails);
                              },
                              icon: Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.black,
                              ),
                              label: Text(
                                '刪除',
                                style: TextStyle(color: Colors.black),
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
  }

  /* Edit event on alert dialog */
  _editEvent(CalendarLongPressDetails editEventDetails) {
    Appointment editEvent = editEventDetails.appointments![0];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: Container(
                  color: ColorSet.secondaryColors,
                  alignment: Alignment.center,
                  child: const Text('編輯事件'),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: editEventNameController,
                        focusNode: editEventNameFocusNode,
                        cursorColor: ColorSet.primaryLightColors,
                        onEditingComplete: () {
                          editEventNameFocusNode.unfocus();
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.event_note_outlined,
                              color: ColorSet.primaryLightColors),
                          hintText: '點擊輸入事件名稱',
                        ),
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
                        heading: Text(
                          '選擇事件顏色',
                          style: TextStyle(
                              fontSize: 15.0,
                              backgroundColor: ColorSet.secondaryColors),
                        ),
                      ),
                      SwitchListTile(
                          title: Text('整天?'),
                          subtitle: editIsAllDay == true
                              ? const Text('是')
                              : const Text('否'),
                          value: editIsAllDay,
                          activeColor: ColorSet.primaryLightColors,
                          onChanged: (value) {
                            setState(() {
                              editIsAllDay = value;
                            });
                          }),
                      Row(
                        children: <Widget>[
                          editIsAllDay == false ? Text('開始時間：') : Text('開始日期：'),
                          // All day show date, not all day show date and time
                          editIsAllDay == false
                              ? Container(
                                  child: Expanded(
                                    child: Tooltip(
                                      message: '選擇開始時間',
                                      child: TextButton.icon(
                                          onPressed: () {
                                            DatePicker.showDateTimePicker(
                                              context,
                                              currentTime: DateTime.now(),
                                              locale: LocaleType.tw,
                                              showTitleActions: true,
                                              onConfirm: (date) {
                                                setState(() {
                                                  editStartDatetime = date;
                                                  // Change end time to start time plus an hour
                                                  editEndDateTime =
                                                      editStartDatetime.add(
                                                          Duration(hours: 1));
                                                });
                                              },
                                              theme: DatePickerTheme(
                                                cancelStyle: const TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.calendar_today,
                                              color:
                                                  ColorSet.primaryLightColors),
                                          label: Text(
                                            formattedDateAndTime
                                                .format(editStartDatetime),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Expanded(
                                      child: Tooltip(
                                    message: '選擇開始日期',
                                    child: TextButton.icon(
                                      onPressed: () {
                                        DatePicker.showDatePicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          locale: LocaleType.tw,
                                          showTitleActions: true,
                                          minTime: DateTime(1971, 1, 1),
                                          maxTime: DateTime(2030, 12, 31),
                                          onConfirm: (date) {
                                            setState(() {
                                              editStartDatetime = date;
                                              // Change end date to start date plus one day
                                              editEndDateTime =
                                                  editStartDatetime
                                                      .add(Duration(days: 1));
                                            });
                                          },
                                          theme: DatePickerTheme(
                                            cancelStyle: const TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.calendar_today,
                                          color: ColorSet.primaryLightColors),
                                      label: Text(
                                        formattedDate.format(editStartDatetime),
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  )),
                                ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          editIsAllDay == false ? Text('結束時間：') : Text('結束日期：'),
                          // All day show date, not all day show date and time
                          editIsAllDay == false
                              ? Container(
                                  child: Expanded(
                                    child: Tooltip(
                                      message: '選擇結束時間',
                                      child: TextButton.icon(
                                          onPressed: () {
                                            DatePicker.showDateTimePicker(
                                              context,
                                              currentTime: DateTime.now(),
                                              locale: LocaleType.tw,
                                              showTitleActions: true,
                                              onConfirm: (date) {
                                                setState(() {
                                                  editEndDateTime = date;
                                                });
                                              },
                                              theme: DatePickerTheme(
                                                cancelStyle: const TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.calendar_today,
                                              color:
                                                  ColorSet.primaryLightColors),
                                          label: Text(
                                            formattedDateAndTime
                                                .format(editEndDateTime),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Expanded(
                                      child: Tooltip(
                                    message: '選擇結束日期',
                                    child: TextButton.icon(
                                        onPressed: () {
                                          DatePicker.showDatePicker(
                                            context,
                                            currentTime: DateTime.now(),
                                            locale: LocaleType.tw,
                                            showTitleActions: true,
                                            minTime: DateTime(1971, 1, 1),
                                            maxTime: DateTime(2030, 12, 31),
                                            onConfirm: (date) {
                                              setState(() {
                                                editEndDateTime = date;
                                              });
                                            },
                                            theme: DatePickerTheme(
                                              cancelStyle: const TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.calendar_today,
                                            color: ColorSet.primaryLightColors),
                                        label: Text(
                                          formattedDate.format(editEndDateTime),
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )),
                                  )),
                                ),
                        ],
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
                    onPressed: () async {
                      if (editEventNameController.text == '') {
                        Fluttertoast.showToast(
                            msg: "請輸入事件名稱",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
                      } else {
                        /* Delete event than add new one */
                        // Delete event in calendar
                        _dataSource.appointments!.removeAt(
                            _dataSource.appointments!.indexOf(editEvent));
                        _dataSource.notifyListeners(
                            CalendarDataSourceAction.remove, [editEvent]);
                        // Delete event in database
                        EventInfoDB.delete(int.parse(editEvent.id.toString()));

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
                        DB.addEvent(
                          editEventNameController.text,
                          formattedDateAndTime
                              .format(editStartDatetime)
                              .toString(),
                          formattedDateAndTime
                              .format(editEndDateTime)
                              .toString(),
                          editEventColor.toHex(),
                          editIsAllDay == false ? 0 : 1,
                        );

                        eventId += 1;
                        prefs.setInt('keyEventId', eventId);
                        // back to page calendar
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                    child: const Text('確定'),
                  ),
                ]);
          });
        });
  }

  /* Delete event on calendar */
  _deleteEvent(CalendarLongPressDetails deleteEventDetails) {
    Appointment deleteEvent = deleteEventDetails.appointments![0];
    setState(() {
      _dataSource.appointments!
          .removeAt(_dataSource.appointments!.indexOf(deleteEvent));
      _dataSource
          .notifyListeners(CalendarDataSourceAction.remove, [deleteEvent]);
    });
    EventInfoDB.delete(int.parse(deleteEvent.id.toString()));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var mySet = Provider.of<SettingModel>(context);
    return Scaffold(
      body: Center(
        child: SfCalendar(
          view: CalendarView.week,
          headerDateFormat: 'yyy - MMM',
          firstDayOfWeek: mySet.getFirstDayOfWeek,
          minDate: DateTime(1971, 01, 01),
          maxDate: DateTime(2030, 12, 31),
          initialDisplayDate: DateTime.now(),
          headerHeight: 45,
          todayHighlightColor: ColorSet.secondaryDarkColors,
          showDatePickerButton: true,
          showCurrentTimeIndicator: true,
          showWeekNumber: mySet.getShowWeekNumber,
          dataSource: _dataSource,
          onTap: _onTapShowEventDetails,
          onLongPress: _onLongPressEditOrDelete,
          timeSlotViewSettings: TimeSlotViewSettings(
              timeIntervalHeight: 50.0,
              timeFormat: mySet.getIs24hourSystem == true ? 'HH:mm' : 'hh a'),
          weekNumberStyle: const WeekNumberStyle(
            backgroundColor: ColorSet.primaryLightColors,
            textStyle: TextStyle(color: Colors.white, fontSize: 15),
          ),
          selectionDecoration: BoxDecoration(
            border: Border.all(color: ColorSet.primaryLightColors, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            shape: BoxShape.rectangle,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '新增事件',
        backgroundColor: ColorSet.secondaryColors,
        onPressed: () {
          setState(() {
            eventNameController.text = '';
            eventColor = Color(0xfff44336);
            isAllDay = false;
            startDatetime = DateTime.now();
            endDateTime = DateTime.now().add(Duration(hours: 1));
            _addEvent();
          });
        },
        child: Icon(
          Icons.add_outlined,
          color: ColorSet.primaryColors,
        ),
      ),
    );
  }
}
