import 'package:apiro_table/model/column_pinning_info.dart';
import 'package:apiro_table/model/row_pinning_info.dart';
import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/widgets/table_cell/table_cell.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableManager {
  static final TableManager _instance = TableManager._internal();
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
    this.tableColumnFilterList = [];
    this.rowData = [];

    this.datagridRow = [];

    this.rowData = List<Map<String, dynamic>>.from(this.staticRowData);
    this.datagridRow = this.decoupleCellObjects();

    this.columnIds = [];
    this.columnNames = [];

    this.columnIds = List<String>.from(this.staticColumnIds);
    this.columnNames = List<String>.from(this.staticColumnsData);
    //Updatetable filters
    AppNotifiers.getInstance().filterListUpdateNotifier.value =
        !AppNotifiers.getInstance().filterListUpdateNotifier.value;

    this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists();
    //refresh the view
    this.refreshDataTable();
  }

  void addFilterToColumn(String columnId) {
    List<Map<String, dynamic>> tempRowData = [];
    List<DataGridRow> _dataGridRow = [];
    int rowIndex = 0;
    for (var data in rowData) {
      if (tableColumnFilterList.any((element) => element
          .toLowerCase()
          .contains(data[columnId].toString().toLowerCase()))) {
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
        print("column Id index -- $colIndex $columnId");
        DataGridCell? gridCell =
            removeDataGridRowForColumn(colIndex, rowIndex, columnId);
        print("Grid Cell is there -- $gridCell");

        if (gridCell != null) {
          cells.add(gridCell);
        }
      }
      rowIndex++;
    }

    // remove data from column id and name
    int colIndex = this.columnIds.indexOf(columnId);
    this.columnIds.remove(columnId);
    var colName = this.columnNames.removeAt(colIndex);

    print(
        "length of grid row -- ${this.datagridRow.length} and column ${columnIds.length}  and column name ${this.columnNames.length} and current col id $columnId");

    //save the columnId to unhide colum in future

    this
        .hiddenColumnIds
        .add({columnId: colIndex, "cells_data": cells, "column_name": colName});

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
            columnName: this.columnIds[index]);
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
    int rowIndex = 0;
    //Add back the column at index
    Map<String, dynamic> getHiddenColumnData =
        _getHiddenColumnDataWithColumnId(columnId);

    int insertToColIndex = getHiddenColumnData[columnId];

    for (var row in this.staticRowData) {
      if (!this.rowData[rowIndex].containsKey(columnId)) {
        this.rowData[rowIndex][columnId] = row[columnId];
        List<DataGridCell<dynamic>> dataGridCells =
            datagridRow[rowIndex].getCells();

        List<DataGridCell<dynamic>> maindataGridCells =
            this.staticDatagridRow[rowIndex].getCells();

        dataGridCells.insert(
            insertToColIndex,
            this._decoupleGridCellsObjects(
                getHiddenColumnData["cells_data"][rowIndex]));

        datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);
      }

      rowIndex++;
    }

    if (getHiddenColumnData.length > 0) {
      this
          .columnNames
          .insert(insertToColIndex, getHiddenColumnData["column_name"]);
      this.columnIds.insert(insertToColIndex, columnId);
    }

    this
        .hiddenColumnIds
        .removeWhere((element) => element.keys.toList()[0] == columnId);
    AppNotifiers.getInstance().hiddenColumnNotifier.value =
        this.hiddenColumnIds.length.toString();
    //refresh table
    this.refreshDataTable();
  }

  //get hidden column data from column id
  Map<String, dynamic> _getHiddenColumnDataWithColumnId(String columnId) {
    Map<String, dynamic> hiddenColumnData = {};
    if (this.hiddenColumnIds.length > 0) {
      hiddenColumnData = this.hiddenColumnIds.firstWhere(
          (element) => element.keys.toList()[0] == columnId, orElse: () {
        return {};
      });
    }
    return hiddenColumnData;
  }

  void showAllColumn() {
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
    if (!isUnPin) {
      var tempRowData = List<Map<String, dynamic>>.from(this.rowData);

      int insertIndex = this.pinnedColumnInfo.length > 0
          ? this.pinnedColumnInfo.length - 1
          : 0;

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
      int insertIndex =
          this.pinnedRowInfo.length > 0 ? this.pinnedRowInfo.length - 1 : 0;

      var value = datagridRow.removeAt(currentPosition);
      datagridRow.insert(insertIndex, value);
      RowPinningInfo info = RowPinningInfo();
      info.currentPosition = insertIndex;
      info.lastPosition = currentPosition;

      this.pinnedRowInfo.add(info);
      AppNotifiers.getInstance().frozenRowCountNotifier.value += 1;
    } else {
      int insertIndex = this.pinnedRowInfo.length > 0
          ? this
                  .pinnedRowInfo
                  .firstWhere(
                      (element) => element.currentPosition == currentPosition)
                  .lastPosition ??
              0
          : 0;

      var value = datagridRow.removeAt(currentPosition);
      datagridRow.insert(insertIndex, value);
      this
          .pinnedRowInfo
          .removeWhere((element) => element.lastPosition == currentPosition);
      AppNotifiers.getInstance().frozenRowCountNotifier.value -= 1;
    }

    //Notify client about pinned or unpinned row
    AppNotifiers.getInstance()
        .isRowunpinController
        .add(this.pinnedRowInfo.map((e) => e.lastPosition ?? 0).toList());

    //refresh table with new data
    this.refreshDataTable();
  }

  void applyAnyFilterHiddenColumnRowAndColumnPinningIfExists() {
    //Apply filter if there are any
    if (this.tableColumnFilterList.length > 0) {
      for (String columnId in this.tableColumnFilterList) {
        this.addFilterToColumn(columnId);
      }
    }

    // hide columns if here are any
    if (this.hiddenColumnIds.length > 0) {
      for (var columnData in this.hiddenColumnIds) {
        String columnId = columnData.keys.toList()[0];
        this.hideColumn(columnId);
      }
    }

    //Pin columns if there are any
    //Pin rows if there are any
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

  void refreshDataTable() {
    AppNotifiers.getInstance().refreshDataTableNotifier.value =
        !AppNotifiers.getInstance().refreshDataTableNotifier.value;
  }
}
