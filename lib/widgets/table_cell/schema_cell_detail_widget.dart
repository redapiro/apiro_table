import 'package:apiro_table/widgets/custom_widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SchemaCellDetailTableCellWidget extends StatelessWidget {
  final String data;
  final String? colName;
  final String cellStatus;
  final Border? border;
  final bool shouldShowGridLines;
  final bool isEditable;

  ValueNotifier<bool> tableCellNotifier = ValueNotifier<bool>(false);
  late TextEditingController _cellEditingController;
  late FocusNode _cellFocusNode;

  SchemaCellDetailTableCellWidget(
      {required this.data,
      this.colName,
      this.border,
      required this.cellStatus,
      this.isEditable = false,
      this.shouldShowGridLines = true}) {
    if (isEditable) {
      _cellEditingController = TextEditingController();
      _cellEditingController.text = data;
      _cellFocusNode = FocusNode();
      _cellFocusNode.addListener(() {
        _onCellTextFieldFocusChange();
      });
    }
  }

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return ValueListenableBuilder<bool>(
        valueListenable: tableCellNotifier,
        builder: (context, data, child) {
          if (data && isEditable) {
            return _getEditableCellViewWidget();
          }
          return GestureDetector(
            onTap: () {
              if (isEditable) _onDataCellTap();
            },
            child: Container(
                height: 60,
                width: 150,
                decoration: BoxDecoration(
                    border: shouldShowGridLines
                        ? Border.all(
                            color: _themeData.disabledColor,
                            width: 0.5,
                          )
                        : border),
                alignment: AlignmentDirectional.center,
                child: Text(this.data,
                    textAlign: TextAlign.center,
                    style: _themeData.textTheme.subtitle2!)),
          );
        });
  }

  Widget _getEditableCellViewWidget() {
    return Container(
        child: AppTextField(
      focusNode: _cellFocusNode,
      textFieldWidth: 140,
      autoFocus: true,
      controller: _cellEditingController,
      backgroundColor: Colors.transparent,
      onEditingComplete: _onCellEditingSubmit,
    ));
  }

  void _onDataCellTap() {
    this.tableCellNotifier.value = true;
    _cellFocusNode.requestFocus();
  }

  void _onCellTextFieldFocusChange() {
    if (!_cellFocusNode.hasFocus) {
      _onCellEditingSubmit();
      _cellFocusNode.unfocus();
      tableCellNotifier.value = false;
    }
  }

  void _onCellEditingSubmit() {
    if (_cellFocusNode.hasFocus) {
      _cellFocusNode.unfocus();
    }
    if (_cellEditingController.text.trim() != this.data) {
      print(
          " old value ${this.data} and new value -- ${_cellEditingController.text.trim()}");
    }
  }
}
