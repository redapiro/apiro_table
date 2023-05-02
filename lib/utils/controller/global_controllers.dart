import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filterListUpdateNotifier =
    StateNotifierProvider<FilterListUpdateNotifier, bool>((ref) {
  return FilterListUpdateNotifier();
});

class FilterListUpdateNotifier extends StateNotifier<bool> {
  FilterListUpdateNotifier() : super(false);

  void updateValue(bool val) => state = val;

  void toggleValue() => state = !state;
}

final refreshDataTableNotifier =
    StateNotifierProvider<RefreshDataTableNotifier, bool>((ref) {
  return RefreshDataTableNotifier();
});

class RefreshDataTableNotifier extends StateNotifier<bool> {
  RefreshDataTableNotifier() : super(false);

  void updateValue(bool val) => state = val;

  void toggleValue() => state = !state;
}

final pinnedRowWidgetNotifier =
    StateNotifierProvider<PinnedRowWidgetNotifier, Widget?>((ref) {
  return PinnedRowWidgetNotifier();
});

class PinnedRowWidgetNotifier extends StateNotifier<Widget?> {
  PinnedRowWidgetNotifier() : super(null);

  void updateValue(Widget? val) => state = val;
}

final hiddenColumnNotifier =
    StateNotifierProvider<HiddenColumnNotifier, String?>((ref) {
  return HiddenColumnNotifier();
});

class HiddenColumnNotifier extends StateNotifier<String?> {
  HiddenColumnNotifier() : super(null);

  void updateValue(String? val) => state = val;
}

final frozenColumnCountNotifier =
    StateNotifierProvider<FrozenColumnCountNotifier, int>((ref) {
  return FrozenColumnCountNotifier();
});

class FrozenColumnCountNotifier extends StateNotifier<int> {
  FrozenColumnCountNotifier() : super(0);

  void updateValue(int val) => state = val;
  void increment ()=> state +=1;
  void decrement ()=> state -=1;
}
final frozenRowCountNotifier =
StateNotifierProvider<FrozenRowCountNotifier, int>((ref) {
  return FrozenRowCountNotifier();
});

class FrozenRowCountNotifier extends StateNotifier<int> {
  FrozenRowCountNotifier() : super(0);

  void updateValue(int val) => state = val;
  void increment ()=> state +=1;
  void decrement ()=> state -=1;
}

final paginationPageNumberNotifier =
StateNotifierProvider<PaginationPageNumberNotifier, int>((ref) {
  return PaginationPageNumberNotifier();
});

class PaginationPageNumberNotifier extends StateNotifier<int> {
  PaginationPageNumberNotifier() : super(1);

  void updateValue(int val) => state = val;
  void increment ()=> state +=1;
  void decrement ()=> state -=1;
}
final isRefreshingTable =
StateNotifierProvider<IsRefreshingTable, bool>((ref) {
  return IsRefreshingTable();
});

class IsRefreshingTable extends StateNotifier<bool> {
  IsRefreshingTable() : super(false);

  void updateValue(bool val) => state = val;

  void toggleValue() => state = !state;
}
