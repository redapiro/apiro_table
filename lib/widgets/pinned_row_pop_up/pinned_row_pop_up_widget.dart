import 'package:apiro_table/utils/app_colors.dart';
import 'package:apiro_table/widgets/custom_widgets/adaptive_elevated_button.dart';
import 'package:flutter/material.dart';

class PinnedRowPopupWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>>? metadata;
  final List<Map<String, dynamic>>? prodperties;
  final bool isPinned;
  final Function(bool)? onRowPinClick;

  final double? popUpButtonHeight;
  PinnedRowPopupWidget(
      {required this.metadata,
      this.onRowPinClick,
      this.prodperties,
      this.isPinned = false,
      this.subtitle = "",
      this.popUpButtonHeight = 50.0,
      this.title = ""});
  double? screenWidth;
  double? screenHeight;

  ThemeData? _themeData;
  late BuildContext context;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    this.context = context;
    this.screenWidth = MediaQuery.of(context).size.width;
    this.screenHeight = MediaQuery.of(context).size.height;

    return Container(
      child: _getPopUpMenuButton(),
    );
  }

  Widget _getPopUpMenuButton() {
    return Container(
        height:
            (screenWidth! < 450) ? screenHeight : (screenHeight ?? 100) - 90,
        width: (screenWidth! > 450) ? screenWidth! * 0.30 : screenWidth,
        decoration: BoxDecoration(
          color: _themeData!.scaffoldBackgroundColor,
          boxShadow: AppColors.boxShadowRightSide,
        ),
        child: _getPopUpMenuItems(context));
  }

  PopupMenuItem _getPopUpMenuItems(BuildContext context) {
    return PopupMenuItem(
      enabled: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 15),
        _getTitleAndPopUpCloseRow(context),
        SizedBox(height: 10),
        _getSubtitleRow(),
        SizedBox(height: 5),
        _getPinFilterHideRow(),
        SizedBox(height: 5),
        _getHorizontalLine(),
        SizedBox(height: 10),
        _getPropertiesWidget(),
        SizedBox(height: 10),
        _getMetadataWidget()
      ]),
    );
  }

  Widget _getTitleAndPopUpCloseRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(
          this.title,
          // style: _themeData!.textTheme.subtitle1,
        )),
        SizedBox(width: 10),
        InkWell(
          child: Icon(Icons.close, color: AppColors.dividerColor),
          onTap: () {
            this.onRowPinClick!(true);
          },
        )
      ],
    );
  }

  Widget _getSubtitleRow() {
    return Container(
        child: Text(this.subtitle,
            textAlign: TextAlign.start,
            style: _themeData!.textTheme.titleSmall!
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
                textColor: AppColors.scaffoldBackgroundColor,
                onClick: _onColumnPinClick),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(height: 5),
      ],
    ));
  }

  Widget _getButtonWithTitle(
      String title, IconData icon, Color? backgroundColor,
      {bool addBorder = false,
      Color textColor = Colors.black,
      Function? onClick}) {
    return Container(
        child: AdaptiveElevatedButton(
      buttonBackgroundColor: backgroundColor,
      width: 75,
      height: 45,
      decoration: addBorder
          ? BoxDecoration(
              border: Border.all(width: 1, color: AppColors.dividerColor),
              borderRadius: BorderRadius.circular(5.0))
          : null,
      onPressed: () {
        onClick!();
      },
      child: Text(
        title,
        style: _themeData!.textTheme.titleSmall!.copyWith(color: textColor),
      ),
    ));
  }

  Widget _getHorizontalLine() {
    return Container(
      height: 0.5,
      color: AppColors.disabledColor,
    );
  }

  Widget _getMetadataWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "\nMetaData:\n",
            style: _themeData!.textTheme.titleMedium!,
          ),
          Column(
            children: List.generate(
                this.metadata!.length == 0 ? 0 : this.metadata![0].length,
                (index) {
              return Row(
                children: [
                  Text(this.metadata![0].keys.toList()[index] + ": ",
                      style: _themeData!.textTheme.titleSmall!),
                  Text(this.metadata![0].values.toList()[index],
                      style: _themeData!.textTheme.titleSmall!),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _getPropertiesWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Properties: \n", style: _themeData!.textTheme.titleMedium!),
          Column(
            children: List.generate(
                this.prodperties!.length == 0 ? 0 : this.prodperties![0].length,
                (index) {
              return Row(
                children: [
                  Text(this.prodperties![0].keys.toList()[index] + ": ",
                      style: _themeData!.textTheme.titleSmall!),
                  Text(this.prodperties![0].values.toList()[index],
                      style: _themeData!.textTheme.titleSmall!),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  void _onColumnPinClick() {
    this.onRowPinClick!(false);
  }
}
