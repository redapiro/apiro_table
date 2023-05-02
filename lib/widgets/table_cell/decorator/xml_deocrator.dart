import 'package:flutter/material.dart';

//@Rohit why is this class not called ValidCellDecorator to be consistent with
// with the other classes in this folder
class XMLDecoratorWidget extends StatelessWidget {
  final String data;
  final String cellStatus;

  final Function() onCellTap;
  final Function() onCellDoubleTap;

  XMLDecoratorWidget({
    required this.data,
    required this.cellStatus,
    required this.onCellTap,
    required this.onCellDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _onDataCellTap();
        },
        onDoubleTap: () {
          _onDoubleTap();
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
                "assets/images/xml.png",
                height: 30,
                width: 70,
                fit: BoxFit.contain,
              ),
            )));
  }

  void _onDataCellTap() {
    this.onCellTap();
  }

  void _onDoubleTap() {
    this.onCellDoubleTap();
  }
}
