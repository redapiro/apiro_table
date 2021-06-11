import 'package:apiro_table/utils/table_manager.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_elevated_button.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_text_button.dart';
import 'package:apiro_table/widgets/custom_widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class AddFilterWidget extends StatefulWidget {
  final Function(List<String>)? onApplyFilterClick;
  final Function()? removeFilterUI;
  final String columnName;
  final List<String> filterList;
  AddFilterWidget(
      {required this.columnName,
      this.onApplyFilterClick,
      this.removeFilterUI,
      this.filterList = const []});
  @override
  _AddFilterWidget createState() => _AddFilterWidget();
}

class _AddFilterWidget extends State<AddFilterWidget> {
  TextEditingController _addFilterTextController = TextEditingController();
  ThemeData? _themeData;

  ValueNotifier<bool> filterListViewNotifier = ValueNotifier<bool>(false);
  List<String>? filterList;
  bool shouldShowAddFilterTextField = true;

  @override
  void initState() {
    super.initState();
    if (widget.filterList.length > 0 &&
        widget.filterList[0] != widget.columnName) {
      this.filterList = [];
      // TableManager.getInstance().removeAllFilters(shouldRefreshWidgets: false);
    } else {
      this.filterList = widget.filterList;
    }

    if (!this.filterList!.contains(widget.columnName))
      this.filterList!.insert(0, widget.columnName);
    if (this.filterList!.length > 1) {
      this.shouldShowAddFilterTextField = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);

    return Container(
        child: Column(
      children: [
        _getTitleAndPopUpCloseRow(context),
        _getAddFilterWidget(),
      ],
    ));
  }

  Widget _getAddFilterWidget() {
    return ValueListenableBuilder<bool>(
        valueListenable: this.filterListViewNotifier,
        builder: (context, value, child) {
          return Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                SizedBox(height: 10),
                _getAvailableFilterCriteriaList(),
                SizedBox(height: 10),
                if (shouldShowAddFilterTextField) _getFilterTextField(),
                if (this.filterList!.length > 1) _addNewCriteria(),
                SizedBox(height: 10),
                _getApplyAndClearAllRow(),
              ]));
        });
  }

  Widget _getFilterTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: "",
          textFieldHeight: 40,
          controller: _addFilterTextController,
          backgroundColor: Colors.transparent,
          validator: (text) {},
          onSaved: (value) {},
        ),
        SizedBox(height: 10),
        AdaptiveElevatedButton(
          height: 40,
          width: 80,
          child: Text(
            "Add",
            style: _themeData!.textTheme.subtitle2!
                .copyWith(color: _themeData!.scaffoldBackgroundColor),
          ),
          buttonBackgroundColor: Colors.black,
          onPressed: _onAddFilterPress,
        )
      ],
    );
  }

  Widget _getTitleAndPopUpCloseRow(BuildContext context,
      {String? title, Function? onDeleteClick}) {
    return Row(
      children: [
        Expanded(
            child: Text(
          title ?? "",
          style: _themeData!.textTheme.subtitle1,
        )),
        SizedBox(width: 10),
        InkWell(
          child: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onTap: () {
            if (onDeleteClick != null) {
              onDeleteClick();
            } else {
              widget.removeFilterUI!();
            }
          },
        )
      ],
    );
  }

  Widget _getFilterNameWidget(int index) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: _themeData!.disabledColor, width: 0.5)),
        child: _getTitleAndPopUpCloseRow(this.context,
            title: filterList![index], onDeleteClick: () {
          _onDeleteFilterClick(index);
        }));
  }

  Widget _getAvailableFilterCriteriaList() {
    return Container(
      child: Column(
        children: List.generate(
          this.filterList!.length - 1,
          (index) {
            return _getFilterNameWidget(index + 1);
          },
        ),
      ),
    );
  }

  Widget _getApplyAndClearAllRow() {
    return Container(
        child: Row(
      children: [
        AdaptiveElevatedButton(
          child: Text(
            "Apply",
            style: _themeData!.textTheme.subtitle2!
                .copyWith(color: _themeData!.scaffoldBackgroundColor),
          ),
          height: 40,
          width: 80,
          buttonBackgroundColor: Colors.black,
          onPressed: _onApplyClick,
        ),
        SizedBox(width: 5),
        AdaptiveTextButton(
          width: 80,
          child: Text(
            "Clear All",
            style: _themeData!.textTheme.subtitle2,
          ),
          onPressed: _onClearAllClick,
        )
      ],
    ));
  }

  Widget _addNewCriteria() {
    return InkWell(
      onTap: _onAddNewCriteriaClick,
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(
          "Add new criteria",
          style: _themeData!.textTheme.subtitle2,
        ),
      ),
    );
  }

  //OnClick methods
  void _onAddFilterPress() {
    List<String> tempList = this.filterList!;
    if (!tempList.contains(_addFilterTextController.text.trim())) {
      tempList.add(_addFilterTextController.text.trim());

      this.filterList = tempList;
      _addFilterTextController.text = "";
      this.shouldShowAddFilterTextField = false;

      //Refresh the UI
      this.filterListViewNotifier.value = !this.filterListViewNotifier.value;
    } else {
      _showSnackBarWithMessage("Filter already exists");
    }
  }

  void _onDeleteFilterClick(int index) {
    List<String> tempList = this.filterList!;
    tempList.removeAt(index);

    this.filterList = tempList;
    _addFilterTextController.text = "";

    //Refresh the UI
    this.filterListViewNotifier.value = !this.filterListViewNotifier.value;
  }

  void _onAddNewCriteriaClick() {
    this.shouldShowAddFilterTextField = true;

    //Refresh the UI
    this.filterListViewNotifier.value = !this.filterListViewNotifier.value;
  }

  void _onClearAllClick() {
    this.filterList = [];
    this.filterList!.add(widget.columnName);
    this.shouldShowAddFilterTextField = true;

    //Refresh the UI
    this.filterListViewNotifier.value = !this.filterListViewNotifier.value;
    Navigator.pop(context);
    TableManager.getInstance().removeAllFilter();
  }

  void _onApplyClick() {
    widget.onApplyFilterClick!(this.filterList!);
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
}
