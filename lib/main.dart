import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:melembra/app/app_widget.dart';

void main() {
  List<String> ids = [];
  ids.add(getAppId());

  Admob.initialize(testDeviceIds: ids);
  runApp(AppWidget());
}

String getAppId() {
  return 'ca-app-pub-3992962658517532/8458488721';
}
