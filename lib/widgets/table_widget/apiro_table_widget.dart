import 'dart:convert';

import 'package:apiro_table/model/column_pinning_info.dart';
import 'package:apiro_table/model/row_pinning_info.dart';
import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/utils/constants.dart';
import 'package:apiro_table/utils/enum/cell_data_type.dart';
import 'package:apiro_table/utils/provider_helper.dart';
import 'package:apiro_table/utils/table_manager/table_manager.dart';
import 'package:apiro_table/widgets/custom_pagination/custom_paginations.dart';
import 'package:apiro_table/widgets/data_grid/table_data_grid.dart';
import 'package:apiro_table/widgets/hidden_column_drop_down/hidden_column_drop_down.dart';
import 'package:apiro_table/widgets/pinned_row_pop_up/pinned_row_pop_up_widget.dart';
import 'package:apiro_table/widgets/table_cell/table_cell.dart';
import 'package:apiro_table/widgets/table_cell/table_cell_detail_widget.dart';
import 'package:apiro_table/widgets/table_header_cell/table_header_popup_menu_cell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../utils/controller/global_controllers.dart';

// ignore: must_be_immutable
typedef TableSortWidgetFunction = Widget Function(int index);
class ApiroTableWidget extends StatelessWidget {
  ApiroTableWidget({
    Key? key,
    this.gridRow = const [],
    required this.columnData,
    required this.context,
    required this.columnIds,
    required this.rowData,
    this.getPinnedRowStream,
    required this.tableHeight,
    required this.onItemPerPageChange,
    required this.onNextClick,
    required this.onPageNumberClick,
    required this.onPageNumberDropDownSelect,
    required this.onPageNumberTextFieldSubmit,
    required this.onPreviousClick,
    required this.totalNumberOfPages,
    required this.totalNumberOfItems,
    this.tableSortWidget,
    this.hiddenColumnInfos = const [],
    this.filterList = const [],
    this.onColumnClick,
    this.onPinRow,
    this.onStatusFilterChange,
    this.sortIcons,
    this.columnIdFilterAppliedOn = "",
    this.widgetInTableHeaderRow,
    this.updateDataOnColumnPinned,
    this.updateDataOnFilterColumn,
    this.updateDataOnHideColumn,
    this.groupColumnPinning = false,
    this.rowGroupPinning = false,
    this.shouldResetTableConfigs = false,
    this.showTableHeaderBar = true,
    this.selectableColumnText = false,
    this.selectableCellText = false,
    this.cellEditDialog = false,
    this.isPaginationVisible = true,
    this.cellMenuOn = false,
    this.cellInlineEditing = true,
    this.columnOrderingOn = true,
    this.columnHidingOn = true,
    this.defaultStatusSortFilter,
    this.headerWidgetIsVisible = true,
    this.filtersOn = true,
    this.pinnedColumnInfo = const [],
    this.rateKeyData,
    this.columnOrderingInfo = const [],
    this.descriptionOfTitle,
    this.paginationPageSize = 50,
    this.updateDataOnColumnOrdering,
    this.onUnHideTheItem,
    this.hiddenFilterTextFieldListIds,
    this.paginationPageSizes = const [5, 10, 50, 100, 500],
    this.statusFilter = Constants.statusFilters,
  }) : super(key: key) {
    //Init table manager
    if (shouldResetTableConfigs)
      TableManager.getInstance().resetTableManagerConfiguration();
    _tableManager = TableManager.getInstance();

    setupData(inConstructor: this.gridRow.length != 0);

    _tableManager.hiddenColumnIds =
        List<Map<String, dynamic>>.from(this.hiddenColumnInfos);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .riverPodReadStateNotifier(hiddenColumnNumberNotifier.notifier)
          .updateValue(0);
      context
          .riverPodReadStateNotifier(statusSortNotifier.notifier)
          .updateValue(defaultStatusSortFilter ?? 'ALL');
      //refresh the table
    });
    _tableManager.onRowPinning = this.onPinRow;
    _tableManager.tableColumnFilterList = List<String>.from(this.filterList);
    print("setting column pinning info");
    this.orderColumnsFromRemoteData();
    this.hideColumnsFromRemoteData();
    this.pinColumnsFromRemote();

    _tableManager
        .applyAnyFilterHiddenColumnRowAndColumnPinningIfExists(context);

    perPageRowCountList = paginationPageSizes.map((e) => e.toString()).toList();
    perPageRowCountNotifier.value = paginationPageSizes.firstWhere(
        (element) => element == this.paginationPageSize, orElse: () {
      return 0;
    }).toString();

    //Initialize app notifier
  }

  List<String> columnData = [];
  final List<String>? rateKeyData;
  final BuildContext context;
  final Function(String?)? onStatusFilterChange;
  final List<String> statusFilter;
  final Map<String, dynamic>? descriptionOfTitle;

  List<String> columnIds = [];
  final List<String> rateKeys = [];
  final String? defaultStatusSortFilter;

  List<Map<String, dynamic>> rowData = [];
  List<DataGridRow> gridRow = [];

  Widget? widgetInTableHeaderRow;
  TableSortWidgetFunction? tableSortWidget;

  //Column pinning properties
  bool groupColumnPinning;
  List<String>? sortIcons;

  //Row column pinning
  bool rowGroupPinning;

  //Selectable column header text
  bool selectableColumnText;
  bool headerWidgetIsVisible;

  //Selectable table cell text
  bool selectableCellText;

  //Table height
  double tableHeight;

  //Pagination page size
  int paginationPageSize;

  //Pagination page size
  List<int> paginationPageSizes;
  List<String>? hiddenFilterTextFieldListIds;

  //Cell menu
  bool cellMenuOn = false;

  //Cell editing Dialog
  bool cellEditDialog = false;

  //cell inline editing
  bool cellInlineEditing = true;

  //cell inline editing
  bool columnOrderingOn = true;
  bool isPaginationVisible = true;

  //cell inline editing
  bool columnHidingOn = true;

  //cell inline editing
  bool filtersOn = true;

  //table header shiw hide
  bool showTableHeaderBar = true;

  //need to reset table config
  bool shouldResetTableConfigs = false;

  //number of pages
  int totalNumberOfPages;
  int totalNumberOfItems;


  //Callback for row pinning
  Function(Stream<List<Map<String, dynamic>>>, Function(int, bool))?
  getPinnedRowStream;

  //****************Pagination callback methods */
  Function(int, int) onPageNumberClick;
  Function(int, int) onNextClick;
  Function(int, int, int) onItemPerPageChange;
  Function(int, int, int) onPageNumberDropDownSelect;
  Function(int, int) onPreviousClick;
  Function(int, int) onPageNumberTextFieldSubmit;

  Function(String, Function(bool), Function(Map<String, dynamic>))?
      onColumnClick;

  //************* Call back methods to work after filter and hide columns */
  Function(List<Map<String, dynamic>>)? updateDataOnHideColumn;
  Function(List<String>, String)? updateDataOnFilterColumn;
  Function(String, int)? updateDataOnColumnPinned;

  Function(String columnName, int sendTo, int currentPosition)?
      updateDataOnColumnOrdering;
  Function()? onUnHideTheItem;

  //***********Variables to manage hideen columns and filters if any */
  List<String> filterList = [];
  String columnIdFilterAppliedOn = "";
  List<Map<String, dynamic>> hiddenColumnInfos = [];
  List<Map<String, dynamic>> pinnedColumnInfo = [];
  List<Map<String, dynamic>> columnOrderingInfo = [];

  // /Pagination variables

  TextEditingController _jumpToPageController = TextEditingController();
  FocusNode _jumpToPageTextFiledFocusNode = FocusNode();

  //****** Will be called from here when fliter reset all data */
  Function()? onPinRow;

  ValueNotifier<String> perPageRowCountNotifier = ValueNotifier<String>("5");
  List<String> perPageRowCountList = ["5", "10", "30", "40", "50", "100"];


  late TableManager _tableManager;

  List<String> colData = [];
  List<String> colIds = [];
  List<GridColumn> columns = [];

  // List<Map<String, dynamic>> rowData = [];

  @override
  Widget build(BuildContext context) {
    context = context;
    // screenHeight = MediaQuery.of(context).size.height;
    // screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: key,
      body: Consumer(builder: (context, value, child) {
        if (columns.isEmpty) {}
        return Container(
            width:
            kIsWeb ? MediaQuery
                .of(context)
                .size
                .width : double.maxFinite,
            constraints: BoxConstraints(
                maxHeight: kIsWeb
                    ? MediaQuery
                    .of(context)
                    .size
                    .height
                    : double.maxFinite),
            child: Column(
              children: [
                if (this.showTableHeaderBar)
                  HiddenColumnDropDown(
                      leftWidget: this.widgetInTableHeaderRow,
                      hideColumns: onUnHideTheItem,
                      clearAllPress: () {
                        this.updateDataOnFilterColumn!([], "");
                      },
                      showAllPress: () {
                        this.updateDataOnHideColumn!([]);
                      },
                      showColumnPress: () {
                        sendUpdateCallback();
                      }),
                Row(
                  children: [
                    Expanded(child: _getSFDataTable()),
                    if (value.watch(pinnedRowWidgetNotifier) != null)
                      value.watch(pinnedRowWidgetNotifier) ?? Container()
                  ],
                ),
              ],
            ));
      }),
    );
  }

  Widget _getSFDataTable() {
    return Consumer(builder: (context, ref, child) {
      ref.watch(refreshDataTableNotifier);
      return Column(
        children: [
          Container(
              height: tableHeight - 120,
              width:
              kIsWeb ? MediaQuery
                  .of(context)
                  .size
                  .width : double.maxFinite,
              child: SfDataGrid(
                source: _tableDataGridSource(ref),
                allowColumnsDragging: true,
                onColumnDragging: (DataGridColumnDragDetails details) {
                  if (details.action == DataGridColumnDragAction.dropped &&
                      details.to != null) {
                    // var removedItem = columns.removeAt(details.from);
                    // columns.insert(details.to!, removedItem);
                    _onColumnOrdering(_tableManager.columnIds[details.from],
                        details.to! + 1, details.from + 1);
                    _reloadTableData();
                  }
                  return true;
                },
                frozenColumnsCount: ref.read(frozenColumnCountNotifier),
                frozenRowsCount: ref.watch(frozenRowCountNotifier),
                defaultColumnWidth: 150,
                columnWidthMode: ColumnWidthMode.fill,
                headerGridLinesVisibility: GridLinesVisibility.none,
                headerRowHeight: 90,
                rowHeight: 60,
                gridLinesVisibility: GridLinesVisibility.none,
                columns:
                List.generate(_tableManager.columnNames.length, (index) {
                  ColumnPinningInfo colInfo;
                  colInfo = _tableManager.pinnedColumnInfo.firstWhere(
                          (element) =>
                      element.columnId == _tableManager.columnIds[index],
                      orElse: () {
                        return ColumnPinningInfo();
                      });
                  return GridColumn(
                    minimumWidth: 150,
                    columnName: _tableManager.columnNames[index],
                    label: TableColumnHeaderPopMenuButtonWidget(
                      index: index,rateKeyData: rateKeyData??[],
                      isVisible: headerWidgetIsVisible,statusFilter: statusFilter,
                      title: _tableManager.columnIds[index],
                      statusSortNotifier: statusSortNotifier,
                      isFiltersTextFieldVisible:
                          hiddenFilterTextFieldListIds != null
                              ? hiddenFilterTextFieldListIds!.isNotEmpty
                                  ? !hiddenFilterTextFieldListIds!
                                      .contains(_tableManager.columnIds[index])
                                  : true
                              : true,
                      pinnedColumnInfo: _tableManager.pinnedColumnInfo,
                      popUpButtonHeight: 150,
                      sortIcon: sortIcons?[index] ?? 'null',
                      columnOrderKey: Key('columnOrderKey_' +
                          _tableManager.columnNames[index].toLowerCase()),
                      hideKey: Key('hideKey_' +
                          _tableManager.columnNames[index].toLowerCase()),
                      columnPinKey: Key('columnPinKey_' +
                          _tableManager.columnNames[index].toLowerCase()),
                      filtersPopUpKey: Key('filtersPopUpKey_' +
                          _tableManager.columnNames[index].toLowerCase()),
                      isFilterOn: this.filtersOn,
                      isColumnOrderingOn: this.columnOrderingOn,
                      isColumnHidingOn: this.columnHidingOn,
                      selectableText: selectableColumnText,
                      metaData: {},
                      tableSortWidget: tableSortWidget,
                      isPinned: colInfo.columnId != null,
                      id: _tableManager.columnIds[index],
                      tableFilterList: _tableManager.tableColumnFilterList,
                      onColumnClick:
                          (columnId, shouldShowSortWidget, updateMetaData) {
                        if (this.onColumnClick != null) {
                          this.onColumnClick!(
                              columnId, shouldShowSortWidget, updateMetaData);
                        }
                      },
                      clearAllCallback: () {
                        this.updateDataOnFilterColumn!([], "");
                      },
                      onColumnPinClick: () {
                        _columnPinClick(_tableManager.columnIds[index], index,
                            colInfo.columnId != null);
                      },
                      onColumnFilterClick: (filterList) {
                        _onColumnFiterClick(
                            filterList, _tableManager.columnIds[index]);
                      },
                      onColumnHideClick: () {
                        _onHideColumnClick(_tableManager.columnIds[index]);
                      },
                      onColumnOrderingSet: (indexToShiftOn) {
                        _onColumnOrdering(_tableManager.columnIds[index],
                            indexToShiftOn, index);
                      },
                      toolTipName: descriptionOfTitle != null
                          ? descriptionOfTitle![
                              _tableManager.columnNames[index]].toString()
                          : _tableManager.columnNames[index],
                      columnIndex: index,
                    ),
                  );
                }),
              )),
         if(isPaginationVisible) Row(
            children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: CustomPaginationWidget(
                      onPageNumberClick: (value) {
                        _onPageNumberClick(value);
                      },
                      onNextClick: () {
                        _onNextClick();
                      },
                      onItemsPerPageChange: () {
                        _onItemPerPageChange();
                      },
                      jumpToPageTextFieldFocusNode:
                          _jumpToPageTextFiledFocusNode,
                      jumpToPageNumberController: _jumpToPageController,
                      onPageNumberSelect: (selectedPageNumber) {
                        _onPageNumberDropDownSelect(selectedPageNumber);
                      },
                      onPreviousClick: () {
                        _onPreviousClick();
                      },
                      onTextFieldSubmit: (data) {
                        _onTextFiledSubmit();
                      },
                      pageNumbers: perPageRowCountList,
                      totalNumberOfItems: totalNumberOfItems,
                      // paginationPageNumberNotifier:
                      //     AppNotifiers.getInstance().paginationPageNumberNotifier,
                      perPageRowCountNotifier: this.perPageRowCountNotifier,
                      totalNumberOfPages: this.totalNumberOfPages,
                    ),
                  ),
                ),
              ],
            )
        ],
      );
    });
  }

  final statusSortNotifier =
      StateNotifierProvider<StatusSortNotifier, String>((ref) {
    return StatusSortNotifier();
  });

  TableDataGrid _tableDataGridSource(WidgetRef ref) {
    var modifiedDataGridRow = List<DataGridRow>.from(_tableManager.dataGridRow);
    // print("ENTEFRED HERE ${ref.watch(statusSortNotifier)}");
    if (ref.watch(statusSortNotifier) != 'ALL') {
      modifiedDataGridRow.removeWhere((element) {
        return element
                .getCells()
                .firstWhere((element) => element.columnName.toLowerCase() == 'status')
                .value
                .value
                .toString()
                .toLowerCase() !=
            (ref.watch(statusSortNotifier) != 'VIOLATED'
                ? ref.watch(statusSortNotifier).toLowerCase()
                : 'violation');
      });
    }

    return TableDataGrid(context: this.context, gridRow: modifiedDataGridRow);
  }

  //On click methods
  void _columnPinClick(String columnId, int currentPosition, bool isUnPin) {
    print('obj');
    if (this.groupColumnPinning) {
      context
          .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
          .decrement();
    } else {
      _tableManager.singleColumnPinning(
          currentPosition, columnId, isUnPin, context);
    }
    this.updateDataOnColumnPinned!(columnId, currentPosition);
  }

  //Pin Columns from firebase
  void pinColumnsFromRemote() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.riverPodReadStateNotifier(isRefreshingTable.notifier).updateValue(
          false);
    });
    _tableManager.pinnedColumnInfo = [];
    for (var i = 0; i < this.pinnedColumnInfo.length; i++) {
      String key = this.pinnedColumnInfo[i].keys.toList()[0];
      _tableManager.pinnedColumnInfo.add(ColumnPinningInfo.fromJson({
        "column_id": key,
        "column_name": key,
        "last_position": this.pinnedColumnInfo[i][key],
        "current_position": this.pinnedColumnInfo[i][key]
      }));
      print("column pinning info added -- ${this.pinnedColumnInfo}");
    }
    print(
        "value to compare here -- ${context.riverPodReadStateNotifier(
            frozenColumnCountNotifier)} and ${_tableManager.pinnedColumnInfo
            .length}");
    if (context.riverPodReadStateNotifier(frozenColumnCountNotifier) <
        _tableManager.pinnedColumnInfo.length &&
        context.riverPodReadStateNotifier(frozenColumnCountNotifier) !=
            _tableManager.pinnedColumnInfo.length) {
      this._reloadTableData();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context
            .riverPodReadStateNotifier(frozenColumnCountNotifier.notifier)
            .updateValue(0);
      });
      // AppNotifiers.getInstance().frozenColumnCountNotifier.value =0;
    }
  }

  //OrderColumns from Firebase
  void orderColumnsFromRemoteData() {
    for (var i = 0; i < this.columnOrderingInfo.length; i++) {
      if (this.columnOrderingInfo[i].keys
          .toList()
          .length > 0) {
        String key = this.columnOrderingInfo[i].keys.toList()[0];

        this._onColumnOrdering(key, this.columnOrderingInfo[i][key][0],
            this.columnOrderingInfo[i][key][1]);
        print("column ordering info added -- $columnOrderingInfo");
      }
    }

    // this._reloadTableData();
  }

  void hideColumnsFromRemoteData() {
    for (var i = 0; i < this.hiddenColumnInfos.length; i++) {
      if (this.hiddenColumnInfos[i].keys.toList().length > 0) {
        String key = this.hiddenColumnInfos[i].keys.toList()[0];
        _onHideColumnClick(key);

        // this._onColumnOrdering(key, this.columnOrderingInfo[i][key][0],
        //     this.columnOrderingInfo[i][key][1]);
        print("column ordering info added -- $columnOrderingInfo");
      }
    }

    // this._reloadTableData();
  }

  ///

  ///

  ///
  void _onColumnFiterClick(List<String> filterList, String columnId) {
    _tableManager.tableColumnFilterList = filterList;
    _tableManager.addFilterToColumn(columnId, context);
    if (updateDataOnFilterColumn != null)
      updateDataOnFilterColumn!(_tableManager.tableColumnFilterList,
          _tableManager.currentFilterColumnId);
  }

  void _onHideColumnClick(String columnId) {
    _tableManager.hideColumn(columnId, context);
    sendUpdateCallback();
  }

  void sendUpdateCallback() {
    if (updateDataOnHideColumn != null) {
      List<Map<String, dynamic>> tempHiddenData = [];
      var tempDataList = _tableManager.hiddenColumnIds;
      _tableManager.hiddenColumnIds = [];

      for (var colData in tempDataList) {
        var cellsData = colData["cells_data"];
        colData["cells_data"] = [];
        tempHiddenData.add(colData);
        colData["cells_data"] = cellsData;
        _tableManager.hiddenColumnIds.add(colData);
      }
      updateDataOnHideColumn!(tempHiddenData.map((e) {
        return e;
      }).toList());
    }
  }

  void _onColumnOrdering(String columnId, int sendTo, int currentPosition) {
    _tableManager.setColumnOrdering(sendTo, currentPosition, columnId, context);
    if (this.updateDataOnColumnOrdering != null) {
      this.updateDataOnColumnOrdering!(columnId, sendTo, currentPosition);
    }
  }

  //Pagination Methods
  void _onPageNumberClick(int pageNumber) {
    context.riverPodReadStateNotifier(paginationPageNumberNotifier.notifier)
        .updateValue(pageNumber);

    this.onPageNumberClick(
        context.riverPodReadStateNotifier(paginationPageNumberNotifier),
        this.totalNumberOfPages);
    _reloadTableData();
  }

  void _onTextFiledSubmit() {
    if (_jumpToPageTextFiledFocusNode.hasFocus) {
      _jumpToPageTextFiledFocusNode.unfocus();

      if (int.parse(_jumpToPageController.text.trim()) >
          this.totalNumberOfPages) {
        showSnackBarWithMessage(
            "Page number is not valid " + _jumpToPageController.text,
            context: context);
      } else {
        context.riverPodReadStateNotifier(paginationPageNumberNotifier.notifier)
            .updateValue(
            int.parse(_jumpToPageController.text.trim()));
        this.onPageNumberTextFieldSubmit(
            context.riverPodReadStateNotifier(paginationPageNumberNotifier),
            this.totalNumberOfPages);
        _reloadTableData();
      }
    }
  }

  void showSnackBarWithMessage(String message,
      {required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .error,
      ),
    );
  }

  void _onItemPerPageChange() {
    context.riverPodReadStateNotifier(paginationPageNumberNotifier.notifier)
        .updateValue(1);

    // this.totalNumberOfPages =
    //     (this.rowData.length ~/ int.parse(this.perPageRowCountNotifier.value));

    this.onItemPerPageChange(
        context.riverPodReadStateNotifier(paginationPageNumberNotifier),
        this.totalNumberOfPages,
        int.parse(this.perPageRowCountNotifier.value));
    if ((this.rowData.length % int.parse(this.perPageRowCountNotifier.value)) >
        0) {
      this.totalNumberOfPages += 1;
    }

    _reloadTableData();
  }

  void _onNextClick() {
    context.riverPodReadStateNotifier(paginationPageNumberNotifier.notifier)
        .increment();
    this.onNextClick(
        context.riverPodReadStateNotifier(paginationPageNumberNotifier),
        this.totalNumberOfPages);
    _reloadTableData();
  }

  void _onPageNumberDropDownSelect(int value) {
    this.perPageRowCountNotifier.value = value.toString();

    _reloadTableData();
  }

  void _onPreviousClick() {
    context.riverPodReadStateNotifier(paginationPageNumberNotifier.notifier)
        .decrement();
    this.onPreviousClick(
        context.riverPodReadStateNotifier(paginationPageNumberNotifier),
        this.totalNumberOfPages);
    _reloadTableData();
  }

  void _reloadTableData() {
    TableManager.getInstance().refreshDataTable(context);
  }

  void setupData({bool inConstructor = false}) {
    if (inConstructor) {
      //Setting up table data when it is coming from constructor
      _tableManager.columnNames = List<String>.from(this.columnData);
      _tableManager.columnIds = List<String>.from(this.columnIds);
      _tableManager.staticColumnIds = List<String>.from(this.columnIds);
      _tableManager.staticColumnsData = List<String>.from(this.columnData);

      _tableManager.staticRowData =
      List<Map<String, dynamic>>.from(this.rowData);
      _tableManager.rowData = List<Map<String, dynamic>>.from(this.rowData);

      //Data grid row
      _tableManager.dataGridRow = [];
      List<DataGridRow> rowss = this.gridRow.map((e) {
        return DataGridRow(
            cells: List.generate(e
                .getCells()
                .length, (index) {
              return DataGridCell(
                  value: e.getCells()[index].value,
                  columnName: this.columnIds[index]);
            }));
      }).toList();
      _tableManager.dataGridRow = List<DataGridRow>.from(this.gridRow);

      _tableManager.staticDataGridRow = [];
      _tableManager.staticDataGridRow = List<DataGridRow>.from(rowss);
    } else {
      _getColumnData();
      _getDataGridRow();
    }

    this.getPinnedRowStream!(
        AppNotifiers
            .getInstance()
            .isRowunpinController
            .stream,
            (index, isUnPin) {
          _tableManager.singleRowPinning(index, isUnPin, context);
        });
  }

  //*************** These methods will be added by the client whenever client sends customized rows */
  //**************** If datagrid rows not provided then these methodss will be called with only call available shown to the user */

  List<String> _getColumnData() {
    List<String> colNamesList = [];
    List<String> clIList = [];

    // List<dynamic> columnData = json.decode(Constants.AUDIT_TASK_COLUMN_DATA);
    List<dynamic> columnData = [];
    for (var colData in columnData) {
      colNamesList.add(colData["displayName"]);
      clIList.add(colData["datafield"]);
    }

    this.colIds = List<String>.from(clIList);
    this.colData = List<String>.from(colNamesList);
    this.columnIds = List<String>.from(columnIds);
    this.colData = List<String>.from(colNamesList);

    this.columnData = List<String>.from(colNamesList);
    this.columnIds = List<String>.from(clIList);

    //Add data to tabke manager
    _tableManager.columnNames = List<String>.from(colNamesList);
    _tableManager.columnIds = List<String>.from(clIList);
    _tableManager.staticColumnIds = List<String>.from(clIList);
    _tableManager.staticColumnsData = List<String>.from(colNamesList);

    return List<String>.from(colNamesList);
  }

  List<DataGridRow> _getDataGridRow() {
    Map<String, dynamic> rowData = json.decode(Constants.AUDIT_TASK_DATA);
    List<DataGridRow> gridRows = [];

    List<Map<String, dynamic>> tableRowData = [];

    if (tableRowData.length == 0)
      tableRowData = List<Map<String, dynamic>>.from(rowData["results"]);

    gridRows = List.generate((rowData["results"] as List).length, (rowIndex) {
      return DataGridRow(
          cells: List.generate(this.colIds.length, (colIndex) {
            return DataGridCell(
                columnName: this.colIds[colIndex],
                value: (colIndex == 0)
                    ? InkWell(
                    onTap: () {
                      _onRowClick(colIndex, rowIndex);
                    },
                    child: Column(
                      children: [
                        Container(
                            child: this.selectableCellText
                                ? SelectableText(rowData["results"][rowIndex]
                            [this.colIds[colIndex]]
                                .toString())
                                : Text(rowData["results"][rowIndex]
                            [this.colIds[colIndex]]
                                .toString())),

                      ],
                    ))
                    : TableGridCell(
                  onCellDoubleTap: () {
                    _onDataCellDoubleTap(
                        rowData["results"][rowIndex][this.colIds[colIndex]],
                        "status",
                        rowIndex: rowIndex,
                        colName: this.colIds[colIndex],
                        colIndex: colIndex);
                  },
                  cellMenuOn: cellMenuOn,
                  isSelectable: this.selectableCellText,
                  isEditable: this.cellInlineEditing,
                  rowIndex: rowIndex,
                  colIndex: colIndex,
                  title: rowData["results"][rowIndex][this.colIds[colIndex]]
                      .toString(),
                ));
          }));
    });

    this.rowData = tableRowData;
    this.gridRow = gridRows;

    //Add row data to table manager
    _tableManager.staticRowData = List<Map<String, dynamic>>.from(tableRowData);
    _tableManager.rowData = List<Map<String, dynamic>>.from(tableRowData);

    //Data grid row
    _tableManager.dataGridRow = [];
    List<DataGridRow> rowss = gridRows.map((e) {
      return DataGridRow(
          cells: List.generate(e
              .getCells()
              .length, (index) {
            return DataGridCell(
                value: e.getCells()[index].value,
                columnName: this.columnIds[index]);
          }));
    }).toList();

    _tableManager.dataGridRow = List<DataGridRow>.from(gridRows);

    _tableManager.staticDataGridRow = [];
    _tableManager.staticDataGridRow = List<DataGridRow>.from(rowss);

    return List<DataGridRow>.from(gridRows);
  }

  void _onRowClick(int colIndex, int rowIndex) {
    if (colIndex == 0 && rowIndex == 0) {
      this.onRowPinClick(rowIndex, colIndex);
    }
  }

  void onRowPinClick(int index, int colIndex) {
    bool isUnpin = false;
    isUnpin = TableManager
        .getInstance()
        .pinnedRowInfo
        .firstWhere((element) => element.lastPosition == index, orElse: () {
      return RowPinningInfo();
    })
        .lastPosition !=
        null;
    context
        .riverPodReadStateNotifier(pinnedRowWidgetNotifier.notifier)
        .updateValue(PinnedRowPopupWidget(
      metadata: TableManager
          .getInstance()
          .rowData[index]["metadata"] ?? [],
      prodperties:
      TableManager
          .getInstance()
          .rowData[index]["metadata"] ?? [],
      onRowPinClick: (closeOnly) {
        if (closeOnly) {
          context
              .riverPodReadStateNotifier(pinnedRowWidgetNotifier.notifier)
              .updateValue(null);
        } else {
          TableManager.getInstance()
              .singleRowPinning(index, isUnpin, context);

          context
              .riverPodReadStateNotifier(pinnedRowWidgetNotifier.notifier)
              .updateValue(null);
        }
      },
      isPinned: isUnpin,
      title: TableManager
          .getInstance()
          .columnNames[index],
      subtitle: TableManager
          .getInstance()
          .columnIds[index],
    ));
  }

  void _onDataCellDoubleTap(String data,
      String tableCellStatus, {
        int? colIndex,
        int? rowIndex,
        String? colName,
        String? finalValue = "",
        bool? isEditable,
      }) {
    var metadata = rowData[rowIndex!]["attributes"] == null
        ? null
        : rowData[rowIndex]["attributes"]?[colIndex!]["metadata"];

    if (metadata != null && (metadata?["sources"] != null)) {
      List<dynamic> sourcesData = (metadata["sources"] as List<dynamic>);
      _onCellDoubleTap(sourcesData, metadata["aggregators"], colName ?? "",
          data, tableCellStatus, CellDataType.JSON,
          finalValue: finalValue.toString(), isEditable: isEditable ?? false);
    } else {
      _onCellDoubleTap(
          [], "", colName ?? "", data, tableCellStatus, CellDataType.JSON,
          shouldShowOnlyFinalValue: true,
          finalValue: finalValue.toString(),
          isEditable: isEditable ?? false);
      // showErrorWithMessage("No metadata to show");
    }
  }

  void _onCellDoubleTap(List<dynamic> sourcesData,
      dynamic agggregators,
      String colName,
      String data,
      String tableCellStatus,
      CellDataType dataType, {
        bool shouldShowOnlyFinalValue = false,
        dynamic finalValue,
        required bool isEditable,
      }) {
    showDialog(
        context: this.context,
        builder: (context) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: TableCellDetailWidget(
                rowData: sourcesData,
                finalValue: finalValue,
                aggregators: agggregators ?? [],
                colName: colName,
                cellValue: data,
                cellDataType: dataType,
                cellStatus: "status",
                shouldShowOnlyFinalValue: shouldShowOnlyFinalValue,
                statusOfCell: "tableCellStatus",
                isEditable: isEditable,
              ));
        });
  }
}
