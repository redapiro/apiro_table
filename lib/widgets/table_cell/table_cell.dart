import 'package:flutter/material.dart';

class TableGridCell extends StatelessWidget {
  final String title;
  final TextStyle? style;
  TableGridCell({Key? key, required this.title, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child:
            Text(title, style: style ?? Theme.of(context).textTheme.subtitle1));
  }
}
