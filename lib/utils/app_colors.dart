import 'package:flutter/material.dart';

class AppColors {
  static const Color textFieldBackGroundColor =
      Color.fromRGBO(233, 240, 253, 1.0);
  static const Color primaryColor = Color.fromRGBO(207, 59, 50, 1.0);
  static const Color secondaryColor = Color.fromRGBO(237, 239, 246, 1.0);
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color separatorColor = Color.fromRGBO(241, 243, 245, 1.0);
  static const Color appBlueColor = Color.fromRGBO(14, 86, 168, 1.0);
  static const Color disabledTabColor = Color.fromRGBO(122, 127, 144, 1.0);
  static Color disabledColor = Colors.grey.withOpacity(0.7);
  static Color dividerColor = Colors.black;
  static Color needleFillColor = Colors.green;
  static const Color selectedSideMenuOptionColor =
      Color.fromRGBO(14, 86, 168, 1.0);
  static const Color voilatedBlockingBackgroundColor =
      Color.fromRGBO(211, 44, 68, 1.0);
  static const Color voilatedNonBlockingBackgroundColor =
      Color.fromRGBO(255, 238, 227, 1.0);
  static const Color voilatedNonBlockingTextColor =
      Color.fromRGBO(163, 84, 21, 1.0);
  static const Color fixedPendingBackgroundColor =
      Color.fromRGBO(255, 233, 236, 1.0);
  static const Color fixedPendingTextColor = Color.fromRGBO(177, 30, 51, 1.0);
  static const Color validEditedBackgroundColor =
      Color.fromRGBO(223, 245, 255, 1.0);
  static const Color validBackgroundColor = Colors.green;
  static const Color validTextColor = Colors.white;
  static const Color fixedAndApprovedBackgroundColor =
      Color.fromRGBO(223, 245, 255, 1.0);
  static const Color validEditedTextColor = Color.fromRGBO(14, 86, 169, 1.0);
  static const Color fixedAndApprovedTextColor =
      Color.fromRGBO(14, 86, 169, 1.0);
  static const Color validUnEditedEvenBackgroundColor =
      Color.fromRGBO(237, 239, 246, 1.0);

  static const Color tableRowBackgroundColor =
      Color.fromRGBO(246, 247, 249, 1.0);

  static List<BoxShadow> boxShadow = [
    BoxShadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 8.0,
        color: disabledColor.withOpacity(0.5))
  ];
  static List<BoxShadow> boxShadowRightSide = [
    BoxShadow(
        offset: Offset(0.0, 2.0),
        blurRadius: 8.0,
        color: disabledColor.withOpacity(0.5))
  ];
}
