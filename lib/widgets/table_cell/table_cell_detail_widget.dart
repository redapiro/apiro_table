import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/enum/cell_data_type.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_elevated_button.dart';
import 'package:apiro_table/widgets/table_cell/decorator/json_decorator.dart';
import 'package:apiro_table/widgets/table_cell/decorator/xml_deocrator.dart';
import 'package:apiro_table/widgets/table_cell/drop_down_table_cell.dart';
import 'package:apiro_table/widgets/table_cell/schema_cell_detail_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableCellDetailWidget extends StatelessWidget {
  ThemeData? _themeData;
  BuildContext? context;
  final String finalValue;
  final String colName;
  final String cellValue;
  final String cellStatus;
  final bool isEditable;
  final CellDataType cellDataType;

  final String statusOfCell;
  final bool shouldShowOnlyFinalValue;
  final dynamic aggregators;
  List<dynamic>? rowData = [];
  List<String> columnData = [];

  late Color textColor;
  late Color backgroundColor;

  TableCellDetailWidget(
      {required this.rowData,
      required this.finalValue,
      required this.colName,
      required this.cellValue,
      required this.cellDataType,
      required this.cellStatus,
      required this.isEditable,
      this.shouldShowOnlyFinalValue = false,
      required this.statusOfCell,
      required this.aggregators}) {
    textColor = AppColors.dividerColor;
    backgroundColor = AppColors.scaffoldBackgroundColor;
  }
  double? screenWidth;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);

    this.context = context;
    screenWidth = MediaQuery.of(context).size.width;

    _setUpColumnNameData();

    return Center(
      child: Container(
        width: screenWidth! * 0.75,
        margin: EdgeInsets.all(30),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
                // color: backgroundColor,
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              children: [
                _getPopupStatusBarWidget(),
                _getHorizontalSeparator(),
                _getPopUpBodyWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPopupStatusBarWidget() {
    return Container(
      height: 55,
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0))),
      child: Column(
        children: [
          Row(
            children: [
              _getStatusBarData(),
              IconButton(
                  icon: Icon(Icons.close, size: 25),
                  onPressed: _onPopupClosePress),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getStatusBarData() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text("label_status",
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(fontWeight: FontWeight.bold, color: textColor)),
            Text(cellStatus,
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(color: textColor)),
            SizedBox(width: 15),
            _getVerticalSeparator(),
            SizedBox(width: 15),
            Text("label_data_type",
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(fontWeight: FontWeight.bold, color: textColor)),
            Text(this.cellDataType.getStringFromCellDatType(),
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(color: textColor)),
            SizedBox(width: 15),
            _getVerticalSeparator(),
            SizedBox(width: 15),
            Text("label_column_name",
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(fontWeight: FontWeight.bold, color: textColor)),
            Text(colName,
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(color: textColor)),
            SizedBox(width: 15),
            _getVerticalSeparator(),
            SizedBox(width: 15),
            Text("label_schema",
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(fontWeight: FontWeight.bold, color: textColor)),
            Text("Schema Name",
                style: _themeData!.textTheme.subtitle1!
                    .copyWith(color: textColor)),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _getHorizontalSeparator() {
    return Container(height: 0.5, color: _themeData!.disabledColor);
  }

  Widget _getVerticalSeparator() {
    return Container(width: 0.5, color: _themeData!.disabledColor, height: 50);
  }

  Widget _getPopUpBodyWidget() {
    return Container(
        margin: EdgeInsets.all(15),
        height: MediaQuery.of(this.context!).size.height * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!shouldShowOnlyFinalValue)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: AppColors.disabledColor, width: 0.5),
                              bottom: BorderSide(
                                  color: AppColors.disabledColor, width: 0.5),
                              left: BorderSide(
                                  color: AppColors.disabledColor, width: 0.5)),
                        ),
                        child: SfDataGrid(
                            source: _orderDataGridSource(),

                            // controller: _controller,
                            // frozenColumnsCount: pageManager.frozenColumnCountNotifier.value,
                            // frozenRowsCount: pageManager.frozenRowCountNotifier.value,
                            // onQueryRowHeight: (e) {
                            //   if (e.rowIndex != 0) {
                            //     return e.rowHeight;
                            //   }
                            //   return e.rowHeight;
                            // },
                            defaultColumnWidth: 150,
                            headerGridLinesVisibility: GridLinesVisibility.none,
                            headerRowHeight: 60,
                            columnWidthMode: ColumnWidthMode.fill,
                            rowHeight: 60,
                            gridLinesVisibility: GridLinesVisibility.none,
                            columns: List.generate(columnData.length, (index) {
                              return GridTextColumn(
                                minimumWidth: 150,
                                columnName: columnData[index],
                                label: Container(
                                    color: AppColors.secondaryColor,
                                    alignment: AlignmentDirectional.center,
                                    child: Text(
                                      columnData[index],
                                      textAlign: TextAlign.center,
                                      style: _themeData!.textTheme.subtitle1!,
                                    )),
                              );
                            })),
                      ),
                    ),
                  _getAggregateAndFinalValues(),
                ],
              ),
            ),
            SizedBox(height: 15),
            _getUndoAndRedoButton(),
            SizedBox(height: 15),
            _getSaveButton(),
            SizedBox(height: 15),
          ],
        ));
  }

  Widget _getAggregateAndFinalValues() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: AppColors.disabledColor, width: 0.5),
            left: shouldShowOnlyFinalValue
                ? BorderSide(color: AppColors.disabledColor, width: 0.5)
                : BorderSide(color: Colors.transparent),
            bottom: BorderSide(color: AppColors.disabledColor, width: 0.5),
            right: BorderSide(color: AppColors.disabledColor, width: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!shouldShowOnlyFinalValue)
                Container(
                    width: 160,
                    height: 52,
                    color: AppColors.secondaryColor,
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      "Aggregators",
                      textAlign: TextAlign.center,
                      style: _themeData!.textTheme.subtitle1!,
                    )),
              Container(
                  width: 160,
                  height: 52,
                  color: AppColors.secondaryColor,
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    "Final",
                    textAlign: TextAlign.center,
                    style: _themeData!.textTheme.subtitle1!,
                  ))
            ],
          ),
          SizedBox(
              height: ((60 *
                          (this.rowData!.length == 0
                              ? 1
                              : this.rowData!.length)) /
                      2) -
                  30.0),
          Row(
            children: [
              if (!shouldShowOnlyFinalValue)
                Container(
                    width: 160,
                    height: 52,
                    child: TableCellWithDropDownWidget(
                      data: List<String>.from(this.aggregators.values.toList()),
                      colName: this.colName,
                      cellStatus: "Status",
                      shouldShowGridLines: false,
                    )),
              Container(width: 160, height: 52, child: _getFinalValueChild()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getFinalValueChild() {
    return this.cellDataType == CellDataType.JSON
        ? JSONDecoratorWidget(
            cellStatus: "this.statusOfCell.getTableCellStatusFromString()",
            onCellDoubleTap: () {},
            data: this.rowData.toString(),
            onCellTap: () {},
          )
        : this.cellDataType == CellDataType.XML
            ? XMLDecoratorWidget(
                cellStatus: "this.statusOfCell.getTableCellStatusFromString()",
                onCellDoubleTap: () {},
                data: this.rowData.toString(),
                onCellTap: () {},
              )
            : SchemaCellDetailTableCellWidget(
                data: this.finalValue,
                colName: this.colName,
                cellStatus: "TableCellStatus.BLOCKING",
                shouldShowGridLines: false,
                isEditable: isEditable,
              );
  }

  Widget _getUndoAndRedoButton() {
    return Container(
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Icon(Icons.undo),
              onTap: () {
                print("undo pressed");
              },
            ),
            SizedBox(width: 20),
            InkWell(
              child: Icon(Icons.redo),
              onTap: () {
                print("redo pressed");
              },
            )
          ],
        ));
  }

  Widget _getSaveButton() {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      child: AdaptiveElevatedButton(
        text: "label_save",
        width: 120,
        onPressed: () {
          Navigator.pop(this.context!);
          print("save pressed");
        },
      ),
    );
  }

  UserDataGridSource _orderDataGridSource() {
    return UserDataGridSource(
      userData: rowData,
      columnNames: this.columnData,
      finalValue: this.finalValue,
      aggregators: this.aggregators,
      dataType: this.cellDataType,
      status: "Unknown",
    );
  }

  void _onPopupClosePress() {
    Navigator.of(this.context!).pop();
  }

  void _setUpColumnNameData() {
    if (columnData.length == 0) {
      columnData = [
        "label_name",
        "label_day_count",
        "label_date",
        "label_raw",
        "label_validators",
        "label_auto_cleansers",
        "label_auto_cleansed",
      ];
    }
  }
}

class UserDataGridSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  ///
  ///
  final String finalValue;
  final dynamic aggregators;
  final String status;
  final CellDataType dataType;

  UserDataGridSource(
      {@required List<dynamic>? userData,
      @required List<String>? columnNames,
      required this.finalValue,
      required this.status,
      required this.dataType,
      required this.aggregators}) {
    _userData = List.generate(userData!.length, (rowIndex) {
      Map<String, dynamic> sourceData = userData[rowIndex].toJson();

      return DataGridRow(
          cells: List.generate(columnNames!.length, (index) {
        Widget? valueWidget;
        String columnName = "Simple";
        List<String> sourceKeys = sourceData.keys.toList();
        if (columnNames[index].contains("Cleansed")) {
          valueWidget = this.dataType == CellDataType.JSON
              ? JSONDecoratorWidget(
                  cellStatus: this.status,
                  onCellDoubleTap: () {},
                  data: sourceData[sourceKeys[index]].toString(),
                  onCellTap: () {},
                )
              : XMLDecoratorWidget(
                  cellStatus: this.status,
                  onCellDoubleTap: () {},
                  data: sourceData[sourceKeys[index]].toString(),
                  onCellTap: () {},
                );
        } else if (sourceData[sourceKeys[index]].toString().contains("{")) {
          valueWidget = TableCellWithDropDownWidget(
            data: List<String>.from(
                sourceData[sourceKeys[index]].values.toList()),
            colName: columnName,
            cellStatus: status,
            shouldShowGridLines: false,
          );
        } else {
          valueWidget = SchemaCellDetailTableCellWidget(
            data: sourceData[sourceKeys[index]].toString(),
            colName: columnName,
            cellStatus: status,
            shouldShowGridLines: false,
          );
        }

        return DataGridCell<Widget>(
            columnName: columnNames[index], value: valueWidget);
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
            // padding: EdgeInsets.all(3.0),
            child: e.value,
          );
        }).toList());
  }
}
