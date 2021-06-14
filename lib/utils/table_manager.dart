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
    this.datagridRow = List<DataGridRow>.from(this.staticDatagridRow);

    this.columnIds = [];
    this.columnNames = [];

    this.columnIds = List<String>.from(this.staticColumnIds);
    this.columnNames = List<String>.from(this.staticColumnsData);

    this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists();
    //refresh the view
    this.refreshDataTable();
  }

  void addFilterToColumn(String columnId) {
    print("inside filter");
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
    this.datagridRow = List<DataGridRow>.from(_dataGridRow);
    this.rowData = [];
    this.rowData = List<Map<String, dynamic>>.from(tempRowData);

    this.currentFilterColumnId = columnId;

    //refreshTable
    this.refreshDataTable();
  }

  void _removeRowFromDataGridWithRowIndex(int rowIndex) {
    datagridRow.removeAt(rowIndex);
  }

  //Hidden ColumnsWorking
  void hideColumn(String columnId) {
    int rowIndex = 0;
    Map<String, dynamic> cellsData = {};
    List<DataGridRow> gridRows = [];
    cellsData["cells_data"] = [];
    for (var row in this.rowData) {
      //Remove col data fro rows
      row.remove(columnId);
      if (this.datagridRow.length > 0) {
        int colIndex = this.columnIds.indexOf(columnId);

        removeDataGridRowForColumn(colIndex, rowIndex, columnId);
      }
    }

    // remove data from column id and name
    int colIndex = this.columnIds.indexOf(columnId);
    this.columnIds.remove(columnId);
    this.columnNames.removeAt(colIndex);

    //save the columnId to unhide colum in future
    this.hiddenColumnIds.add({columnId: colIndex});

    AppNotifiers.getInstance().hiddenColumnNotifier.value =
        this.hiddenColumnIds.length.toString();

    //refresh the table
    this.refreshDataTable();
  }

  List<DataGridRow> decoupleCellObjects() {
    List<DataGridRow> rowss = this.staticDatagridRow.map((e) {
      return DataGridRow(
          cells: List.generate(e.getCells().length, (index) {
        return DataGridCell(
            value: e.getCells()[index].value,
            columnName: this.columnIds[index]);
      }));
    }).toList();
    return rowss;
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
    for (var row in this.staticRowData) {
      print("row data -- $rowData");
      if (!this.rowData[rowIndex].containsKey(columnId)) {
        this.rowData[rowIndex][columnId] = row[columnId];
        List<DataGridCell<dynamic>> dataGridCells =
            datagridRow[rowIndex].getCells();
        int colIndex = this.staticColumnIds.indexOf(columnId);
        List<DataGridCell<dynamic>> maindataGridCells =
            this.staticDatagridRow[rowIndex].getCells();

        dataGridCells.insert(colIndex, maindataGridCells[colIndex]);

        datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);
      }

      rowIndex++;
    }

    //Add back the column at index
    Map<String, dynamic> getHiddenColumnData =
        _getHiddenColumnDataWithColumnId(columnId);
    print(
        "both column data comparision column length ${this.staticColumnsData.length}");
    print(
        "both column data comparision column length ${this.columnNames.length}");
    print("hidden column data -- $getHiddenColumnData");
    print(
        "hidden column data -- ${this.staticColumnsData[getHiddenColumnData[columnId]]}");
    if (getHiddenColumnData.length > 0) {
      this.columnNames.insert(getHiddenColumnData[columnId],
          this.staticColumnsData[getHiddenColumnData[columnId]]);
      this.columnIds.insert(getHiddenColumnData[columnId], columnId);
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
      print("unpin insert at -- ${insertIndex}");
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
    print(
        "updated last value ${this.rowData[rowIndex][this.columnIds[colIndex]]} with $value ");
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
