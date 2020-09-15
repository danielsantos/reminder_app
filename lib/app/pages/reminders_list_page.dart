import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melembra/app/components/reminder_item_component.dart';
import 'package:melembra/app/database/dao/reminder_dao.dart';
import 'package:melembra/app/models/reminder.dart';

class RemindersList extends StatelessWidget {

  final ReminderDao _dao = new ReminderDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lembretes Cadastrados'),
      ),
      body: FutureBuilder(
        future: _dao.findAll(),
        builder: (context, snapshot) {

          switch(snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Loading')
                  ],
                ),
              );
              break;
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              final List<Reminder> reminders = snapshot.data;
              return ListView.builder(
                  itemBuilder: (context, index) {
                    final Reminder reminder = reminders[index];
                    return ReminderItem(reminder);
                  },
                  itemCount: reminders.length
              );
              break;
          }

          return Text('Unknow error');

        },
      )

    );
  }
}
