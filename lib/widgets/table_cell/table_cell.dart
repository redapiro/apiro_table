import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/common_methods.dart';
import 'package:apiro_table/utils/constants.dart';
import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/custom_widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class TableGridCell extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final bool isEditable;
  final bool isSelectable;
  final int rowIndex;
  final int colIndex;
  final Function() onCellDoubleTap;

  TableGridCell(
      {Key? key,
      required this.title,
      required this.rowIndex,
      required this.colIndex,
      this.style,
      this.isEditable = true,
      required this.onCellDoubleTap,
      this.isSelectable = false})
      : super(key: key) {
    _cellEditingController = TextEditingController();
    _cellEditingController.text = title;
    _cellFocusNode = FocusNode();
    _cellFocusNode.addListener(() {
      _onCellTextFieldFocusChange();
    });
  }

  ValueNotifier<bool> tableCellNotifier = ValueNotifier<bool>(false);
  late TextEditingController _cellEditingController;
  late FocusNode _cellFocusNode;
  BuildContext? context;
  final _cellKey = GlobalKey();
  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    this.context = context;
    return ValueListenableBuilder<bool>(
        valueListenable: tableCellNotifier,
        builder: (context, data, child) {
          if (data) {
            return _getEditableCellViewWidget();
          }
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (isEditable) _onDataCellTap();
              },
              onDoubleTap: () {
                _onDataCellDoubleTap();
              },
              onSecondaryTap: () {
                _onCellRightClick();
              },
              child: Container(
                  height: 60,
                  width: 150,
                  key: _cellKey,
                  // color: cellStatus.getBackgroundColorForTableCellStatus(),
                  alignment: AlignmentDirectional.center,
                  child: this.isSelectable
                      ? (SelectableText(
                          this.title,
                          textAlign: TextAlign.center,
                        )
                          // style: _themeData.textTheme.subtitle2!.copyWith(
                          //     color: this
                          //         .cellStatus
                          //         .getTextColorFromTableCellStatus()))
                          )
                      : (Text(this.title,
                          textAlign: TextAlign.center,
                          style: _themeData.textTheme.subtitle2!.copyWith(
                              // color: this
                              //     .cellStatus
                              //     .getTextColorFromTableCellStatus()
                              )))));
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

  void _onCellEditingSubmit() {
    _cellFocusNode.unfocus();

    if (_cellEditingController.text.trim() != this.title) {
      TableManager.getInstance().updateCellValue(rowIndex, colIndex,
          _cellEditingController.text.trim(), onCellDoubleTap);
    }
  }

  void _onCellTextFieldFocusChange() {
    if (!_cellFocusNode.hasFocus) {
      _onCellEditingSubmit();
      _cellFocusNode.unfocus();
      tableCellNotifier.value = false;
    }
  }

  void _onDataCellDoubleTap() {
    this.onCellDoubleTap();
  }

  void _onCellRightClick() {
    CommonMethods.showPopUpMenu(
        this.context!, _cellKey, _getPopUpMenuItems(context!));
  }

  PopupMenuItem _getPopUpMenuItems(BuildContext context) {
    return PopupMenuItem(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              List.generate(Constants.cellPopupMenuOptions.length, (index) {
            return InkWell(
                onTap: () {
                  _onRightClockPopupOptionTap(index);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Row(
                    children: [
                      Text(
                        Constants.cellPopupMenuOptions[index],
                        style: _themeData.textTheme.subtitle1!
                            .copyWith(color: AppColors.dividerColor),
                      ),
                    ],
                  ),
                ));
          }),
        ));
  }

  void _onRightClockPopupOptionTap(int index) {
    Navigator.pop(context!);
    print("clicked on -- ${Constants.cellPopupMenuOptions[index]}");
  }
}
