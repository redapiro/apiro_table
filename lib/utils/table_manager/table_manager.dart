import 'package:apiro_table/model/column_pinning_info.dart';
import 'package:apiro_table/model/row_pinning_info.dart';
import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/widgets/table_cell/table_cell.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableManager {
  static TableManager _instance = TableManager._internal();
  static TableManager getInstance() => _instance;
  TableManager._internal();

  //Table data variables

  //Column data variables
  List<String> columnNames = [];
  List<String> staticColumnsData = [];
  List<String> columnIds = [];
  List<String> staticColumnIds = [];
  List<DataGridRow> datagridRow = [];
  List<DataGridRow> staticDatagridRow = [];

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

  //Filters working
  void removeAllFilter() {
    if (this.tableColumnFilterList.length > 0) {
      //Updatetable filters
      AppNotifiers.getInstance().frozenRowCountNotifier.value = 0;
      AppNotifiers.getInstance().frozenColumnCountNotifier.value = 0;

      this.tableColumnFilterList = [];
      this.rowData = [];

      this.datagridRow = [];

      this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
      this.datagridRow = this.decoupleCellObjects();

      this.columnIds = [];
      this.columnNames = [];

      this.columnIds = List<String>.from(this.staticColumnIds);
      this.columnNames = List<String>.from(this.staticColumnsData);

      this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists();
      //refresh the view
      this.refreshDataTable();
      AppNotifiers.getInstance().filterListUpdateNotifier.value =
          !AppNotifiers.getInstance().filterListUpdateNotifier.value;
    }
  }

  void addFilterToColumn(String columnId) {
    List<Map<String, dynamic>> tempRowData = [];
    List<DataGridRow> _dataGridRow = [];
    int rowIndex = 0;
    var filterableList = [];
    if (tableColumnFilterList.contains(columnId)) {
      filterableList = tableColumnFilterList.sublist(1);
    }

    for (var data in rowData) {
      if (filterableList.any((element) {
        return data[columnId]
            .toString()
            .trim()
            .toLowerCase()
            .contains(element.toString().toLowerCase().trim());
      })) {
        tempRowData.add(data);
        _dataGridRow.add(this.datagridRow[rowIndex]);
      }
      rowIndex++;
    }
    this.datagridRow = [];
    this.datagridRow = this.decoupleCellObjects(gridRows: _dataGridRow);
    this.rowData = [];
    this.rowData = List<Map<String, dynamic>>.from(tempRowData);

    this.currentFilterColumnId = columnId;

    //refreshTable
    this.refreshDataTable();

    //Updatetable filters
    AppNotifiers.getInstance().filterListUpdateNotifier.value =
        !AppNotifiers.getInstance().filterListUpdateNotifier.value;
  }

  //Hidden ColumnsWorking
  void hideColumn(String columnId) {
    int rowIndex = 0;

    List<DataGridCell> cells = [];
    for (var row in this.rowData) {
      //Remove col data fro rows
      row.remove(columnId);
      if (this.datagridRow.length > 0) {
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

    //refresh the table
    this.refreshDataTable();
    AppNotifiers.getInstance().hiddenColumnNotifier.value =
        this.hiddenColumnIds.length.toString();
  }

  List<DataGridRow> decoupleCellObjects({List<DataGridRow>? gridRows}) {
    List<DataGridRow> rowss =
        (gridRows != null ? gridRows : this.staticDatagridRow).map((e) {
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
        datagridRow[rowIndex].getCells();
    DataGridCell? cell;

    if (dataGridCells[colIndex].columnName == colId) {
      cell = dataGridCells.removeAt(colIndex);

      datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);
    }

    return cell;
  }

  void showColumn(String columnId) {
    // int rowIndex = 0;
    // //Add back the column at index
    // Map<String, dynamic> getHiddenColumnData =
    //     _getHiddenColumnDataWithColumnId(columnId);

    // int insertToColIndex = getHiddenColumnData[columnId];

    // for (var row in this.staticRowData) {
    //   if (!this.rowData[rowIndex].containsKey(columnId)) {
    //     this.rowData[rowIndex][columnId] = row[columnId];
    //     List<DataGridCell<dynamic>> dataGridCells =
    //         datagridRow[rowIndex].getCells();

    //     // List<DataGridCell<dynamic>> maindataGridCells =
    //     //     this.staticDatagridRow[rowIndex].getCells();

    //     // dataGridCells.insert(
    //     //     insertToColIndex,
    //     //     this._decoupleGridCellsObjects(
    //     //         getHiddenColumnData["cells_data"][rowIndex]));
    //     dataGridCells.insert(
    //         insertToColIndex,
    //         DataGridCell(
    //             columnName: getHiddenColumnData["column_name"] ,
    //             value: getHiddenColumnData["cells_data"][rowIndex]));

    //     datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);
    //   }

    //   rowIndex++;
    // }

    // if (getHiddenColumnData.length > 0) {
    //   this
    //       .columnNames
    //       .insert(insertToColIndex, getHiddenColumnData["column_name"]);
    //   this.columnIds.insert(insertToColIndex, columnId);
    // }

    this
        .hiddenColumnIds
        .removeWhere((element) => element.keys.toList().contains(columnId));
    this.rowData = [];

    this.datagridRow = [];

    this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
    this.datagridRow = this.decoupleCellObjects();

    this.columnIds = [];
    this.columnNames = [];

    this.columnIds = List<String>.from(this.staticColumnIds);
    this.columnNames = List<String>.from(this.staticColumnsData);

    ///refresh table
    this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists();
    AppNotifiers.getInstance().hiddenColumnNotifier.value =
        this.hiddenColumnIds.length.toString();
    this.refreshDataTable();
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

  void showAllColumn() {
    if (this.hiddenColumnIds.length > 0) {
      AppNotifiers.getInstance().frozenRowCountNotifier.value = 0;
      AppNotifiers.getInstance().frozenColumnCountNotifier.value = 0;

      this.hiddenColumnIds = [];
      this.columnNames = [];
      this.columnIds = [];
      this.columnIds = List<String>.from(this.staticColumnIds);
      this.columnNames = List<String>.from(this.staticColumnsData);
      this.rowData = [];
      this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
      this.datagridRow = [];
      this.datagridRow = List<DataGridRow>.from(this.decoupleCellObjects());

      //apply if any row column pinning and filters are there
      this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists();
      AppNotifiers.getInstance().hiddenColumnNotifier.value =
          this.hiddenColumnIds.length.toString();

      //refresh table
      this.refreshDataTable();
    }
  }

  //Column Ordering Working
  void setColumnOrdering(int sendTo, int currentPosition, String columnId) {
    int rowIndex = 0;
    int colIndex = this.columnIds.indexOf(columnId);
    for (var rowsData in this.rowData) {
      List<DataGridCell<dynamic>> dataGridCells =
          datagridRow[rowIndex].getCells();
      var value = dataGridCells.removeAt(colIndex);
      dataGridCells.insert(sendTo > 0 ? sendTo - 1 : 0, value);
      datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);

      rowIndex++;
    }

    var colValue = this.columnNames.removeAt(colIndex);
    this.columnNames.insert(sendTo > 0 ? sendTo - 1 : 0, colValue);
    colValue = this.columnIds.removeAt(colIndex);
    this.columnIds.insert(sendTo > 0 ? sendTo - 1 : 0, colValue);

    //refresh table
    this.refreshDataTable();
  }

  //Single Column pinning working
  void singleColumnPinning(int colIndex, String columnId, bool isUnPin) {
    // print("pinned col info --- ${this.pinnedColumnInfo}");
    // print("pinned col info --- ${colIndex}");
    // print("pinned col info --- ${columnId}");
    if (!isUnPin) {
      var tempRowData = List<Map<String, dynamic>>.from(this.rowData);

      int insertIndex =
          this.pinnedColumnInfo.length > 0 ? this.pinnedColumnInfo.length : 0;
      print("insert index --- $insertIndex");
      int rowIndex = 0;
      for (var rowActData in tempRowData) {
        rowActData.remove(columnId);

        List<DataGridCell<dynamic>> dataGridCells =
            datagridRow[rowIndex].getCells();
        var value = dataGridCells.removeAt(colIndex);
        dataGridCells.insert(insertIndex, value);
        datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);

        rowIndex++;
      }

      var value = this.columnNames.removeAt(colIndex);
      this.columnNames.insert(insertIndex, value);
      value = this.columnIds.removeAt(colIndex);
      this.columnIds.insert(insertIndex, value);

      ColumnPinningInfo info = ColumnPinningInfo(
          columnId: columnId,
          columnName: this.columnNames[colIndex],
          currentPosition: insertIndex,
          lastPosition: colIndex);
      print("col info to sve --- ${info.toJson()}");
      this.pinnedColumnInfo.add(info);

      //update frozen column count
      AppNotifiers.getInstance().frozenColumnCountNotifier.value += 1;
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
          (AppNotifiers.getInstance().frozenColumnCountNotifier.value - 1)) {
        insertIndex =
            (AppNotifiers.getInstance().frozenColumnCountNotifier.value - 1);
      }
      int rowIndex = 0;
      for (var rowActData in tempRowData) {
        List<DataGridCell<dynamic>> dataGridCells =
            datagridRow[rowIndex].getCells();
        var value = dataGridCells.removeAt(colIndex);
        dataGridCells.insert(insertIndex, value);
        datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);

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
      AppNotifiers.getInstance().frozenColumnCountNotifier.value -= 1;
    }
    //refresh data table with new data
    this.refreshDataTable();
  }

  //Single Row pining working
  void singleRowPinning(int currentPosition, bool isUnPin) {
    if (!isUnPin) {
      int insertIndex = this.pinnedRowInfo.length > 0
          ? this.pinnedRowInfo.length == datagridRow.length
              ? this.pinnedRowInfo.length - 1
              : this.pinnedRowInfo.length
          : 0;

      var value = datagridRow.removeAt(currentPosition);
      datagridRow.insert(insertIndex, value);
      RowPinningInfo info = RowPinningInfo();
      info.currentPosition = insertIndex;
      info.lastPosition = currentPosition;

      this.pinnedRowInfo.add(info);
      //Notify client about pinned or unpinned row

      AppNotifiers.getInstance().frozenRowCountNotifier.value += 1;
    } else {
      int insertIndex = this.pinnedRowInfo.length > 0
          ? (this
                      .pinnedRowInfo
                      .firstWhere((element) =>
                          element.currentPosition == currentPosition)
                      .lastPosition ??
                  0) +
              (this.pinnedRowInfo.length > 1 ? this.pinnedRowInfo.length : 0)
          : 0;

      var value = datagridRow.removeAt(currentPosition);
      datagridRow.insert(insertIndex, value);
      this
          .pinnedRowInfo
          .removeWhere((element) => element.currentPosition == currentPosition);
      //Notify client about pinned or unpinned row

      AppNotifiers.getInstance().frozenRowCountNotifier.value -= 1;
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
    this.refreshDataTable();
  }

  void applyAnyFilterHiddenColumnRowAndColumnPinningIfExists() {
    //Apply filter if there are any

    if (this.tableColumnFilterList.length > 0) {
      // for (String columnId in this.tableColumnFilterList.length > 1
      //     ? this.tableColumnFilterList.sublist(0, 1)
      //     : []) {

      this.addFilterToColumn(this.tableColumnFilterList[0]);
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
        this.hideColumn(columnId);
      }
    }

    //Pin columns if there are any
    var tempColInfos = this.pinnedColumnInfo.map((e) => e.copyFrom()).toList();

    this.pinnedColumnInfo = [];
    if (tempColInfos.length > 0) {
      for (var pinnedColInfos in tempColInfos) {
        this.singleColumnPinning(pinnedColInfos.lastPosition ?? 0,
            pinnedColInfos.columnId ?? "", false);
      }
    }

    //Pin rows if there are any
    var tempRowInfos = this.pinnedRowInfo.map((e) => e.copyFrom()).toList();
    this.pinnedRowInfo = [];
    if (tempRowInfos.length > 0) {
      for (var pinnedROwInfos in tempRowInfos) {
        this.singleRowPinning(pinnedROwInfos.lastPosition ?? 0, false);
      }
    }
  }

  void updateCellValue(
      int rowIndex, int colIndex, String value, Function() onCellDoubleClick) {
    this.rowData[rowIndex][this.columnIds[colIndex]] = value;
    List<DataGridCell> cells = this.datagridRow[rowIndex].getCells();

    cells[colIndex] = DataGridCell(
        columnName: this.columnNames[colIndex],
        value: TableGridCell(
          onCellDoubleTap: onCellDoubleClick,
          rowIndex: rowIndex,
          colIndex: colIndex,
          title: rowData[rowIndex][this.columnIds[colIndex]].toString(),
        ));
    this.datagridRow[rowIndex] = DataGridRow(cells: cells);
    this.refreshDataTable();
  }

  void resetTableManagerConfiguration() {
    //reset all  values from table manager
    AppNotifiers.getInstance().frozenColumnCountNotifier.value = 0;
    AppNotifiers.getInstance().frozenRowCountNotifier.value = 0;
    AppNotifiers.getInstance().paginationPageNumberNotifier.value = 1;
    this.tableColumnFilterList = [];
    this.hiddenColumnIds = [];
    this.pinnedColumnInfo = [];
    this.pinnedRowInfo = [];
  }

  void refreshDataTable() {
    AppNotifiers.getInstance().refreshDataTableNotifier.value =
        !AppNotifiers.getInstance().refreshDataTableNotifier.value;
  }
}
