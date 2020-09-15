import 'package:melembra/app/database/dao/reminder_dao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDatabase() async {

  final String path = join(await getDatabasesPath(), 'melembra.db');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(ReminderDao.tableSql);
    },
    version: 1,
  );

}