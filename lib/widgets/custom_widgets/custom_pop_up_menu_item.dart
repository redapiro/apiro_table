import 'package:flutter/material.dart';

class CustomPopUpMenuItem<T> extends PopupMenuEntry<T> {
  final Widget child;
  CustomPopUpMenuItem({required this.child});
  @override
  State<StatefulWidget> createState() {
    
    return CustomPopUpMenuItemState<T, CustomPopUpMenuItem<T>>();
  }

  @override
  
  double get height => kMinInteractiveDimension;

  @override
  bool represents(T? value) {
    
    return false;
  }
}

class CustomPopUpMenuItemState<T, W extends CustomPopUpMenuItem<T>>
    extends State<W> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: false,
      child: InkWell(
        onTap: () {},
        canRequestFocus: false,
        child: widget.child,
      ),
    );
  }
}
