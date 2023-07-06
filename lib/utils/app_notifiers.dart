import 'dart:async';
class AppNotifiers {
  static final AppNotifiers _instance = AppNotifiers._internal();
  static AppNotifiers getInstance() => _instance;
  AppNotifiers._internal();
  // bool isRefreshingTable = false;

  // ValueNotifier<bool> filterListUpdateNotifier = ValueNotifier<bool>(false);
  // ValueNotifier<bool> refreshDataTableNotifier = ValueNotifier<bool>(false);

  //notifier for row pinning
  // ValueNotifier<Widget?> pinnedRowWidgetNotifier = ValueNotifier<Widget?>(null);

  //hidden column notifier
  // ValueNotifier<String?> hiddenColumnNotifier = ValueNotifier<String?>(null);

  //Table pinned row and column pointers
  // ValueNotifier<int> frozenColumnCountNotifier = ValueNotifier<int>(0);
  // ValueNotifier<int> frozenRowCountNotifier = ValueNotifier<int>(0);
  // ValueNotifier<int> paginationPageNumberNotifier = ValueNotifier<int>(1);

  //Controller to notify client about row pinning
  StreamController<List<Map<String, dynamic>>> isRowunpinController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
}
