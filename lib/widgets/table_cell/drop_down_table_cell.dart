import 'package:apiro_table/widgets/custom_dropdown/custom_drop_down.dart';
import 'package:flutter/material.dart';

class TableCellWithDropDownWidget extends StatelessWidget {
  final List<String> data;
  final String? colName;
  final String cellStatus;
  final Border? border;
  final bool shouldShowGridLines;

  TableCellWithDropDownWidget(
      {required this.data,
      this.colName,
      this.border,
      required this.cellStatus,
      this.shouldShowGridLines = true}) {}

  ValueNotifier<int> selectedValue = ValueNotifier<int>(0);

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Container(
        height: 60,
        width: 150,
        decoration: BoxDecoration(
            border: shouldShowGridLines
                ? Border.all(
                    color: _themeData.disabledColor,
                    width: 0.5,
                  )
                : border),
        alignment: AlignmentDirectional.center,
        child: _getDropDownWidget());
  }

  Widget _getDropDownWidget() {
    return ValueListenableBuilder(
        valueListenable: selectedValue,
        builder: (context, value, child) {
          return Container(
            margin: EdgeInsets.only(left: 10),
            child: CustomDropDownWidget(
              items: this.data,
              width: 160,
              height: 60,
              // textColor: cellStatus.getTextColorFromTableCellStatus(),
              shouldShowBorder: false,
              onChange: (value) {
                selectedValue.value = data.indexOf(value);
              },
              selectedItemIndex: selectedValue.value,
            ),
          );
        });
  }
}
