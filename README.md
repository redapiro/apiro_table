[![Build Status]
# Apiro Table

This plugin allows Flutter apps to create a customized table grid with a lot of available options and column and row pinning options, user will also be able to use pagination option with this plugin.

User can hide the table columns and apply different kind of filter on table columns.

It also provide the callbacks to save the applied filters and hidden columns configuration to shared pref or remotely on any server.

There are flags for every functionality available in this plugin, you can turn the flag on and use the functionality straight away.

This plugin works Android, ios and web.

Any updates and suggestions are most welcome.


## :sparkles: What's New
#### Version 1.0.0 (30th Jun 2021)

-- Changed pagination logic

## :book: Guide

#### 1. Setup the config file

Add your Apiro Table configuration to your `pubspec.yaml`.
An example is shown below. 
```yaml
dependencies:
  apiro_table:
    git:
      url: https://github.com/redapiro/apiro_table.git
```

```
  flutter pub get
```

## Usage
```dart
  import 'package:apiro_table/widgets/table_widget/apiro_table_widget.dart';
  List<String> columnName = [];
  List<String> columnIds = [];
  List<Map<String, dynamic>> rowData = [];
  
   ApiroTableWidget(
            columnData: columnName,
            columnIds: columnIds,
            rowData: rowData,
            //Used to reset the table configuration whenever we are using multiple tables in single project
            shouldResetTableConfigs: this.shouldResetTableManagerConfig,
            paginationPageSizes: [2,5,10,100,200,500],
            paginationPageSize:
                5,
                //Header widget for table if needed 
            widgetInTableHeaderRow: DashboardTableHeaderWidget(),
            //Flag to turn column hiding on
            columnHidingOn: true,
            //Callback for row pinning
            getPinnedRowStream: (rowPinStream, callbackRowPin) {
            //An stream always provide the pinned row index
              rowPinStream.listen((event) {
                this.pinnedRowIndex = event;
              });
              //callback that will be called whenever row pinning is used at client side
              this.rowPinCallback = callbackRowPin;
            },
            //grid source to provide most of the customization to table cell
            gridRow: _orderDataGridSource(),
            
            //call back on column pinning
            updateDataOnColumnPinned: () {},
            
            //callback on filter on column
            updateDataOnFilterColumn: (filterList, columnName) {
              tableNotifier.saveConfigFilterDataFromCallbacksToFirebase(
                  filterList, columnName);
            },
            //callback on hide columns
            updateDataOnHideColumn: (hiddenColumnsData) {
            
            },
            tableHeight: (screenHeight ?? 100) - 150,
            //pagination methods
            onItemPerPageChange: (currentPage, numberOfPages, perPageCount) {
              
              
            },
            onNextClick: (currentPage, numberOfPages) {
              
            },
            onPageNumberClick: (currentPage, numberOfPages) {
              
            },
            onPageNumberDropDownSelect:
                (currentPage, numberOfPages, perPageRowCount) {},
            onPageNumberTextFieldSubmit: (currentPage, numberOfPages) {
              
            },
            onPreviousClick: (currentPage, numberOfPages) {
              
            },
            totalNumberOfPages: totalNumberOfPages,
          )


//Generate gris source for the table row
List<DataGridRow> _orderDataGridSource() {
  TableGridSource dataSource = TableGridSource(
  rowData: tableRowData,
  columnNames: tableColumnName!,
  onStatusWidgetClick: (index) {
  onRowPinClick(index);
  },
  context: this.context);

  return dataSource.dataGridRow;
}


import 'package:syncfusion_flutter_datagrid/datagrid.dart';
  
  
  class TableGridSource {
  /// Creates the employee data source class with required details.
  ///
  Function(int) onStatusWidgetClick;
  List<Map<String, dynamic>>? rowData;
  List<String> columnNames = [];
  List<DataGridRow> dataGridRow = [];

  TableGridSource(
      {@required this.rowData,
      required this.columnNames,
      required this.onStatusWidgetClick,
      required this.context}) {
    _userData = List.generate(rowData!.length, (rowIndex) {
      return DataGridRow(cells: List.generate(columnNames.length, (index) {
      DataGridCell<Widget>(
            columnName: columnNames[index].id!.toString(), value: valueWidget);
            });
            }
  

```

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
