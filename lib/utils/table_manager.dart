import 'package:apiro_table/utils/app_notifiers.dart';
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
    this._refreshDataTable();
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
    this._refreshDataTable();
  }

  void _removeRowFromDataGridWithRowIndex(int rowIndex) {
    datagridRow.removeAt(rowIndex);
  }

  //Hidden ColumnsWorking
  void hideColumn(String columnId) {
    int rowIndex = 0;
    List<DataGridRow> gridRows = [];
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

    //refresh the table
    this._refreshDataTable();
  }

  //remove data from datagrid row if exists
  void removeDataGridRowForColumn(int colIndex, int rowIndex, String colId) {
    List<DataGridCell<dynamic>> dataGridCells =
        datagridRow[rowIndex].getCells();

    if (dataGridCells[colIndex].columnName == colId) {
      dataGridCells.removeAt(colIndex);

      datagridRow[rowIndex] = DataGridRow(cells: dataGridCells);
    }
  }

  void showColumn(String columnId) {
    int rowIndex = 0;
    for (var row in this.staticRowData) {
      if (!this.rowData[rowIndex].containsKey(columnId)) {
        this.rowData[rowIndex][columnId] = row[columnId];
        List<DataGridCell<dynamic>> dataGridCells =
            datagridRow[rowIndex].getCells();
        List<DataGridCell<dynamic>> maindataGridCells =
            this.staticDatagridRow[rowIndex].getCells();
        dataGridCells.insert(rowIndex, maindataGridCells[rowIndex]);
      }

      rowIndex++;
    }

    //Add back the column at index
    Map<String, dynamic> getHiddenColumnData =
        _getHiddenColumnDataWithColumnId(columnId);
    if (getHiddenColumnData.length > 0)
      this.columnNames.insert(getHiddenColumnData[columnId],
          this.staticColumnsData[getHiddenColumnData[columnId]]);

    //refresh table
    this._refreshDataTable();
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
    this.datagridRow = List<DataGridRow>.from(this.staticDatagridRow);

    //apply if any row column pinning and filters are there
    this.applyAnyFilterHiddenColumnRowAndColumnPinningIfExists();

    //refresh table
    this._refreshDataTable();
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
    this._refreshDataTable();
  }

  //Single Column pinning working
  void singleColumnPinning(int sendTo, int currentPosition, String columnId) {}

  //Single Row pining working
  void singleRowPinning(int sendTo, int currentPosition, String columnId) {}

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

  void _refreshDataTable() {
    AppNotifiers.getInstance().refreshDataTableNotifier.value =
        !AppNotifiers.getInstance().refreshDataTableNotifier.value;
  }
}
