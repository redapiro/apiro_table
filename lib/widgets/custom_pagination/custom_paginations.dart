import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/utils/controller/global_controllers.dart';
import 'package:apiro_table/utils/provider_helper.dart';
import 'package:apiro_table/widgets/custom_widgets/app_text_field.dart';
import 'package:apiro_table/widgets/custom_widgets/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable

///
//
bool isListAlreadyScrolled = false;

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

  // final ValueNotiAppNotifiers.getInstance().paginationPageNumberNotifier;
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
    // required AppNotifiers.getInstance().paginationPageNumberNotifier,
    required this.jumpToPageTextFieldFocusNode,
    required this.perPageRowCountNotifier,
  }) : super(key: key) {
    rowCountPerPageList = this.pageNumbers;
    Future.delayed(Duration(milliseconds: 300), () {
      // if (!isListAlreadyScrolled) {
      //   _scrollToIndex(
      //       context!.riverPodReadStateNotifier(paginationPageNumberNotifier));
      // }
    });
  }

  BuildContext? context;
  ThemeData? _themeData;

  //To control the page number scrolling
  final _scrollController = ScrollController();

  List<String> rowCountPerPageList = [];
  final FocusNode jumpToPageTextFieldFocusNode;
  final TextEditingController jumpToPageNumberController;
  ValueNotifier<bool> refreshPagination = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    _themeData = Theme.of(context);

    return Scaffold(
      body: Consumer(
          builder: (context, value, child) {
            jumpToPageNumberController.text =
                value.watch(paginationPageNumberNotifier).toString();
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
                              child: Row(
                                children: [
                                  Expanded(
                                      child: _getPaginationPagesWidget(value)),
                                  _getJumpToPageNumberWidget(),
                                  Container(child: _getPageNumberDropDown()),
                                  Expanded(child: Container()),
                                ],
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
    return Row(
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
    );
  }

  Widget _getPaginationPagesWidget(WidgetRef ref) {
    return Row(children: [
      Row(
        children: [
          Text("Page",
              style: _themeData!.textTheme.bodyLarge!
                  .copyWith(color: AppColors.disabledColor)),
          _getPagingContainerWith("<",
              clickable: ref.watch(paginationPageNumberNotifier) >
                  1,
              onPress: this.onPreviousClick),
        ],
      ),
      Expanded(child: Container(height: 30, child: Consumer(
        builder: (context,ref,child) {
          var paginationNumberNotifier = ref.watch(paginationPageNumberNotifier);
          return ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: this.totalNumberOfPages, itemBuilder: (context, index) {
            Color pageNumberBckColor =
            ((paginationNumberNotifier - 1) ==
                index)
                ? AppColors.appBlueColor
                : Colors.transparent;
            return InkWell(
              onTap: () {
                ref.read(paginationPageNumberNotifier.notifier).updateValue(
                    index + 1);
                isListAlreadyScrolled = false;
                this.onPageNumberClick(index + 1);
              },
              child: Container(
                height: 28,
                width: 40,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: pageNumberBckColor,
                    border: Border.all(color: pageNumberBckColor, width: 0.5),
                    // boxShadow: AppColors.boxShadow,
                    shape: BoxShape.circle),

                child: Center(child: Text("${index + 1}",
                    style: _getSelectedPageTextStyle(index, ref))),),
            );
          });
        }
      ),)),
      _getPagingContainerWith(">",
          clickable: ((this.totalNumberOfPages > 1) &&
              ref.watch(paginationPageNumberNotifier) <
                  this.totalNumberOfPages),
          onPress: onNextClick),

    ]);
    // Color pageNumberBckColor =
    //     ((AppNotifiers.getInstance().paginationPageNumberNotifier.value - 1) ==
    //             index)
    //         ? AppColors.appBlueColor
    //         : Colors.transparent;
    // return Container(
    //   margin: EdgeInsets.only(left: 10, right: 10),
    //   child: Row(children: [
    //     if (index == 0)
    //       Row(
    //         children: [
    //           Text("Page",
    //               style: _themeData!.textTheme.bodyText1!
    //                   .copyWith(color: AppColors.disabledColor)),
    //           _getPagingContainerWith("<",
    //               clickable: AppNotifiers.getInstance()
    //                       .paginationPageNumberNotifier
    //                       .value >
    //                   1,
    //               onPress: this.onPreviousClick),
    //         ],
    //       ),
    //     InkWell(
    //       onTap: () {
    //         AppNotifiers.getInstance().paginationPageNumberNotifier.value =
    //             index + 1;
    //         this.onPageNumberClick(index + 1);
    //       },
    //       child: Container(
    //           padding: EdgeInsets.all(8),
    //           decoration: BoxDecoration(
    //               color: pageNumberBckColor,
    //               border: Border.all(color: pageNumberBckColor, width: 0.5),
    //               // boxShadow: AppColors.boxShadow,
    //               shape: BoxShape.circle),
    //           child: Text("${index + 1}",
    //               style: _getSelectedPageTextStyle(index))),
    //     ),
    //     if (index == (totalNumberOfPages - 1))
    //       _getPagingContainerWith(">",
    //           clickable: ((this.totalNumberOfPages > 1) &&
    //               AppNotifiers.getInstance()
    //                       .paginationPageNumberNotifier
    //                       .value <
    //                   this.totalNumberOfPages),
    //           onPress: onNextClick),
    //   ]),
    // );
  }

  TextStyle _getSelectedPageTextStyle(int index, WidgetRef ref) {
    return _themeData!.textTheme.bodyLarge!.copyWith(
        color: ((ref.watch(paginationPageNumberNotifier) -
            1) ==
            index)
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
            style: _themeData!.textTheme.bodyLarge!.copyWith(
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
    isListAlreadyScrolled = false;
  }

  // Define the function that scroll to an item
  void _scrollToIndex(index) {
    _scrollController.animateTo((40 * (index - 1)).toDouble(),
        duration: const Duration(milliseconds: 300), curve: Curves.bounceIn)
        .then((value) {
      isListAlreadyScrolled = true;
    });
  }
}
