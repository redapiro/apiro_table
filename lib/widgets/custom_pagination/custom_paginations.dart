import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/widgets/custom_widgets/app_text_field.dart';
import 'package:apiro_table/widgets/custom_widgets/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class CustomPaginationWidget extends StatelessWidget {
  final Function() onPreviousClick;
  final Function() onNextClick;
  final Function() onItemsPerPageChange;
  final Function(int) onPageNumberClick;
  final Function(int) onPageNumberSelect;
  final Function(String) onTextFieldSubmit;
  final List<String> pageNumbers;
  final int totalNumberOfPages;
  final ValueNotifier paginationPageNumberNotifier;
  final ValueNotifier perPageRowCountNotifier;

  CustomPaginationWidget({
    Key? key,
    required this.onPreviousClick,
    required this.onNextClick,
    required this.onItemsPerPageChange,
    required this.onPageNumberClick,
    required this.onPageNumberSelect,
    required this.pageNumbers,
    required this.totalNumberOfPages,
    required this.onTextFieldSubmit,
    required this.jumpToPageNumberController,
    required this.paginationPageNumberNotifier,
    required this.jumpToPageTextFieldFocusNode,
    required this.perPageRowCountNotifier,
  }) : super(key: key) {
    jumpToPageNumberController.text =
        paginationPageNumberNotifier.value.toString();
    rowCountPerPageList = this.pageNumbers;
  }

  BuildContext? context;
  ThemeData? _themeData;

  List<String> rowCountPerPageList = [];
  final FocusNode jumpToPageTextFieldFocusNode;
  final TextEditingController jumpToPageNumberController;
  ValueNotifier<bool> refreshPagination = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    _themeData = Theme.of(context);

    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: this.paginationPageNumberNotifier,
          builder: (context, value, child) {
            return Container(
                height: 50,
                child: Column(
                  children: [
                    Container(
                        height: 0.5,
                        color: _themeData!.disabledColor,
                        width: double.maxFinite),
                    Expanded(child: Container()),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        width: double.maxFinite,
                        child: Row(children: [
                          Expanded(
                            child: Container(
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    Row(
                                        children: List.generate(
                                            this.totalNumberOfPages, (index) {
                                      return _getPaginationPagesWidget(index);
                                    })),
                                    _getJumpToPageNumberWidget(),
                                    Container(child: _getPageNumberDropDown()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ])),
                    Expanded(child: Container()),
                    Container(
                        height: 0.5,
                        color: _themeData!.disabledColor,
                        width: double.maxFinite),
                  ],
                ));
          }),
    );
  }

  Widget _getPageNumberDropDown() {
    return ValueListenableBuilder(
        valueListenable: this.perPageRowCountNotifier,
        builder: (context, value, child) {
          return Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                CustomDropDownWidget(
                    width: 100,
                    height: 30,
                    items: rowCountPerPageList,
                    onChange: (value) {
                      this.perPageRowCountNotifier.value = value;
                      onItemsPerPageChange();
                    },
                    selectedItemIndex: rowCountPerPageList
                        .indexOf(this.perPageRowCountNotifier.value)),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text("item per page"))
              ],
            ),
          );
        });
  }

  Widget _getJumpToPageNumberWidget() {
    return Container(
        child: Row(
      children: [
        Text("Page"),
        Container(
          height: 40,
          margin: EdgeInsets.only(left: 10, right: 10),
          child: AppTextField(
            focusNode: jumpToPageTextFieldFocusNode,
            textFieldWidth: 90,
            textInputType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: jumpToPageNumberController,
            backgroundColor: Colors.transparent,
            onEditingComplete: _ontextFieldSubmit,
          ),
        )
      ],
    ));
  }

  Widget _getPaginationPagesWidget(int index) {
    Color pageNumberBckColor =
        ((this.paginationPageNumberNotifier.value - 1) == index)
            ? AppColors.appBlueColor
            : Colors.transparent;
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(children: [
        if (index == 0)
          Row(
            children: [
              Text("Page",
                  style: _themeData!.textTheme.bodyText1!
                      .copyWith(color: AppColors.disabledColor)),
              _getPagingContainerWith("<",
                  clickable: this.paginationPageNumberNotifier.value > 1,
                  onPress: this.onPreviousClick),
            ],
          ),
        InkWell(
          onTap: () {
            this.paginationPageNumberNotifier.value =
                this.paginationPageNumberNotifier.value + 1;
            this.onPageNumberClick(index);
          },
          child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: pageNumberBckColor,
                  border: Border.all(color: pageNumberBckColor, width: 0.5),
                  // boxShadow: AppColors.boxShadow,
                  shape: BoxShape.circle),
              child: Text("${index + 1}",
                  style: _getSelectedPageTextStyle(index))),
        ),
        if (index == (totalNumberOfPages - 1))
          _getPagingContainerWith(">",
              clickable: ((this.totalNumberOfPages > 1) &&
                  this.paginationPageNumberNotifier.value <
                      this.totalNumberOfPages),
              onPress: onNextClick),
      ]),
    );
  }

  TextStyle _getSelectedPageTextStyle(int index) {
    return _themeData!.textTheme.bodyText1!.copyWith(
        color: ((this.paginationPageNumberNotifier.value - 1) == index)
            ? AppColors.scaffoldBackgroundColor
            : AppColors.disabledColor);
  }

  Widget _getPagingContainerWith(String data,
      {bool clickable = false, Function()? onPress}) {
    Widget pagingContainer = Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(right: 10, left: 10),
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            border: Border.all(
                color: clickable
                    ? AppColors.dividerColor
                    : AppColors.disabledColor,
                width: 0.5),
            shape: BoxShape.circle),
        child: Text(data,
            style: _themeData!.textTheme.bodyText1!.copyWith(
                color: clickable
                    ? AppColors.dividerColor
                    : AppColors.disabledColor)));
    if (clickable) {
      return InkWell(onTap: onPress, child: pagingContainer);
    } else {
      return pagingContainer;
    }
  }

  void _ontextFieldSubmit() {
    this.onTextFieldSubmit(jumpToPageNumberController.text.trim());
  }
}
