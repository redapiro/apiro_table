

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

### Parameters 
1. columnData - takes List<String> to show column names
2. columnIds - takes List<String> to keep track on column used as column unique Id
3. rowData - Rows data in Map 
4. shouldResetTableConfigs - flag used to reset table configuration when a new table object is created (The plugin is using a singleton class to manage operations on table, that singleton class data is reset using this flag)
5. paginationPageSizes - Pagination page sizes for table pagination
6. paginationPageSize - No of rows per page
7. widgetInTableHeaderRow - left side widget in table header
8. columnHidingOn - column hiding functionality flag
9. getPinnedRowStream - provides a callback to be called whenever a row is pinned and return pinned row data through stream back to its client
10. gridRow - Row data grid that is generated using GridDataSource and fully customisable 
11. updateDataOnHideColumn - hidden columns data from plugin to client for saving into firebase or shared pref
12. updateDataOnFilterColumn - column filter callback data from plugin to client for saving into firebase or shared pref
13. tableHeight - Height of table
14. onItemPerPageChange - Callback when no of rows per page is changed
15. onNextClick - Callback when next button in pagination widget is clicked
16. onPageNumberClick - Callback when specific page number is clicked
17. onPageNumberDropDownSelect - Callback when no of rows per page selected from pagination frop down
18. onPageNumberTextFieldSubmit - callback when age number submitted in text field
19. onPreviousClick - Callback when previous button in pagination is clicked
20. totalNumberOfPages - Total number of pages available in pagination

![Untitled](https://user-images.githubusercontent.com/70631810/124572079-fb0e1780-de65-11eb-9b21-b81d84c2e6df.png)




```dart
  import 'package:apiro_table/widgets/table_widget/apiro_table_widget.dart';
  import 'package:syncfusion_flutter_datagrid/datagrid.dart';
  
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


//Generate grid source for the table row
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



  
  class TableGridSource {
  /// Creates the employee data source class with required details.
  ///
  Function(int) onStatusWidgetClick;
  List<Map<String, dynamic>>? rowData;
  List<String> columnNames = [];
  List<DataGridRow> dataGridRow = [];

  TableGridSource(
      {required this.rowData,
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


![Untitled](https://user-images.githubusercontent.com/70631810/124572471-4d4f3880-de66-11eb-837f-f17850efce46.png)

```dart
  import 'package:apiro_table/widgets/table_widget/apiro_table_widget.dart';
  import 'package:syncfusion_flutter_datagrid/datagrid.dart';
  
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


//Generate grid source for the table row
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



  

class AuditTaskDataTableGridSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  ///

  BuildContext? context;
  List<RestAuditListDTO> rowData = [];
  List<TableColumnDTO> columnNames = [];

  AuditTaskDataTableGridSource(
      {required this.rowData,
      required this.columnNames,
      required this.context}) {
    _userData = List.generate(rowData.length, (rowIndex) {
      return DataGridRow(
          cells: List.generate(columnNames.length, (index) {
        return DataGridCell<Widget>(
            columnName: displayName ?? "",
            value: CollectionTableCell(
              tableCellTitle:
                  title,
            ));
      }));
    }).toList();
  }

 

  List<DataGridRow> _userData = [];

  @override
  List<DataGridRow> get rows => _userData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getBackgroundColor() {
      int index = _userData.indexOf(row) + 1;
      if (index % 2 == 0) {
        return AppColors.tableRowBackgroundColor;
      } else {
        return AppColors.scaffoldBackgroundColor;
      }
    }

    return DataGridRowAdapter(
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


```


For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
