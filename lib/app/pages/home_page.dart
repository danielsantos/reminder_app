import 'package:admob_flutter/admob_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:melembra/app/database/dao/reminder_dao.dart';
import 'package:melembra/app/models/reminder.dart';
import 'package:melembra/app/pages/reminders_list_page.dart';

class HomePage extends StatefulWidget {
  final Reminder reminder;

  HomePage(this.reminder);

  @override
  _HomePageState createState() => _HomePageState(reminder);
}

class _HomePageState extends State<HomePage> {
  Reminder reminderParam;

  _HomePageState(this.reminderParam);

  AdmobBannerSize bannerSize;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final ReminderDao _dao = new ReminderDao();
  final format = DateFormat("HH:mm dd/MM/yyyy");
  var minutesToAlert;

  @override
  void initState() {
    super.initState();
    initializing();
    bannerSize = AdmobBannerSize.BANNER;

    if (reminderParam.id != 0) {
      _descriptionController.text = reminderParam.description;
      _dateTimeController.text = reminderParam.dateTime;
    }
  }

  void initializing() async {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, ios);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text('Notification'),
              content: new Text('$payload'),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80.0,
              child: DrawerHeader(
                child: Text('Menu'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              title: Text('Lembretes Cadastrados'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RemindersList(),
                ));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Me Lembra'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'O que deseja lembrar?',
              ),
              style: TextStyle(fontSize: 24.0),
            ),
            DateTimeField(
              controller: _dateTimeController,
              decoration: InputDecoration(labelText: 'Em que dia e hora?'),
              format: format,
              onShowPicker: (context, currentValue) async {
                final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );

                  DateTime dateToAlert = DateTimeField.combine(date, time);
                  Duration durationToShowAlert =
                      DateTime.now().difference(dateToAlert);
                  minutesToAlert = durationToShowAlert.inMinutes * -1;

                  return dateToAlert;
                } else {
                  return currentValue;
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 68.0, right: 8.0),
              child: SizedBox(
                width: double.maxFinite,
                child: RaisedButton(
                  child: Text('Salvar'),
                  onPressed: () {
                    if (_descriptionController.text.isEmpty ||
                        _dateTimeController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Preencha todos os campos",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      var now = new DateTime.now();
                      var dateOfReminder = DateFormat('HH:mm dd/MM/yyyy')
                          .parse(_dateTimeController.text);

                      if (now.isAfter(dateOfReminder)) {
                        Fluttertoast.showToast(
                            msg: "Dados Inválidos",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        final Reminder reminder = Reminder(
                            0,
                            _descriptionController.text,
                            _dateTimeController.text);

                        if (reminderParam.id == 0) {
                          Future<int> resultOfSave = _dao.save(reminder);

                          resultOfSave.then((id) {
                            showNotification(id);
                          });

                          //REFACT
                          Fluttertoast.showToast(
                              msg: "Lembrete salvo com sucesso!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green[300],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          _dao.update(new Reminder(
                              reminderParam.id,
                              _descriptionController.text,
                              _dateTimeController.text));

                          flutterLocalNotificationsPlugin
                              .cancel(reminderParam.id);
                          showNotification(reminderParam.id);

                          print('vamos atualizar!');

                          clearFields();

                          Fluttertoast.showToast(
                              msg: "Lembrete atualizado com sucesso!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }

                        reminderParam = new Reminder(0, '', '');
                      }
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child:
                  Container(child: getBanner(AdmobBannerSize.MEDIUM_RECTANGLE)),
            )
          ],
        ),
      ),
    );
  }

  showNotification(int id) async {
    var timeDelayed = DateTime.now().add(Duration(minutes: minutesToAlert));
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION');
    var ios = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, ios);

    await flutterLocalNotificationsPlugin.schedule(
      id,
      'Viemos te lembrar!',
      _descriptionController.text,
      timeDelayed,
      platform,
    );
    clearFields();
  }

  void clearFields() {
    _descriptionController.clear();
    _dateTimeController.clear();
  }
}

AdmobBanner getBanner(AdmobBannerSize size) {
  return AdmobBanner(
    adUnitId: 'ca-app-pub-3992962658517532/8458488721',
    adSize: size,
    listener: (AdmobAdEvent event, Map<String, dynamic> args) {
      handleEvent(event, args, 'Banner');
    },
  );
}

void handleEvent(AdmobAdEvent event, Map<String, dynamic> args, String adType) {
  switch (event) {
    case AdmobAdEvent.loaded:
      print('Novo $adType Ad carregado!');
      break;
    case AdmobAdEvent.opened:
      print('Admob $adType Ad aberto!');
      break;
    case AdmobAdEvent.closed:
      print('Admob $adType Ad fechado!');
      break;
    case AdmobAdEvent.failedToLoad:
      print('Admob $adType falhou ao carregar. :(');
      break;
    default:
  }
}
