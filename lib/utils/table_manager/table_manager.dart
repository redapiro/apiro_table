import 'package:apiro_table/model/column_pinning_info.dart';
import 'package:apiro_table/model/controller_info.dart';
import 'package:apiro_table/model/row_pinning_info.dart';
import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/utils/controller/global_controllers.dart';
import 'package:apiro_table/utils/provider_helper.dart';
import 'package:apiro_table/widgets/table_cell/table_cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableManager {
  static TableManager _instance = TableManager._internal();

  static TableManager getInstance() => _instance;

  TableManager._internal();

  //Table data variables

  //Column data variables
  List<String> columnNames = [];
  List<TextEditingController> columnNameControllers = [];
  List<String> staticColumnsData = [];
  List<String> columnIds = [];
  List<String> staticColumnIds = [];
  List<DataGridRow> dataGridRow = [];
  List<DataGridRow> staticDataGridRow = [];

  //Row data varaibles
  List<Map<String, dynamic>> rowData = [];
  List<Map<String, dynamic>> staticRowData = [];

  //Table action required vriables
  List<String> tableColumnFilterList = [];
  List<Map<String, dynamic>> hiddenColumnIds = [];
  String currentFilterColumnId = "";

  //Pinned column data
  List<ColumnPinningInfo> pinnedColumnInfo = [];

  //Pinned Row data
  List<RowPinningInfo> pinnedRowInfo = [];
  List<Map<String, dynamic>> columnOrderingDataInfo = [];
  Function()? onRowPinning;

  //Filters working
  void removeAllFilter(BuildContext context) {
    if (this.tableColumnFilterList.length > 0) {
      //Updatetable filters

      context
          .riverPodReadStateNotifier(frozenRowCountNotifier.notifier)
          .updateValue(0);
      context
          .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
          .updateValue(0);

      this.tableColumnFilterList = [];
      this.rowData = [];

      this.dataGridRow = [];

      this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
      this.dataGridRow = this.decoupleCellObjects();

      this.columnIds = [];
      this.columnNames = [];

      this.columnIds = List<String>.from(this.staticColumnIds);
      this.columnNames = List<String>.from(this.staticColumnsData);

      this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists(context);
      //refresh the view
      this.refreshDataTable(context);

      context
          .riverPodReadStateNotifier(filterListUpdateNotifier.notifier)
          .toggleValue();
    }
  }

  void upPinAllItems(BuildContext context) {
    if (context.riverPodReadStateNotifier(frozenColumnCountNotifier) != 0) {
      var tempPinnedColumnInfo = pinnedColumnInfo;

      for (int i = 0; i < tempPinnedColumnInfo.length; i++) {
        var tempRowData = List<Map<String, dynamic>>.from(this.rowData);
        int insertIndex = tempPinnedColumnInfo[i].lastPosition!;

        int rowIndex = 0;
        for (var rowActData in tempRowData) {
          List<DataGridCell<dynamic>> dataGridCells =
              dataGridRow[rowIndex].getCells();
          var value =
              dataGridCells.removeAt(tempPinnedColumnInfo[i].currentPosition!);
          dataGridCells.insert(insertIndex, value);
          dataGridRow[rowIndex] = DataGridRow(cells: dataGridCells);
          rowIndex++;
        }

        var value =
            this.columnNames.removeAt(tempPinnedColumnInfo[i].currentPosition!);
        this.columnNames.insert(insertIndex, value);
        value =
            this.columnIds.removeAt(tempPinnedColumnInfo[i].currentPosition!);
        this.columnIds.insert(insertIndex, value);

        // pinnedColumnInfo.removeAt(i);
      }
      context
          .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
          .updateValue(0);
      pinnedColumnInfo = [];
      refreshDataTable(context);
    }
  }

  void addFilterToColumn(String columnId, BuildContext context) {
    List<Map<String, dynamic>> tempRowData = [];
    List<DataGridRow> _dataGridRow = [];
    int rowIndex = 0;
    var filterableList = [];
    if (tableColumnFilterList.contains(columnId)) {
      filterableList = tableColumnFilterList.sublist(1);
    }

    this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
    this.dataGridRow = this.decoupleCellObjects();

    for (var data in rowData) {
      if (filterableList.any((element) {
        return data[columnId]
            .toString()
            .trim()
            .toLowerCase()
            .contains(element.toString().toLowerCase().trim());
      })) {
        tempRowData.add(data);
        _dataGridRow.add(this.dataGridRow[rowIndex]);
      }
      rowIndex++;
    }
    this.dataGridRow = [];
    this.dataGridRow = this.decoupleCellObjects(gridRows: _dataGridRow);
    this.rowData = [];
    this.rowData = List<Map<String, dynamic>>.from(tempRowData);

    this.currentFilterColumnId = columnId;

    //refreshTable
    //remove all pinning and hidden column and apply them again

    // this.refreshDataTable(context);
    //
    // //Updatetable filters
      WidgetsBinding.instance.addPostFrameCallback((timeStamp)   {
        this.refreshDataTable(context);
        // applyHideColumnRowAndColumnPinningIfExists(context);
      context
          .riverPodReadStateNotifier(filterListUpdateNotifier.notifier)
          .toggleValue();
    });
  }

  //Hidden ColumnsWorking
  void hideColumn(String columnId, BuildContext context) {
    int rowIndex = 0;
    List<DataGridCell> cells = [];
    for (var row in this.rowData) {
      //Remove col data fro rows
      row.remove(columnId);
      if (this.dataGridRow.length > 0) {
        int colIndex = this.columnIds.indexOf(columnId);
        if (colIndex != -1) {
          DataGridCell? gridCell =
              removeDataGridRowForColumn(colIndex, rowIndex, columnId);

          if (gridCell != null) {
            cells.add(gridCell);
          }
        }
      }
      rowIndex++;
    }
    print("HERE NOW 2");

    // remove data from column id and name
    int colIndex = this.columnIds.indexOf(columnId);
    if (colIndex != -1) {
      this.columnIds.remove(columnId);
      var colName = this.columnNames.removeAt(colIndex);
      //save the columnId to unhide colum in future

      if ((this.hiddenColumnIds.firstWhere(
              (element) => element.containsKey(columnId), orElse: () {
            return {};
          })).length ==
          0) {
        (this.hiddenColumnIds).add({
          columnId: colIndex,
          "cells_data": cells.map((e) => e.value).toList(),
          "column_name": colName
        });
      } else {}
    }
    if (pinnedColumnInfo.any((element) => element.columnId == columnId)) {
      context
          .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
          .decrement();
      // singleColumnPinning(
      //     pinnedColumnInfo
      //         .firstWhere((element) => element.columnId == columnId)
      //         .lastPosition!,
      //     columnId,
      //     true,
      //     context);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .riverPodReadStateNotifier(hiddenColumnNumberNotifier.notifier)
          .increment();
      //refresh the table
    });
    refreshDataTable(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .riverPodReadStateNotifier(hiddenColumnNotifier.notifier)
          .updateValue(this.hiddenColumnIds.length.toString());
    });

  }

  List<DataGridRow> decoupleCellObjects({List<DataGridRow>? gridRows}) {
    List<DataGridRow> rowss =
    (gridRows != null ? gridRows : this.staticDataGridRow).map((e) {
      return DataGridRow(
          cells: List.generate(e.getCells().length, (index) {
        return DataGridCell(
            value: e.getCells()[index].value,
            columnName: e.getCells()[index].columnName);
      }));
    }).toList();
    return rowss;
  }

  DataGridCell _decoupleGridCellsObjects(DataGridCell cells) {
    DataGridCell gridCells =
        DataGridCell(columnName: cells.columnName, value: cells.value);

    return gridCells;
  }


  //remove data from datagrid row if exists
  DataGridCell? removeDataGridRowForColumn(
      int colIndex, int rowIndex, String colId) {
    List<DataGridCell<dynamic>> dataGridCells =
        dataGridRow[rowIndex].getCells();
    DataGridCell? cell;

    if (dataGridCells[colIndex].columnName == colId) {
      cell = dataGridCells.removeAt(colIndex);

      dataGridRow[rowIndex] = DataGridRow(cells: dataGridCells);
    }

    return cell;
  }

  void showColumn(
      String columnId, BuildContext context, Function hideColumns) async {
    this
        .hiddenColumnIds
        .removeWhere((element) => element.keys.toList().contains(columnId));

    this.rowData = [];

    this.dataGridRow = [];
    //
    this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
    this.dataGridRow = this.decoupleCellObjects();

    this.columnIds = [];
    this.columnNames = [];

    this.columnIds = List<String>.from(this.staticColumnIds);
    this.columnNames = List<String>.from(this.staticColumnsData);
    context
        .riverPodReadStateNotifier(hiddenColumnNumberNotifier.notifier)
        .decrement();


    ///refresh table
    this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists(context);
    // context
    //     .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
    //     .decrement();
    if (pinnedColumnInfo.any((element) => element.columnId == columnId)) {
      context
          .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
          .decrement();
      // singleColumnPinning(
      //     pinnedColumnInfo
      //         .firstWhere((element) => element.columnId == columnId)
      //         .lastPosition!,
      //     columnId,
      //     true,
      //     context);
    }
    context
        .riverPodReadStateNotifier(hiddenColumnNumberNotifier.notifier)
        .updateValue(hiddenColumnIds.length);

    context
        .riverPodReadStateNotifier(hiddenColumnNotifier.notifier)
        .updateValue(this.hiddenColumnIds.length.toString());

    hideColumns();

    this.refreshDataTable(context);
  }

  //get hidden column data from column id
  Map<String, dynamic> _getHiddenColumnDataWithColumnId(String columnId) {
    Map<String, dynamic> hiddenColumnData = {};
    print("hidden column data -- ${this.hiddenColumnIds}");
    if (this.hiddenColumnIds.length > 0) {
      hiddenColumnData = this.hiddenColumnIds.firstWhere(
          (element) => element.keys.toList()[0] == columnId, orElse: () {
        return {};
      });
    }
    return hiddenColumnData;
  }

  void showAllColumn(BuildContext context) {
    if (this.hiddenColumnIds.length > 0) {
      context
          .riverPodReadStateNotifier(frozenRowCountNotifier.notifier)
          .updateValue(0);
      context
          .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
          .updateValue(0);

      this.hiddenColumnIds = [];
      this.columnNames = [];
      this.columnIds = [];
      this.columnIds = List<String>.from(this.staticColumnIds);
      this.columnNames = List<String>.from(this.staticColumnsData);
      this.rowData = [];
      this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
      this.dataGridRow = [];
      this.dataGridRow = List<DataGridRow>.from(this.decoupleCellObjects());

      //apply if any row column pinning and filters are there
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists(context);
      context
          .riverPodReadStateNotifier(hiddenColumnNotifier.notifier)
          .updateValue(this.hiddenColumnIds.length.toString());
      context
          .riverPodReadStateNotifier(hiddenColumnNumberNotifier.notifier)
          .updateValue(hiddenColumnIds.length);});

      //refresh table
      this.refreshDataTable(context);
    }
  }

  //Column Ordering Working
  void setColumnOrdering(int sendTo, int currentPosition, String columnId, BuildContext context) {
    int rowIndex = 0;
    int colIndex = this.columnIds.indexOf(columnId);
    for (var rowsData in this.rowData) {
      List<DataGridCell<dynamic>> dataGridCells =
          dataGridRow[rowIndex].getCells();
      var value = colIndex != -1 ? dataGridCells.removeAt(colIndex) : null;
      if (value != null) {
        dataGridCells.insert(sendTo > 0 ? sendTo - 1 : 0, value);
        dataGridRow[rowIndex] = DataGridRow(cells: dataGridCells);
      }

      rowIndex++;
    }

    if (colIndex != -1) {
      var colValue = this.columnNames.removeAt(colIndex);
      this.columnNames.insert(sendTo > 0 ? sendTo - 1 : 0, colValue);
      colValue = this.columnIds.removeAt(colIndex);
      this.columnIds.insert(sendTo > 0 ? sendTo - 1 : 0, colValue);
    }
    int indexOfExistingColumnOrder = this
        .columnOrderingDataInfo
        .indexWhere((element) => element[columnId] != null);
    if (indexOfExistingColumnOrder != -1) {
      this.columnOrderingDataInfo[indexOfExistingColumnOrder] = {
        columnId: [sendTo, currentPosition]
      };
    } else {
      this.columnOrderingDataInfo.add({
        columnId: [sendTo, currentPosition]
      });
    }

    //refresh table
    this.refreshDataTable(context);
  }

  //Single Column pinning working
  void singleColumnPinning(
      int colIndex, String columnId, bool isUnPin, BuildContext context) {
    // print("pinned col info --- ${this.pinnedColumnInfo}");
    // print("pinned col info --- ${colIndex}");
    // print("pinned col info --- ${columnId}");

    if (!isUnPin) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context.riverPodReadStateNotifier(isRefreshingTable.notifier)
            .updateValue(true);
      });
      var tempRowData = List<Map<String, dynamic>>.from(this.rowData);

      int insertIndex =
          this.pinnedColumnInfo.length > 0 ? this.pinnedColumnInfo.length : 0;

      int rowIndex = 0;
      for (var rowActData in tempRowData) {
        rowActData.remove(columnId);

        List<DataGridCell<dynamic>> dataGridCells =
            dataGridRow[rowIndex].getCells();
        var value = dataGridCells.removeAt(colIndex);
        dataGridCells.insert(insertIndex, value);
        dataGridRow[rowIndex] = DataGridRow(cells: dataGridCells);

        rowIndex++;
      }

      var columnRemovedName = this.columnNames.removeAt(colIndex);
      this.columnNames.insert(insertIndex, columnRemovedName);
      var value = this.columnIds.removeAt(colIndex);
      this.columnIds.insert(insertIndex, value);
      
   ColumnPinningInfo existingDataWithId =   this.pinnedColumnInfo.firstWhere((element) => element.columnId == columnId, orElse: (){
        return ColumnPinningInfo();
      });
      
      ColumnPinningInfo info = ColumnPinningInfo(
          columnId: columnId,
          columnName: columnRemovedName,
          currentPosition: insertIndex,
          lastPosition: colIndex);
      
      this.pinnedColumnInfo.add(info);

      //update frozen column count
      if(existingDataWithId.columnId == null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context
              .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
              .increment();
        });
      }
    } else {
      var tempRowData = List<Map<String, dynamic>>.from(this.rowData);
      int insertIndex = (this.pinnedColumnInfo.length > 0
          ? this.pinnedColumnInfo.firstWhere(
                  (element) => element.columnId == columnId, orElse: () {
                return ColumnPinningInfo();
              }).lastPosition ??
              0
          : 0);
      if (insertIndex <
          (context.riverPodReadStateNotifier(frozenColumnCountNotifier) - 1)) {
        insertIndex =
            (context.riverPodReadStateNotifier(frozenColumnCountNotifier) - 1);
      }
      int rowIndex = 0;
      for (var rowActData in tempRowData) {
        List<DataGridCell<dynamic>> dataGridCells =
            dataGridRow[rowIndex].getCells();
        var value = dataGridCells.removeAt(colIndex);
        dataGridCells.insert(insertIndex, value);
        dataGridRow[rowIndex] = DataGridRow(cells: dataGridCells);

        rowIndex++;
      }

      var value = this.columnNames.removeAt(colIndex);
      this.columnNames.insert(insertIndex, value);
      value = this.columnIds.removeAt(colIndex);
      this.columnIds.insert(insertIndex, value);

      this
          .pinnedColumnInfo
          .removeWhere((element) => element.columnId == columnId);

      //update frozen column count
      if (context.riverPodReadStateNotifier(frozenColumnCountNotifier) > 0) {
        context
            .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
            .decrement();
      }
    }
    //refresh data table with new data
    this.refreshDataTable(context);
  }

  //Single Row pining working
  void singleRowPinning(
      int currentPosition, bool isUnPin, BuildContext context) {
    if (!isUnPin) {
      context
          .riverPodReadStateNotifier(frozenRowCountNotifier.notifier)
          .increment();

    } else {


      context
          .riverPodReadStateNotifier(frozenRowCountNotifier.notifier)
          .decrement();
    }

    AppNotifiers.getInstance()
        .isRowunpinController
        .add(this.pinnedRowInfo.length == 0
            ? []
            : this.pinnedRowInfo.map((e) {
                return {
                  "current_position": e.currentPosition ?? 0,
                  "last_position": e.lastPosition ?? 0
                };
              }).toList());

    //refresh table with new data
    this.refreshDataTable(context);
  }

  void applyAnyFilterHiddenColumnRowAndColumnPinningIfExists(
      BuildContext context) {
    //Apply filter if there are any

    if (this.tableColumnFilterList.length > 0) {
      // for (String columnId in this.tableColumnFilterList.length > 1
      //     ? this.tableColumnFilterList.sublist(0, 1)
      //     : []) {

      this.addFilterToColumn(this.tableColumnFilterList[0], context);
      // }
    }

    // hide columns if here are any
    if (this.hiddenColumnIds.length > 0) {
      for (var columnData in this.hiddenColumnIds) {
        String columnId = columnData["column_name"];
        // if (!columnData.containsKey("cells_data")) {
        //   this.showAllColumn();
        //   return;
        // }
        print("column id to hide -- $columnId");
        // this.hideColumn(columnId, context);
      }
    }

    //Pin columns if there are any
    var tempColInfos = this.pinnedColumnInfo.map((e) => e.copyFrom()).toList();

    this.pinnedColumnInfo = [];
    if (tempColInfos.length > 0) {
      for (var pinnedColInfos in tempColInfos) {
        print("column id to pin -- $pinnedColInfos");
        this.singleColumnPinning(pinnedColInfos.lastPosition ?? 0,
            pinnedColInfos.columnId ?? "", false, context);
      }
    }

    //Pin rows if there are any
    this.pinnedRowInfo = [];
    if (this.onRowPinning != null) {
      this.onRowPinning!();
    }
    // if (tempRowInfos.length > 0) {
    //   for (var pinnedROwInfos in tempRowInfos) {
    //     this.singleRowPinning(pinnedROwInfos.lastPosition ?? 0, false);
    //   }
    // }

    //Apply column ordering if any

    for (var columnOrderData in this.columnOrderingDataInfo) {
      String columnId = columnOrderData.keys.toList()[0];
      this.setColumnOrdering(columnOrderData[columnId][0],
          columnOrderData[columnId][1], columnId, context);
    }
    columnNameControllers = List.generate(
        staticColumnIds.length, (index) => TextEditingController());
  }

  void applyHideColumnRowAndColumnPinningIfExists(BuildContext context) {
    // resetTableManagerConfiguration(excepFilters: true);
    this.columnIds = List<String>.from(this.staticColumnIds);
    this.columnNames = List<String>.from(this.staticColumnsData);
    context
        .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
        .updateValue(0);

    context
        .riverPodReadStateNotifier(frozenRowCountNotifier.notifier)
        .updateValue(0);
    context.riverPodReadStateNotifier(paginationPageNumberNotifier.notifier).updateValue(1);


    // hide columns if here are any
    if (this.hiddenColumnIds.length > 0) {
      for (var columnData in this.hiddenColumnIds) {
        String columnId = columnData["column_name"];
        // if (!columnData.containsKey("cells_data")) {
        //   this.showAllColumn();
        //   return;
        // }
        print("column id to hide -- $columnId");
        this.hideColumn(columnId, context);
      }
    }

    //Pin columns if there are any
    var tempColInfos = this.pinnedColumnInfo.map((e) => e.copyFrom()).toList();

    this.pinnedColumnInfo = [];
    if (tempColInfos.length > 0) {
      for (var pinnedColInfos in tempColInfos) {
        this.singleColumnPinning(pinnedColInfos.lastPosition ?? 0,
            pinnedColInfos.columnId ?? "", false, context);
      }
    }

    //Pin rows if there are any
    var tempRowInfos = this.pinnedRowInfo.map((e) => e.copyFrom()).toList();
    this.pinnedRowInfo = [];
    if (this.onRowPinning != null) {
      this.onRowPinning!();
    }

    // if (tempRowInfos.length > 0) {
    //   for (var pinnedROwInfos in tempRowInfos) {
    //     this.singleRowPinning(pinnedROwInfos.lastPosition ?? 0, false);
    //   }
    // }

    //Apply column ordering if any

    for (var columnOrderData in this.columnOrderingDataInfo) {
      String columnId = columnOrderData.keys.toList()[0];
      this.setColumnOrdering(columnOrderData[columnId][0],
          columnOrderData[columnId][1], columnId, context);
    }
  }

  void updateCellValue(int rowIndex, int colIndex, String value,
      Function() onCellDoubleClick, BuildContext context) {
    this.rowData[rowIndex][this.columnIds[colIndex]] = value;
    List<DataGridCell> cells = this.dataGridRow[rowIndex].getCells();

    cells[colIndex] = DataGridCell(
        columnName: this.columnNames[colIndex],
        value: TableGridCell(
          onCellDoubleTap: onCellDoubleClick,
          rowIndex: rowIndex,
          colIndex: colIndex,
          title: rowData[rowIndex][this.columnIds[colIndex]].toString(),
        ));
    this.dataGridRow[rowIndex] = DataGridRow(cells: cells);
    this.refreshDataTable(context);
  }

  void resetTableManagerConfiguration(
      {bool excepFilters = false, BuildContext? context}) {
    //reset all  values from table manager
    context!
        .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
        .updateValue(0);
    context
        .riverPodReadStateNotifier(frozenRowCountNotifier.notifier)
        .updateValue(0);
    context.riverPodReadStateNotifier(paginationPageNumberNotifier.notifier).updateValue(1);
    if (!excepFilters) this.tableColumnFilterList = [];
    this.hiddenColumnIds = [];
    this.pinnedColumnInfo = [];
    this.pinnedRowInfo = [];
  }

  void refreshDataTable(BuildContext context) {
    // AppNotifiers.getInstance().refreshDataTableNotifier.value =
    //     !AppNotifiers.getInstance().refreshDataTableNotifier.value;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        context
            .riverPodReadStateNotifier(refreshDataTableNotifier.notifier)
            .toggleValue();
      }
    });
  }

  ControllerInfo getTextFromFirstNonEmptyController() {
    for (int i = 0; i < columnNameControllers.length; i++) {
      TextEditingController controller = columnNameControllers[i];
      if (controller.text.isNotEmpty) {
        return ControllerInfo(i, controller.text);
      }
    }
    // If no controller has text, return an empty string and -1 as the index or any default values you prefer.
    return ControllerInfo(-1, "");
  }
}
