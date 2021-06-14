import 'package:flutter/material.dart';

//@Rohit why is this class not called ValidCellDecorator to be consistent with
// with the other classes in this folder
class JSONDecoratorWidget extends StatelessWidget {
  final String data;
  final Function() onCellTap;
  final String cellStatus;
  final Function() onCellDoubleTap;

  JSONDecoratorWidget({
    required this.data,
    required this.onCellTap,
    required this.cellStatus,
    required this.onCellDoubleTap,
  });

  late ThemeData _themeData;

  BuildContext? context;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    this.context = context;
    return GestureDetector(
        onTap: () {
          _onDataCellTap();
        },
        onDoubleTap: () {
          this.onCellDoubleTap();
        },
        child: Container(
            height: 60,
            width: 150,
            alignment: AlignmentDirectional.center,
            // color: this.cellStatus.getBackgroundColorForTableCellStatus(),
            child: Container(
              height: 30,
              width: 70,
              child: Image.asset(
                "assets/images/json.png",
                height: 30,
                width: 70,
                fit: BoxFit.contain,
              ),
            )));
  }

  void _onDataCellTap() {
    this.onCellTap();
  }
}
