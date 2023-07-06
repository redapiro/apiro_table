// To parse this JSON data, do
//
//     final columnPinningInfo = columnPinningInfoFromJson(jsonString);

import 'dart:convert';

ColumnPinningInfo columnPinningInfoFromJson(String str) =>
    ColumnPinningInfo.fromJson(json.decode(str));

String columnPinningInfoToJson(ColumnPinningInfo data) =>
    json.encode(data.toJson());

class ColumnPinningInfo {
  ColumnPinningInfo({
    this.columnId,
    this.columnName,
    this.lastPosition,
    this.currentPosition,
  });

  String? columnId;
  String? columnName;
  int? lastPosition;
  int? currentPosition;

  factory ColumnPinningInfo.fromJson(Map<String, dynamic> json) =>
      ColumnPinningInfo(
        columnId: json["column_id"],
        columnName: json["column_name"],
        lastPosition: json["last_position"],
        currentPosition: json["current_position"],
      );

  Map<String, dynamic> toJson() => {
        "column_id": columnId,
        "column_name": columnName,
        "last_position": lastPosition,
        "current_position": currentPosition,
      };
  ColumnPinningInfo copyFrom() {
    ColumnPinningInfo colInfo = ColumnPinningInfo.fromJson(this.toJson());
    return colInfo;
  }
}
