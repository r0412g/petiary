import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class EventInfo {
  final String name;
  final String startDate;
  final String endDate;
  final String color;
  final int isAllDay;

  EventInfo({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.isAllDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'color': color,
      'isAllDay': isAllDay,
    };
  }

  @override
  String toString() {
    return "{name: $name, startDate: $startDate, endDate: $endDate, color: $color, isAllDay: $isAllDay}";
  }
}

class EventInfoDB {
  /* Open database */
  static Future<Database> initDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'eventDatabase.db'),
      /* Create Event table */
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE Event("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "name TEXT, "
          "startDate TEXT, "
          "endDate TEXT, "
          "color TEXT, "
          "isAllDay INTEGER)",
        );
      },
      version: 1,
    );
    return database;
  }

  /* Insert a pet into the database */
  static Future<void> insertEvent(EventInfo eventInfo) async {
    final db = await initDatabase();
    await db.insert(
      'Event',
      eventInfo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /* Retrieve the list of Event */
  static Future<List<EventInfo>> queryEvent() async {
    final Database db = await initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('Event');
    return List.generate(maps.length, (i) {
      return EventInfo(
        name: maps[i]['name'],
        startDate: maps[i]['startDate'],
        endDate: maps[i]['endDate'],
        color: maps[i]['color'],
        isAllDay: maps[i]['isAllDay'],
      );
    });
  }
}
