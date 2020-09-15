
import 'package:intl/intl.dart';
import 'package:melembra/app/models/reminder.dart';
import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class ReminderDao {

  static const String _tableName = 'reminders';
  static const String _id = 'id';
  static const String _description = 'description';
  static const String _dateTime = 'dateTime';

  static const String tableSql = 'CREATE TABLE $_tableName ( '
      '$_id INTEGER PRIMARY KEY, '
      '$_description TEXT, '
      '$_dateTime TEXT)';

  Future<int> save(Reminder reminder) async {
    final Database db = await getDatabase();
    Map<String, dynamic> reminderMap = _toMap(reminder);
    return db.insert(_tableName, reminderMap);
  }

  Future<int> update(Reminder reminder) async {
    final Database db = await getDatabase();
    Map<String, dynamic> reminderMap = _toMap(reminder);
    return db.update(_tableName, reminder.toMap(), where: '$_id = ?', whereArgs: [reminder.id]);
  }

  Future<int> delete(Reminder reminder) async {
    final Database db = await getDatabase();
    return db.delete(_tableName, where: '$_id = ?', whereArgs: [reminder.id]);
  }

  Map<String, dynamic> _toMap(Reminder reminder) {
    final Map<String, dynamic> reminderMap = Map();
    reminderMap[_description] = reminder.description;
    reminderMap[_dateTime] = reminder.dateTime;
    return reminderMap;
  }

  Future<List<Reminder>> findAll() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> results = await db.query(_tableName);
    List<Reminder> reminders = _toList(results);

    reminders.removeWhere((element) =>
        new DateTime.now().isAfter(DateFormat('HH:mm dd/MM/yyyy').parse(element.dateTime)));

    return reminders;

  }

  List<Reminder> _toList(List<Map<String, dynamic>> results) {
    final List<Reminder> reminders = List();
    for (Map<String, dynamic> row in results) {
      final Reminder reminder = new Reminder(
        row[_id],
        row[_description],
        row[_dateTime],
      );
      reminders.add(reminder);
    }
    return reminders;
  }

}