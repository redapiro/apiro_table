import 'dart:math';

import 'package:apiro_table/model/controller_info.dart';
import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/table_manager/table_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableDataGrid extends DataGridSource {
  BuildContext? context;
  List<DataGridRow> gridRow = [];
  Color? rowColor;
  Color? oddRowColor;
  Color? evenRowColor;

  TableDataGrid(
      {required this.context,
      required this.gridRow,
      this.rowColor,
      this.oddRowColor,
      this.evenRowColor});

  ControllerInfo controllerInfo =
      TableManager.getInstance().getTextFromFirstNonEmptyController();

  @override
  List<DataGridRow> get rows => controllerInfo.index != -1 &&
          controllerInfo.text.isNotEmpty &&
          controllerInfo.text.length > 2
      ? TableManager.getInstance()
          .dataGridRow
          .where((element) => element
              .getCells()[controllerInfo.index]
              .value
              .value
              .toString()
              .toLowerCase()
              .startsWith(controllerInfo.text.toLowerCase()))
          .toList()
      : TableManager.getInstance().dataGridRow;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {

    Color getBackgroundColor() {
      if (this.rowColor != null) {
        return this.rowColor!;
      }
      int index = gridRow.indexOf(row) + 1;
      if (index % 2 == 0) {
        return this.evenRowColor ?? AppColors.tableRowBackgroundColor;
      } else {
        return this.oddRowColor ?? Colors.white;
      }
    }

    final _random = Random();


        return DataGridRowAdapter(
        key: UniqueKey(),
        color: getBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          return Container(
            key: UniqueKey(),
            alignment: Alignment.center,
            // padding: EdgeInsets.all(3.0),
            child: e.value,
            color: Color.fromARGB(200, _random.nextInt(256),_random.nextInt(256),_random.nextInt(256))
          );
        }).toList());
  }

  void refreshTableDataGrid(){
    notifyDataSourceListeners();
    notifyListeners();
  }
}
