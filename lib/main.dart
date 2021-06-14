import 'dart:convert';

import 'package:apiro_table/model/row_pinning_info.dart';
import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/utils/constants.dart';
import 'package:apiro_table/utils/enum/cell_data_type.dart';
import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/pinned_row_pop_up/pinned_row_pop_up_widget.dart';
import 'package:apiro_table/widgets/table_cell/table_cell.dart';
import 'package:apiro_table/widgets/table_cell/table_cell_detail_widget.dart';
import 'package:apiro_table/widgets/table_widget/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    // setupData();
  }

  late BuildContext context;

  late double screenWidth;
  List<String> colData = [];
  List<String> colIds = [];
  List<Map<String, dynamic>> rowData = [];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    this.context = context;

    return MaterialApp(
      title: 'Apiro Table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: TableWidget(
        columnData: [],
        columnIds: colIds,
        rowData: rowData,
        gridRow: [],
      ),
    );
  }
}
