import 'package:flutter/material.dart';

class TableHeaderCell extends StatelessWidget {
  final String tableHeaderCellTitle;
  TableHeaderCell({Key? key, required this.tableHeaderCellTitle})
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
        this.tableHeaderCellTitle,
        textAlign: TextAlign.center,
        style: _themeData.textTheme.titleMedium!.copyWith(color: Colors.black),
      ),
    );
  }
}
