import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/app_notifiers.dart';
import 'package:apiro_table/utils/common_methods.dart';
import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_outlined_button.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_text_button.dart';
import 'package:flutter/material.dart';

class HiddenColumnDropDown extends StatelessWidget {
  final Widget? leftWidget;
  HiddenColumnDropDown({Key? key, this.leftWidget}) : super(key: key);

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Container(
        child: Column(
      children: [
        Divider(height: 0.3, color: AppColors.disabledColor),
        SizedBox(height: 10),
        Row(
          children: [
            SizedBox(width: 15),
            Expanded(child: (leftWidget == null) ? Container() : leftWidget!),
            _getClearAllButton(),
            _getHiddenColumnDropDown(),
            SizedBox(width: 15),
          ],
        ),
        SizedBox(height: 10),
        Divider(height: 0.3, color: AppColors.disabledColor),
      ],
    ));
  }

  Widget _getClearAllButton() {
    return Container(
        width: 150,
        height: 30,
        child: AdaptiveOutlinedButton(
          buttonColor: AppColors.appBlueColor,
          borderRadius: BorderRadius.circular(40),
          onPressed: () {
            _clearAllFiltersPressed();
          },
          text: "Clear All Filters",
        ));
  }

  Widget _getHiddenColumnDropDown() {
    return ValueListenableBuilder<String?>(
        valueListenable: AppNotifiers.getInstance().hiddenColumnNotifier,
        builder: (context, data, child) {
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (tapDetails) {
                if (TableManager.getInstance().hiddenColumnIds.length > 0) {
                  CommonMethods.showPopUpMenuWithOffset(context,
                      tapDetails.globalPosition, _getPopUpMenuItems(context));
                }
              },
              child: IntrinsicWidth(
                child: Container(
                    height: 35,
                    margin: EdgeInsets.only(left: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: 7,
                    ),
                    alignment: AlignmentDirectional.centerStart,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: AppColors.disabledColor, width: 1)),
                    child: Row(
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "Hidden Columns",
                              style: _themeData.textTheme.subtitle2!
                                  .copyWith(color: AppColors.dividerColor)),
                          TextSpan(
                              text:
                                  " (${TableManager.getInstance().hiddenColumnIds.length})",
                              style: _themeData.textTheme.subtitle2!
                                  .copyWith(color: AppColors.appBlueColor))
                        ])),
                        SizedBox(width: 20),
                        Icon(Icons.keyboard_arrow_down_sharp)
                      ],
                    )),
              ));
        });
  }

  PopupMenuItem _getPopUpMenuItems(BuildContext context) {
    List<String> hiddenColumnNames = TableManager.getInstance()
        .hiddenColumnIds
        .map((e) => e.keys.toList()[0].toString())
        .toList();
    return PopupMenuItem(
      enabled: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Column(
            children: List.generate(
                TableManager.getInstance().hiddenColumnIds.length, (index) {
          return _getDropDownItemWidgetForHiddenColumn(
              hiddenColumnNames[index], context);
        })),
        SizedBox(height: 15),
        _getShowAllOption(context),
        SizedBox(height: 10),
      ]),
    );
  }

  Widget _getDropDownItemWidgetForHiddenColumn(
      String value, BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: _themeData.textTheme.subtitle2!
                    .copyWith(color: AppColors.dividerColor),
              ),
            ),
            SizedBox(width: 15),
            InkWell(
                onTap: () {
                  _onHiddenColumnShowPress(value, context);
                },
                child: Container(
                    child: Text("Show",
                        style: _themeData.textTheme.subtitle2!
                            .copyWith(color: AppColors.appBlueColor)))),
          ],
        ));
  }

  Widget _getShowAllOption(BuildContext context) {
    return InkWell(
      onTap: () {
        _onShowAllPress(context);
      },
      child: Container(
          child: Text("Show All",
              style: _themeData.textTheme.subtitle2!
                  .copyWith(color: AppColors.appBlueColor))),
    );
  }

  void _onShowAllPress(BuildContext context) {
    TableManager.getInstance().showAllColumn();
    Navigator.pop(context);
  }

  void _onHiddenColumnShowPress(String colName, BuildContext context) {
    TableManager.getInstance().showColumn(colName);
    Navigator.pop(context);
  }

  void _clearAllFiltersPressed() {
    TableManager.getInstance().removeAllFilter();
  }
}
