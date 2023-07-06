import 'package:apiro_table/utils/app_colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomDropDownWidget extends StatelessWidget {
  final List<String> items;
  final Function(String) onChange;
  int selectedItemIndex;
  final double height;
  final double width;
  final bool shouldShowBorder;
  final Color? textColor;
  final EdgeInsets? dropDownMargin;
  final Widget Function(String)? childWidget;
  final bool withSelectionNotifier;

  CustomDropDownWidget(
      {required this.items,
      required this.onChange,
      required this.selectedItemIndex,
      this.childWidget,
      this.textColor,
      this.withSelectionNotifier = false,
      this.height = 30,
      this.shouldShowBorder = true,
      this.dropDownMargin,
      this.width = 150});

  late ThemeData _themeData;
  ValueNotifier<int> selectionNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    Widget dropDown = Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            border: shouldShowBorder
                ? Border.all(color: _themeData.disabledColor)
                : null,
            borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.only(left: 10, right: 5),
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isExpanded: true,

            style: _themeData.textTheme.bodyLarge!
                .copyWith(color: textColor ?? AppColors.dividerColor),
            underline: Container(),
            // itemHeight: kMinInteractiveDimension,

            icon: Icon(Icons.keyboard_arrow_down),
            value: items.length > 0 ? items[selectedItemIndex] : "",
            items: items.map<DropdownMenuItem<String>>(
              (value) {
                return DropdownMenuItem<String>(
                  child: childWidget != null
                      ? childWidget!(value)
                      : Container(
                          child: Text(
                          value,
                          style: _themeData.textTheme.bodyLarge!.copyWith(
                              color: textColor ?? AppColors.dividerColor),
                        )),
                  value: value,
                );
              },
            ).toList(),
            onChanged: (value) {
              if (this.withSelectionNotifier) {
                this.selectedItemIndex = this.items.indexOf(value ?? "");
                this.selectionNotifier.value = this.selectedItemIndex;
              }

              onChange(value!);
            },
          ),
        ));

    if (this.withSelectionNotifier) {
      return ValueListenableBuilder(
          valueListenable: this.selectionNotifier,
          builder: (context, value, child) {
            return dropDown;
          });
    }
    return dropDown;
  }
}
