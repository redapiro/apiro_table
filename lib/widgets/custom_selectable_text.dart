import 'package:apiro_table/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSelectableText extends StatelessWidget {
  final String data;
  final TextAlign? textAlign;
  final bool ? isSelectableText;
  final TextStyle? style;

  const CustomSelectableText(this.data,
      {this.textAlign, this.style, this.isSelectableText})
      : super();

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      data,
      textAlign: textAlign,
      style: style,
      enableInteractiveSelection: isSelectableText?? false,
      contextMenuBuilder:
          (BuildContext context, EditableTextState editableTextState) {
        return AdaptiveTextSelectionToolbar(
          anchors: editableTextState.contextMenuAnchors,
          // Build the default buttons, but make them look custom.
          // In a real project you may want to build different
          // buttons depending on the platform.
          children: editableTextState.contextMenuButtonItems
              .map((ContextMenuButtonItem buttonItem) {
            return CupertinoButton(
              borderRadius: null,
              color: Colors.black,
              disabledColor: AppColors.disabledColor,
              onPressed: buttonItem.onPressed,
              padding: const EdgeInsets.all(10.0),
              pressedOpacity: 0.7,
              child: SizedBox(
                width: 200.0,
                child: Text(
                  CupertinoTextSelectionToolbarButton.getButtonLabel(
                      context, buttonItem),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
