// ignore_for_file: must_be_immutable

import 'package:apiro_table/model/column_pinning_info.dart';
import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/common_methods.dart';
import 'package:apiro_table/utils/controller/global_controllers.dart';
import 'package:apiro_table/utils/provider_helper.dart';
import 'package:apiro_table/utils/table_manager/table_manager.dart';
import 'package:apiro_table/widgets/custom_selectable_text.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_elevated_button.dart';
import 'package:apiro_table/widgets/custom_widgets/custom_drop_down.dart';
import 'package:apiro_table/widgets/custom_widgets/custom_pop_up_menu_item.dart';
import 'package:apiro_table/widgets/map_popup.dart';
import 'package:apiro_table/widgets/table_header_cell/add_filter_widget.dart';
import 'package:apiro_table/widgets/table_header_cell/table_column_filter_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TableColumnHeaderPopMenuButtonWidget extends StatelessWidget {
  final String title;
  final String id;

  final String subtitle;
  final String toolTipName;

  late Map<String, dynamic> metaData;
  final bool isPinned;
  final List<String>? tableFilterList;

  final bool isFilterOn;
  final bool selectableText;
  final bool isColumnOrderingOn;
  final bool isColumnHidingOn;

  final Function()? onColumnPinClick;
  final Function()? onColumnHideClick;
  final Function()? clearAllCallback;
  final Function(String, Function(bool), Function(Map<String, dynamic>))?
      onColumnClick;
  final Function(int)? onColumnOrderingSet;
  final Function(List<String>)? onColumnFilterClick;
  final double? popUpButtonHeight;
  int columnIndex;
  bool shouldShowSortWidget = false;
  final Key? filtersPopUpKey;
  final Key? columnOrderKey;
  final Key? columnPinKey;
  final Key? hideKey;
  final List<ColumnPinningInfo>? pinnedColumnInfo;

  Widget? tableSortWidget;

  TableColumnHeaderPopMenuButtonWidget(
      {required this.metaData,
      required this.columnIndex,
      this.pinnedColumnInfo,
      this.onColumnFilterClick,
      this.onColumnHideClick,
      this.clearAllCallback,
      this.tableFilterList,
      this.isFilterOn = true,
      this.isColumnHidingOn = true,
      this.isColumnOrderingOn = true,
      this.selectableText = false,
      required this.toolTipName,
      required this.id,
      this.onColumnPinClick,
      this.onColumnOrderingSet,
      this.onColumnClick,
      this.tableSortWidget,
      this.isPinned = false,
      this.subtitle = "",
      this.popUpButtonHeight = 50.0,
      this.title = "",
      this.filtersPopUpKey,
      this.columnOrderKey,
      this.columnPinKey,
      this.hideKey}) {
    _tableManager = TableManager.getInstance();

    selectedColumnOrderIndex = ValueNotifier<int>(0);
    selectedPinnedColumnOrderIndex = ValueNotifier<int>(0);
  }

  ThemeData? _themeData;



  final isPopUpButtonPressed =
  StateNotifierProvider<IsPopUpButtonPressed, bool>((ref) {
    return IsPopUpButtonPressed();
  });
  final shouldShowFilterUI =
  StateNotifierProvider<ShouldShowFilterUI, bool>((ref) {
    return ShouldShowFilterUI();
  });
  late ValueNotifier<int> selectedColumnOrderIndex;
  late ValueNotifier<int> selectedPinnedColumnOrderIndex;
  double? screenWidth;
  List<String> columnNameList = [];
  List<String> pinnedColumnNameList = [];
  late TableManager _tableManager;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);

    this.screenWidth = MediaQuery.of(context).size.width;

    int colNumber = 1;
    if (columnNameList.length == 0) {
      columnNameList = _tableManager.columnIds.map<String>((element) {
        String tempString = "Column Order " + "- " + (colNumber).toString();

        colNumber++;
        return tempString;
      }).toList();
      selectedColumnOrderIndex.value = _tableManager.columnNames
              .indexWhere((element) => element == toolTipName) -
          _tableManager.pinnedColumnInfo.length;
      selectedPinnedColumnOrderIndex.value = _tableManager.columnNames
          .indexWhere((element) => element == toolTipName);
    }
    int pinnedColNumber = 1;
    if (pinnedColumnNameList.length == 0) {
      pinnedColumnNameList =
          _tableManager.pinnedColumnInfo.map<String>((element) {
        String tempString =
            "Column Order " + "- " + (pinnedColNumber).toString();

        pinnedColNumber++;
        return tempString;
      }).toList();
    }

    return Container(
      child: _getPopUpMenuButton(),
    );
  }

  Widget _getPopUpMenuButton() {
    return Container(
        height: 50,

        color: AppColors.secondaryColor,
        child: Consumer(builder: (context, value, child) {
          return GestureDetector(
            key: filtersPopUpKey,
            behavior: HitTestBehavior.opaque,
            onTap: () {

              // _showPopUpMenu(context, tapDetails.globalPosition);
              if (this.onColumnClick != null) {
                this.onColumnClick!(this.id, (shouldShowSortWidget) {
                  this.shouldShowSortWidget = shouldShowSortWidget;
                }, (metadata) {
                  this.metaData = metadata;
                });
              }
              if (context.mounted) {
                _showPopUpMenu(context, value);
              }
              value.read(isPopUpButtonPressed.notifier).toggleValue();
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Tooltip(
                        message: this.toolTipName,
                        child: CustomSelectableText(this.title,
                            textAlign: TextAlign.center,
                            style: _themeData!.textTheme.titleSmall!.copyWith(
                                color: value.watch(isPopUpButtonPressed)
                                    ? AppColors.appBlueColor
                                    : AppColors.dividerColor),
                            isSelectableText: selectableText)),
                  ),
                  SizedBox(width: 3),
                  _getTableColumnFilterIcon(),
                  Icon(Icons.keyboard_arrow_down,
                      size: 15, color: AppColors.disabledColor)
                ],
              ),
            ),
          );
        }));
  }

  Widget _getTableColumnFilterIcon() {
    if (TableManager.getInstance().tableColumnFilterList.length > 1 &&
        (TableManager.getInstance().currentFilterColumnId == this.id))
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

  CustomPopUpMenuItem _getPopUpMenuItems(BuildContext context) {
    return CustomPopUpMenuItem(
        child: Container(
      color: Colors.white,
      child: Consumer(builder: (context, value, child) {
        if (value.watch(shouldShowFilterUI)) {
          return Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: AddFilterWidget(
              onApplyFilterClick: _applyFilterCallback,
              removeFilterUI: _hideFilterUI,
              columnName: this.title,
              clearAllCallback: this.clearAllCallback ?? () {},
              filterList: this.tableFilterList ?? [],
            ),
          );
        }
        return Container(
          padding: EdgeInsets.only(left: 5, right: 5),
          color: Colors.white,
          child: Column(children: [
            _getTitleAndPopUpCloseRow(context),
            SizedBox(height: 5),
            _getSubtitleRow(),
            SizedBox(height: 5),
            _getPinFilterHideRow(context),
            SizedBox(height: 5),
            _getHorizontalLine(context),
            SizedBox(height: 5),
            _getMetadataWidget(context)
          ]),
        );
      }),
    ));
    // return PopupMenuItem(
    //   enabled: false,
    //   child: ValueListenableBuilder<bool>(
    //       valueListenable: shouldShowFilterUI,
    //       builder: (context, value, child) {
    //         if (value) {
    //           return Container(
    //             color: Colors.white,
    //             child: AddFilterWidget(
    //               onApplyFilterClick: _applyFilterCallback,
    //               removeFilterUI: _hideFilterUI,
    //               columnName: this.title,
    //               filterList: this.tableFilterList ?? [],
    //             ),
    //           );
    //         }
    //         return Container(
    //           color: Colors.white,
    //           child: Column(children: [
    //             _getTitleAndPopUpCloseRow(context),
    //             SizedBox(height: 5),
    //             _getSubtitleRow(),
    //             SizedBox(height: 5),
    //             _getPinFilterHideRow(),
    //             SizedBox(height: 5),
    //             _getHorizontalLine(),
    //             SizedBox(height: 5),
    //             _getMetadataWidget()
    //           ]),
    //         );
    //       }),
    // );
  }

  Widget _getTitleAndPopUpCloseRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(
          this.title,
          style: _themeData!.textTheme.titleMedium,
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
            style: _themeData!.textTheme.titleSmall!
                .copyWith(color: AppColors.disabledColor)));
  }

  Widget _getPinFilterHideRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _getButtonWithTitle(this.isPinned ? "UnPin" : "Pin",
                Icons.push_pin_outlined, AppColors.dividerColor,context,
                textColor: Theme.of(context).scaffoldBackgroundColor,
                onClick: _onColumnPinClick,
                columnKey: columnPinKey),
            SizedBox(width: 5),
            if (this.isFilterOn)
              _getButtonWithTitle("Filter", Icons.filter_alt_rounded,
                  Theme.of(context).scaffoldBackgroundColor,context,
                  addBorder: true, onClick: _onColumnFilterClick),
            SizedBox(width: 5),
            if (this.shouldShowSortWidget) this.tableSortWidget ?? Container()
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            if (this.isColumnHidingOn)
              _getButtonWithTitle("Hide", Icons.remove_red_eye_outlined,
                  Theme.of(context).scaffoldBackgroundColor,context,
                  onClick: _onColumnHideClick, columnKey: hideKey),
            SizedBox(width: 5),
            if (this.isColumnOrderingOn) _getColumnOrderTextField(context),
          ],
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget _getColumnOrderTextField(BuildContext context) {
    return Container(
      key: columnOrderKey,
      child: CustomDropDownWidget(
          items: isPinned ? pinnedColumnNameList : columnNameList,
          textColor: AppColors.dividerColor,
          height: 45,
          onChange: (value) {
            _onColumnOrderingSubmit(value.split("-").toList()[1].trim(),context);
          },
          selectedItemIndex: isPinned
              ? selectedPinnedColumnOrderIndex.value
              : selectedColumnOrderIndex.value),
    );
  }

  Widget _getButtonWithTitle(
      String title, IconData icon, Color? backgroundColor,BuildContext context,
      {bool addBorder = false,
      Color textColor = Colors.black,
      Function? onClick,
      Key? columnKey}) {
    return Container(
        child: AdaptiveElevatedButton(
            key: columnKey,
            buttonBackgroundColor: backgroundColor,
            width: 96,
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
                  style: _themeData!.textTheme.titleSmall!
                      .copyWith(color: textColor),
                ),
              ],
            )));
  }

  Widget _getHorizontalLine(BuildContext context) {
    return Container(
      height: 0.5,
      color: Theme.of(context).disabledColor,
    );
  }

  Widget _getMetadataWidget(BuildContext context) {
    return Material( // Wrap with Material widget for button-like behavior
      color: Colors.transparent, // Set the background color to transparent
      borderRadius: BorderRadius.circular(8), // Apply rounded corners
      clipBehavior: Clip.antiAlias, // Clip content to rounded corners
      child: InkWell( // Use InkWell for the ripple effect
        onTap: () {
          if (metaData.isNotEmpty) {
            _showMapPopup(context, metaData,title);
          }

        },
        child: Container(
          padding: EdgeInsets.all(16), // Add some padding for button-like appearance
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black), // Add a border to resemble a button
            borderRadius: BorderRadius.circular(8), // Apply rounded corners to the border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metaData.isNotEmpty ?"Meta Data":"No Meta Data",
                style: _themeData!.textTheme.titleMedium!,
              ),
              // Add the commented code here if needed
              // Column(
              //   children: List.generate(this.metaData.length, (index) {
              //     return Row(
              //       children: [
              //         Text(this.metaData.entries.toList()[index].key + ": ",
              //             style: _themeData!.textTheme.titleSmall!),
              //         Column(
              //           children: [
              //             for (int i = 0; i < metaData.entries.toList()[index].value.length; i++)
              //               Text(metaData.entries.toList()[index].value[i],
              //                   style: _themeData!.textTheme.titleSmall!),
              //           ],
              //         )
              //       ],
              //     );
              //   }),
              // )
            ],
          ),
        ),
      ),
    );
  }


  ///on Click methods

  void _showPopUpMenu(BuildContext context, WidgetRef ref) {
    RenderBox renderBox =context.findRenderObject()! as RenderBox;
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
      ref.read(isPopUpButtonPressed.notifier).toggleValue();
    });
  }

  void _onColumnOrderingSubmit(String orderPosition,BuildContext context) {
    int columnOrderingIndex;
    try {
      columnOrderingIndex = isPinned
          ? int.parse(orderPosition)
          : int.parse(orderPosition) + _tableManager.pinnedColumnInfo.length;

      if (this.onColumnOrderingSet != null) {
        Navigator.pop(context);
        this.onColumnOrderingSet!(columnOrderingIndex);
      }
    } catch (e) {
      _showSnackBarWithMessage("Not a valid int",context);
    }
    // }
  }

  //Showing snack bar method
  void _showSnackBarWithMessage(String message,BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _resetPopPressValue(BuildContext context) {
    Navigator.of(context).pop();
    context
        .riverPodReadStateNotifier(isPopUpButtonPressed.notifier)
        .toggleValue();
  }

  void _onColumnPinClick(BuildContext context) {
    _resetPopPressValue(context);

    this.onColumnPinClick!();
  }

  void _onColumnHideClick(BuildContext context) {
    _resetPopPressValue(context);
    this.onColumnHideClick!();
  }

  void _onColumnFilterClick(BuildContext context) {
    context
        .riverPodReadStateNotifier(shouldShowFilterUI.notifier)
        .toggleValue();
  }

  //Filter callback method
  void _applyFilterCallback(List<String> filterList,BuildContext context) {
    this.onColumnFilterClick!(filterList);
    _resetPopPressValue(context);
    context
        .riverPodReadStateNotifier(shouldShowFilterUI.notifier)
        .toggleValue();
  }

  void _hideFilterUI(BuildContext context) {
    context
        .riverPodReadStateNotifier(shouldShowFilterUI.notifier)
        .toggleValue();
  }

  void _showMapPopup(BuildContext context,Map<String, dynamic> data,String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapPopup(data: data,title: title);
      },
    );
  }
}
