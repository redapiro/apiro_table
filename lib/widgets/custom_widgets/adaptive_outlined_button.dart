import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveOutlinedButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final ButtonStyle? style;
  final Color? buttonColor;
  final BorderRadius? borderRadius;

  AdaptiveOutlinedButton({
    this.onPressed,
    this.style,
    this.buttonColor,
    this.borderRadius,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _getOutLinedButton(context);
    } else if (Platform.isLinux) {
      return _getOutLinedButton(context);
    } else if (Platform.isIOS) {
      return _getCupertinoButton();
    } else if (Platform.isMacOS) {
      return _getCupertinoButton();
    } else {
      return _getOutLinedButton(context);

    }
  }

  Widget _getOutLinedButton(BuildContext context) {
    return OutlinedButton(
      style: this.style ??
          OutlinedButton.styleFrom(
              foregroundColor: buttonColor ?? Theme.of(context).primaryColor, shape: RoundedRectangleBorder(
                  borderRadius:
                      this.borderRadius ?? BorderRadius.circular(5.0)),
              side: BorderSide(
                  color: buttonColor ?? Theme.of(context).primaryColor)),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _getCupertinoButton() {
    return CupertinoButton(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
