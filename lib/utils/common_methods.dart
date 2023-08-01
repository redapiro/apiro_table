import 'package:flutter/material.dart';

class CommonMethods {
  static void showPopUpMenu(
      BuildContext context, GlobalKey key, PopupMenuEntry popUpMenuItems) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    double left = offset.dx;
    double top = offset.dy;
    double screenWidth = MediaQuery.of(context).size.width;

    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            left, top + 40, screenWidth - (left + 150), 0),
        items: [
          popUpMenuItems,
        ]);
  }

  static void showPopUpMenuWithOffset(
      BuildContext context, Offset offset, PopupMenuEntry popUpMenuItems) {
    double left = offset.dx;
    double top = offset.dy;
    double screenWidth = MediaQuery.of(context).size.width;

    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            left, top + 40, screenWidth - (left + 150), 0),
        items: [
          popUpMenuItems,
        ]);
  }

  static void showSnackBarWithMessage(String message,
      {required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
  static String capitalizeFirstLetter(String ? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
