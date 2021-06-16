import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/table_cell/table_cell.dart';
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

  @override
  List<DataGridRow> get rows => TableManager.getInstance().datagridRow;

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

    return DataGridRowAdapter(
        key: UniqueKey(),
        color: getBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(3.0),
            child: e.value,
          );
        }).toList());
  }
}
