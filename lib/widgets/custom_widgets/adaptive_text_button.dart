import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveTextButton extends StatelessWidget {
  final String? text;
  final Function()? onPressed;
  final ButtonStyle? style;
  final double? width;
  final double? height;
  final Widget? child;

  AdaptiveTextButton({
    this.onPressed,
    this.style,
    this.width,
    this.child,
    this.height,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _getTextButton(context);
    } else if (Platform.isLinux) {
      return _getTextButton(context);
    } else if (Platform.isIOS) {
      return _getCupertinoButton();
    } else if (Platform.isMacOS) {
      return _getCupertinoButton();
    } else {
      return _getTextButton(context);
    }
  }

  Widget _getTextButton(BuildContext context) {
    return Container(
      width: this.width ?? double.maxFinite,
      height: this.height ?? 50,
      child: TextButton(
        style: this.style ??
            TextButton.styleFrom(primary: Theme.of(context).primaryColor),
        child: this.child ??
            Text(
              text ?? "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _getCupertinoButton() {
    return CupertinoButton(
      child: this.child ??
          Text(
            text ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
      onPressed: onPressed,
    );
  }
}
