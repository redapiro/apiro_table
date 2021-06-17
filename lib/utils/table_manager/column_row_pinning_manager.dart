import 'package:apiro_table/utils/app_notifiers.dart';

class PinRowColumn {
  void pinRowWithRowAndColumnId() {}
  void pinColumnWithRowAndColumnId() {}

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

}
