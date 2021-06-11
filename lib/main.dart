import 'dart:convert';

import 'package:apiro_table/utils/constants.dart';
import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/table_widget/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    setupData();
  }
  List<String> colData = [];
  List<String> colIds = [];
  List<Map<String, dynamic>> rowData = [];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apiro Table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TableWidget(
        columnData: _getColumnData(),
        columnIds: colIds,
        rowData: rowData,
        gridRow: _getDataGridRow(),
      ),
    );
  }

  void setupData() {
    _getColumnData();
    _getDataGridRow();
  }

  List<String> _getColumnData() {
    List<String> columnNames = [];
    List<String> columnIds = [];

    List<dynamic> columnData = json.decode(Constants.AUDIT_TASK_COLUMN_DATA);
    for (var colData in columnData) {
      columnNames.add(colData["displayName"]);
      columnIds.add(colData["datafield"]);
    }

    this.colIds = columnIds;
    this.colData = columnNames;

    return columnNames;
  }

  List<DataGridRow> _getDataGridRow() {
    Map<String, dynamic> rowData = json.decode(Constants.AUDIT_TASK_DATA);
    List<DataGridRow> gridRows = [];
    List<Map<String, dynamic>> tableRowData = [];
    for (var gridRowData in rowData.keys.toList()) {
      if (gridRowData == "results") {
        if (tableRowData.length == 0)
          tableRowData = List<Map<String, dynamic>>.from(rowData["results"]);
        for (var resultsRow in (rowData["results"] as List)) {
          List<DataGridCell> gridCells = [];
          for (var columnId in this.colIds) {
            gridCells.add(DataGridCell(
                columnName: columnId,
                value: Text(resultsRow[columnId].toString())));
          }
          gridRows.add(DataGridRow(cells: gridCells));
        }
      }
    }
    this.rowData = tableRowData;
    return gridRows;
  }
}
