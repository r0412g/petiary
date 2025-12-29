import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MedicalRecords {
  final String date;
  final int isMedicine;
  final String medicine;
  final double weight;
  final String remark;

  MedicalRecords({
    required this.date,
    required this.isMedicine,
    required this.medicine,
    required this.weight,
    required this.remark,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'isMedicine': isMedicine,
      'medicine': medicine,
      'weight': weight,
      'remark': remark,
    };
  }
}

class MedicalInfoDB {
  /* Open database */
  static Future<Database> initDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'medicalDatabase.db'),
      /* Create Medical table */
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE Medical("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "date TEXT, "
          "isMedicine INTEGER, "
          "medicine TEXT, "
          "weight DOUBLE, "
          "remark TEXT)",
        );
      },
      version: 1,
    );
    return database;
  }

  /* Insert medical records to the database */
  static Future<void> insertMedicalRecords(
      MedicalRecords medicalRecords) async {
    final db = await initDatabase();
    await db.insert(
      'Medical',
      medicalRecords.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /* Query medical records */
  static Future<List<Map<String, Object?>>> queryMedicalRecords() async {
    final db = await initDatabase();
    List<Map<String, Object?>> records = await db.query('Medical');
    return records;
  }

  /* Delete medical records */
  static Future<int> deleteMedicalRecords(int id) async {
    final db = await initDatabase();
    return await db.delete('Medical', where: 'id = ?', whereArgs: [id]);
  }

  /* Update medical records */
  static Future<int> updateMedicalRecords(
      MedicalRecords medicalRecords, int id) async {
    final db = await initDatabase();
    return await db.update('Medical', medicalRecords.toMap(),
        where: 'id = ?', whereArgs: [id]);
  }

  /* Close database */
  static Future close() async {
    final db = await initDatabase();
    db.close();
  }
}
