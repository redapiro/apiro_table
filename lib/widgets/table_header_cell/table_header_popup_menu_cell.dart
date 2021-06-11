import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_elevated_button.dart';
import 'package:apiro_table/widgets/custom_widgets/custom_drop_down.dart';
import 'package:apiro_table/widgets/table_header_cell/add_filter_widget.dart';
import 'package:apiro_table/widgets/table_header_cell/table_column_filter_icon_widget.dart';
import 'package:flutter/material.dart';

class TableColumnHeaderPopMenuButtonWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tootipName;

  final Map<String, dynamic> metadata;
  final bool isPinned;
  final List<String>? tableFilterList;

  final Function()? onColumnmPinClick;
  final Function()? onColumnmHideClick;
  final Function(int)? onColumnOrderingSet;
  final Function(List<String>)? onColumnmFilterClick;
  final double? popUpButtonHeight;

  TableColumnHeaderPopMenuButtonWidget(
      {required this.metadata,
      this.onColumnmFilterClick,
      this.onColumnmHideClick,
      this.tableFilterList,
      required this.tootipName,
      this.onColumnmPinClick,
      this.onColumnOrderingSet,
      this.isPinned = false,
      this.subtitle = "",
      this.popUpButtonHeight = 50.0,
      this.title = ""}) {
    _tableManager = TableManager.getInstance();

    selectedColumnOrderIndex = ValueNotifier<int>(0);
  }

  ThemeData? _themeData;
  late BuildContext context;
  GlobalKey _key = GlobalKey();
  ValueNotifier<bool> shouldShowFilterUI = ValueNotifier<bool>(false);
  ValueNotifier<bool> isPopUpButtonPressed = ValueNotifier<bool>(false);
  late ValueNotifier<int> selectedColumnOrderIndex;
  double? screenWidth;

  TextEditingController _columnOrderingController = TextEditingController();
  List<String> columnNameList = [];
  late TableManager _tableManager;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    this.context = context;
    this.screenWidth = MediaQuery.of(context).size.width;

    int colNumber = 1;
    if (columnNameList.length == 0) {
      columnNameList = _tableManager.columnNames.map<String>((element) {
        String tempString = "Column Order " + "- " + colNumber.toString();

        colNumber++;
        return tempString;
      }).toList();
      selectedColumnOrderIndex.value =
          _tableManager.columnNames.indexWhere((element) => element == title);
    }

    return Container(
      child: _getPopUpMenuButton(),
    );
  }

  Widget _getPopUpMenuButton() {
    return Container(
        height: 50,
        key: _key,
        color: AppColors.secondaryColor,
        child: ValueListenableBuilder<bool>(
            valueListenable: isPopUpButtonPressed,
            builder: (context, value, child) {
              return ValueListenableBuilder<bool>(
                  valueListenable:
                      AppNotifiers.getInstance().filterListUpdateNotifier,
                  builder: (context, value, child) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // _showPopUpMenu(context, tapDetails.globalPosition);
                        _showPopUpMenu(context);
                        isPopUpButtonPressed.value =
                            !isPopUpButtonPressed.value;
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: this.title,
                                child: Text(this.title,
                                    textAlign: TextAlign.center,
                                    style: _themeData!.textTheme.subtitle2!
                                        .copyWith(
                                            color: isPopUpButtonPressed.value
                                                ? AppColors.appBlueColor
                                                : AppColors.dividerColor)),
                              ),
                            ),
                            SizedBox(width: 3),
                            _getTableColumnFilterIcon(),
                            Icon(Icons.keyboard_arrow_down,
                                size: 15, color: AppColors.disabledColor)
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }

  Widget _getTableColumnFilterIcon() {
    if (TableManager.getInstance().tableColumnFilterList.length > 1 &&
        (TableManager.getInstance().currentFilterColumnId == this.title))
      return TableColumnFilterIconWidget(
        margin: EdgeInsets.only(right: 3),
        text: ((TableManager.getInstance().tableColumnFilterList.length - 1)
            .toString()),
        color: Colors.blueAccent,
      );
    else {
      return Container();
    }
  }

  PopupMenuItem _getPopUpMenuItems(BuildContext context) {
    return PopupMenuItem(
      enabled: false,
      child: ValueListenableBuilder<bool>(
          valueListenable: shouldShowFilterUI,
          builder: (context, value, child) {
            if (value) {
              return Container(
                color: Colors.white,
                child: AddFilterWidget(
                  onApplyFilterClick: _applyFilterCallback,
                  removeFilterUI: _hideFilterUI,
                  columnName: this.title,
                  filterList: this.tableFilterList ?? [],
                ),
              );
            }
            return Container(
              color: Colors.white,
              child: Column(children: [
                _getTitleAndPopUpCloseRow(context),
                SizedBox(height: 5),
                _getSubtitleRow(),
                SizedBox(height: 5),
                _getPinFilterHideRow(),
                SizedBox(height: 5),
                _getHorizontalLine(),
                SizedBox(height: 5),
                _getMetadataWidget()
              ]),
            );
          }),
    );
  }

  Widget _getTitleAndPopUpCloseRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(
          this.title,
          style: _themeData!.textTheme.subtitle1,
        )),
        SizedBox(width: 10),
        InkWell(
          child: Icon(Icons.close),
          onTap: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  Widget _getSubtitleRow() {
    return Container(
        child: Text(this.subtitle,
            style: _themeData!.textTheme.subtitle2!
                .copyWith(color: AppColors.disabledColor)));
  }

  Widget _getPinFilterHideRow() {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _getButtonWithTitle(this.isPinned ? "UnPin" : "Pin",
                Icons.push_pin_outlined, AppColors.dividerColor,
                textColor: Theme.of(context).scaffoldBackgroundColor,
                onClick: _onColumnPinClick),
            SizedBox(width: 10),
            _getButtonWithTitle("Filter", Icons.filter_alt_rounded,
                Theme.of(context).scaffoldBackgroundColor,
                addBorder: true, onClick: _onColumnFilterClick),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            _getButtonWithTitle("Hide", Icons.remove_red_eye_outlined,
                Theme.of(context).scaffoldBackgroundColor,
                onClick: _onColumnHideClick),
            SizedBox(width: 10),
            _getColumnOrderTextField(),
          ],
        ),
        SizedBox(height: 5),
      ],
    ));
  }

  Widget _getColumnOrderTextField() {
    return Container(
      child: CustomDropDownWidget(
          items: columnNameList,
          textColor: AppColors.dividerColor,
          height: 45,
          onChange: (value) {
            _onColumnOrderingSubmit(value.split("-").toList()[1].trim());
          },
          selectedItemIndex: selectedColumnOrderIndex.value),
    );
  }

  Widget _getButtonWithTitle(
      String title, IconData icon, Color? backgroundColor,
      {bool addBorder = false,
      Color textColor = Colors.black,
      Function? onClick}) {
    return Container(
        child: AdaptiveElevatedButton(
            buttonBackgroundColor: backgroundColor,
            width: 80,
            height: 45,
            decoration: addBorder
                ? BoxDecoration(
                    border: Border.all(
                        width: 1, color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(5.0))
                : null,
            onPressed: () {
              onClick!();
            },
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                SizedBox(width: 5),
                Text(
                  title,
                  style: _themeData!.textTheme.subtitle2!
                      .copyWith(color: textColor),
                ),
              ],
            )));
  }

  Widget _getHorizontalLine() {
    return Container(
      height: 0.5,
      color: Theme.of(context).disabledColor,
    );
  }

  Widget _getMetadataWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Meta Data",
            style: _themeData!.textTheme.subtitle1!,
          ),
          Column(
            children: List.generate(this.metadata.length, (index) {
              return Row(
                children: [
                  Text(this.metadata.keys.toList()[index] + ": ",
                      style: _themeData!.textTheme.subtitle2!),
                  Text(this.metadata.values.toList()[index],
                      style: _themeData!.textTheme.subtitle2!),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  ///on Click methods

  void _showPopUpMenu(
    BuildContext context,
  ) {
    RenderBox renderBox = _key.currentContext!.findRenderObject()! as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    double left = position.dx;
    double top = position.dy;
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            left, top + 50, this.screenWidth! - (left + 150), 0),
        items: [
          _getPopUpMenuItems(context),
        ]).then((value) {
      //OnMenuClose
      isPopUpButtonPressed.value = !isPopUpButtonPressed.value;
    });
  }

  void _onColumnOrderingSubmit(String orderPosition) {
    int columnOrderingIndex;
    try {
      columnOrderingIndex = int.parse(orderPosition);

      if (this.onColumnOrderingSet != null) {
        Navigator.pop(context);
        this.onColumnOrderingSet!(columnOrderingIndex);
      }
    } catch (e) {
      _showSnackBarWithMessage("Not a valid int");
    }
    // }
  }

  //Showing snack bar method
  void _showSnackBarWithMessage(String message) {
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(this.context).errorColor,
      ),
    );
  }

  void _resetPopPressValue(context) {
    Navigator.of(context).pop();
    isPopUpButtonPressed.value = !isPopUpButtonPressed.value;
  }

  void _onColumnPinClick() {
    _resetPopPressValue(context);

    this.onColumnmPinClick!();
  }

  void _onColumnHideClick() {
    _resetPopPressValue(context);
    this.onColumnmHideClick!();
  }

  void _onColumnFilterClick() {
    // _resetPopPressValue(context);
    // this.onColumnmFilterClick!();

    shouldShowFilterUI.value = !shouldShowFilterUI.value;
  }

  //Filter callback method
  void _applyFilterCallback(List<String> filterList) {
    this.onColumnmFilterClick!(filterList);
    _resetPopPressValue(context);
    shouldShowFilterUI.value = !shouldShowFilterUI.value;
  }

  void _hideFilterUI() {
    shouldShowFilterUI.value = !shouldShowFilterUI.value;
  }
}
