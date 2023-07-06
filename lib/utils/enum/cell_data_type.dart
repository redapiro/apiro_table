enum CellDataType {
  INT,
  DOUBLE,
  STRING,
  JSON,
  XML,
  NOT_IMPLEMENTED,
}

extension CellDataTypeExtension on CellDataType {
  String getStringFromCellDatType() {
    switch (this) {
      case CellDataType.INT:
        return "int";
      case CellDataType.STRING:
        return "String";
      case CellDataType.DOUBLE:
        return "Double";
      case CellDataType.JSON:
        return "JSON";
      case CellDataType.XML:
        return "XML";

      default:
        return "NOT IMPLEMENTED";
    }
  }
}

extension StringExtension on String {
  CellDataType getCellDataTypeFromString() {
    switch (this) {
      case "String":
        return CellDataType.STRING;
      case "Double":
        return CellDataType.DOUBLE;
      // case "violated":
      //   return CellDataType.Violated;
      case "Int":
        return CellDataType.INT;
      case "JSON":
        return CellDataType.JSON;
      case "XML":
        return CellDataType.XML;

      default:
        return CellDataType.NOT_IMPLEMENTED;
    }
  }
}
