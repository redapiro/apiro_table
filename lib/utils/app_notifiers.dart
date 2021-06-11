import 'package:flutter/material.dart';

class AppNotifiers {
  static final AppNotifiers _instance = AppNotifiers._internal();
  static AppNotifiers getInstance() => _instance;
  AppNotifiers._internal();

  ValueNotifier<bool> filterListUpdateNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> refreshDataTableNotifier = ValueNotifier<bool>(false);
}
