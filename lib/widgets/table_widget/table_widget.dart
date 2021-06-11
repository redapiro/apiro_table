import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/data_grid/table_data_grid.dart';
import 'package:apiro_table/widgets/table_header_cell/table_header_cell.dart';
import 'package:apiro_table/widgets/table_header_cell/table_header_popup_menu_cell.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableWidget extends StatelessWidget {
  TableWidget({
    Key? key,
    required this.gridRow,
    required this.columnData,
    required this.columnIds,
    required this.rowData,
    this.groupColumnPinning = false,
    this.rowColumnPinning = false,
    this.selectableColumnText = false,
    this.selectableCellText = false,
    this.cellEditDialog = false,
    this.cellMenuOn = false,
    this.cellInlineEditing = true,
    this.columnOrderingOn = true,
    this.columnHidingOn = true,
    this.filtersOn = true,
    this.paginationPageSize = 50,
    this.paginationPageSizes = const [5, 10, 50, 100, 500],
  }) : super(key: key) {
    //Init table manager
    _tableManager = TableManager.getInstance();

    //Add data to tabke manager
    _tableManager.columnNames = columnData;
    _tableManager.columnIds = columnIds;
    _tableManager.staticColumnIds = columnIds;
    _tableManager.staticColumnsData = columnData;

    //Add row data to table manager
    _tableManager.staticRowData = rowData;
    _tableManager.rowData = rowData;

    //Data grid row
    _tableManager.datagridRow = gridRow;
    _tableManager.staticDatagridRow = gridRow;
  }

  List<String> columnData = [];
  List<String> columnIds = [];
  List<Map<String, dynamic>> rowData = [];
  List<DataGridRow> gridRow = [];

  //Column pinning properties
  bool groupColumnPinning;

  //Row column pinning
  bool rowColumnPinning;

  //Selectable column header text
  bool selectableColumnText;

  //Selectable table cell text
  bool selectableCellText;

  //Pagination page size
  int paginationPageSize;

  //Pagination page size
  List<int> paginationPageSizes;

  //Cell menu
  bool cellMenuOn = false;

  //Cell editing Dialog
  bool cellEditDialog = false;

  //cell inline editing
  bool cellInlineEditing = true;

  //cell inline editing
  bool columnOrderingOn = true;

  //cell inline editing
  bool columnHidingOn = true;

  //cell inline editing
  bool filtersOn = true;

  late BuildContext context;
  late double screenHeight;
  late TableManager _tableManager;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    screenHeight = MediaQuery.of(context).size.height;

    return Container(
        constraints: BoxConstraints(maxHeight: screenHeight),
        child: _getSFDataTable());
  }

  Widget _getSFDataTable() {
    return ValueListenableBuilder<bool>(
        valueListenable: AppNotifiers.getInstance().refreshDataTableNotifier,
        builder: (context, value, child) {
          return SfDataGrid(
              source: _tableDataGridSource(),
              frozenColumnsCount: 0,
              frozenRowsCount: 0,
              defaultColumnWidth: 150,
              headerGridLinesVisibility: GridLinesVisibility.none,
              headerRowHeight: 60,
              rowHeight: 60,
              gridLinesVisibility: GridLinesVisibility.none,
              columns: List.generate(this.columnData.length, (index) {
                return GridTextColumn(
                  minimumWidth: 150,
                  columnName: this.columnData[index],
                  label: TableColumnHeaderPopMenuButtonWidget(
                    title: this.columnData[index],
                    popUpButtonHeight: 50,
                    metadata: {},
                    isPinned: false,
                    tableFilterList: _tableManager.tableColumnFilterList,
                    onColumnmPinClick: () {
                      _columnPinClick(_tableManager.columnIds[index]);
                    },
                    onColumnmFilterClick: (filterList) {
                      _onColumnFiterClick(
                          filterList, _tableManager.columnIds[index]);
                    },
                    onColumnmHideClick: () {
                      _onHideColumnClick(_tableManager.columnIds[index]);
                    },
                    onColumnOrderingSet: (indexToShiftOn) {
                      _onColumnOrdering(_tableManager.columnIds[index],
                          indexToShiftOn, index);
                    },
                    tootipName: _tableManager.columnNames[index],
                  ),
                );
              }));
        });
  }

  TableDataGrid _tableDataGridSource() {
    return TableDataGrid(context: this.context, gridRow: this.gridRow);
  }

  //On click methods
  void _columnPinClick(String columnId) {}

  void _onColumnFiterClick(List<String> filterList, String columnId) {
    _tableManager.tableColumnFilterList = filterList;
    _tableManager.addFilterToColumn(columnId);
  }

  void _onHideColumnClick(String columnId) {
    _tableManager.hideColumn(columnId);
  }

  void _onColumnOrdering(String columnId, int sendTo, int currentPosition) {
    _tableManager.setColumnOrdering(sendTo, currentPosition, columnId);
  }
}
