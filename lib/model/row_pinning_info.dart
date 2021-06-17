// To parse this JSON data, do
//
//     final columnPinningInfo = columnPinningInfoFromJson(jsonString);

import 'dart:convert';

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

RowPinningInfo rowPinningInfoFromJson(String str) =>
    RowPinningInfo.fromJson(json.decode(str));

String rowPinningInfoToJson(RowPinningInfo data) => json.encode(data.toJson());

class RowPinningInfo {
  RowPinningInfo({
    this.lastPosition,
    this.currentPosition,
    this.row,
  });

  int? lastPosition;
  int? currentPosition;
  DataGridRow? row;

  factory RowPinningInfo.fromJson(Map<String, dynamic> json) => RowPinningInfo(
        lastPosition: json["last_position"],
        currentPosition: json["current_position"],
        row: json["row"],
      );

  Map<String, dynamic> toJson() => {
        "last_position": lastPosition,
        "current_position": currentPosition,
      };

  RowPinningInfo copyFrom() {
    RowPinningInfo info = RowPinningInfo.fromJson(this.toJson());
    return info;
  }
}
