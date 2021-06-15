import 'dart:io';
import 'package:apiro_table/utils/app_colors.dart';
import 'package:flutter/material.dart';

class TableColumnFilterIconWidget extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;
  final EdgeInsets? margin;
  final String? text;

  final Function? onIconClick;
  TableColumnFilterIconWidget(
      {this.height = 25,
      this.width = 25,
      this.color,
      this.onIconClick,
      this.text,
      this.margin});

  BuildContext? context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    AssetImage assetImage;
    // if (kIsWeb) {
    //   assetImage =
    //       AssetImage("assets/images/icons/valid_status_icon/web/valid.png");
    // } else if (Platform.isIOS) {
    //   assetImage =
    //       AssetImage("assets/images/icons/valid_status_icon/ios/valid.png");
    // } else if (Platform.isAndroid) {
    //   assetImage =
    //       AssetImage("assets/images/icons/valid_status_icon/android/valid.png");
    // } else {
    assetImage = AssetImage("assets/images/icons/filter_icon/filter.png");
    // }

    return InkWell(
      onTap: () {
        if (onIconClick != null) this.onIconClick!();
      },
      child: Container(
        margin: this.margin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.appBlueColor,
              ),
              child: Text(
                this.text!,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 9),
              ),
            ),
            SizedBox(height: 2),
            Tooltip(
                message: "Filter",
                child: Image(
                  image: assetImage,
                  height: height,
                  width: width,
                  color: AppColors.appBlueColor,
                  fit: BoxFit.contain,
                )),
          ],
        ),
      ),
    );
  }
}
