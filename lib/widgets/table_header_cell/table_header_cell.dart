import 'package:flutter/material.dart';

class TableHeaderCell extends StatelessWidget {
  final String tableHealderCellTitle;
  TableHeaderCell({Key? key, required this.tableHealderCellTitle})
      : super(key: key);

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Container(
      height: 60,
      width: 150,
      alignment: AlignmentDirectional.center,
      color: Colors.grey.withOpacity(0.3),
      child: Text(
        this.tableHealderCellTitle,
        textAlign: TextAlign.center,
        style: _themeData.textTheme.subtitle1!.copyWith(color: Colors.black),
      ),
    );
  }
}
