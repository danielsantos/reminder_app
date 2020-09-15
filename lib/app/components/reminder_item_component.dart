

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:melembra/app/database/dao/reminder_dao.dart';
import 'package:melembra/app/models/reminder.dart';
import 'package:melembra/app/pages/home_page.dart';
import 'package:melembra/app/pages/reminders_list_page.dart';

class ReminderItem extends StatelessWidget {

  final ReminderDao _dao = new ReminderDao();
  final Reminder reminder;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ReminderItem(this.reminder);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          //Navigator.pop(context, reminder);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(reminder),
          ));
        },
        child: ListTile(
          trailing: IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {

              var description = reminder.description;

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Atenção'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Tem certeza que deseja apagar o lembrete "$description" ?'),
                          ],
                        ),
                      ),
                      actions: [
                        FlatButton(
                            child: Text('Confirmar'),
                            onPressed: () {
                              _dao.delete(reminder);
                              flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
                              flutterLocalNotificationsPlugin.cancel(reminder.id);
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => RemindersList()));
                            }
                        ),
                        FlatButton(
                          child: Text('Cancelar'),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    );
                  }
              );
            },
          ),
          title: Text(
            reminder.description,
            style: TextStyle(fontSize: 24.0),
          ),
          subtitle: Text(
            'Marcado para: ' + reminder.dateTime,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      )
    );
  }
}
