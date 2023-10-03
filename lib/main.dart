
import 'package:apiro_table/widgets/table_widget/apiro_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
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
  List<int> pinnedRowIndex = [];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    this.context = context;

    return MaterialApp(useInheritedMediaQuery: true,
      title: 'Apiro Table',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ApiroTableWidget(
        columnData: [],totalNumberOfItems: colIds.length,
        columnIds: colIds,context: context,
        rowData: rowData,
        filtersOn: true,
        updateDataOnColumnPinned: (val1, val2) {},
        updateDataOnFilterColumn: (data, data1) {},
        selectableCellText: false,
        cellInlineEditing: false,
        columnHidingOn: true,
        columnOrderingOn: true,
        paginationPageSize: 50,
        updateDataOnHideColumn: (data) {},
        cellMenuOn: true,
        onColumnClick: (ind, shouldShowSort, updateMetadata) {
          shouldShowSort(false);
          updateMetadata({});
        },
        paginationPageSizes: [5, 10, 50, 300, 700],
        selectableColumnText: false,
        totalNumberOfPages: 2,
        gridRow: [],
        getPinnedRowStream: (pinnedRows, rowPinCallback) {
          pinnedRows.listen((event) {
            // this.pinnedRowIndex = event;
          });
          // rowPinCallback()
        },
        tableHeight: 400,
        onItemPerPageChange: (int, ds, sdf) {},
        onNextClick: (int, sdf) {},
        onPageNumberClick: (int, sdf) {},
        onPageNumberDropDownSelect: (int, dfds, sdf) {},
        onPageNumberTextFieldSubmit: (int, sadsa) {},
        onPreviousClick: (int, asd) {},
      ),
    );
  }
}
