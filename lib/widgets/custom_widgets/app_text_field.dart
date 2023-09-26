import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  final String? Function(String?)? validator;
  final Function()? onEditingComplete;
  final String? label;
  final FocusNode? focusNode;
  final void Function(String?)? onSaved;
  final TextCapitalization textCapitalization;
  final Color? backgroundColor;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final void Function()? onTap;
  final InputBorder? border;
  final Function(String?)? onChanged;
  final double? textFieldHeight;
  final double? textFieldWidth;
  final bool? isPasswordField;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final EdgeInsets? margin;
  final bool? editable;
  final int? noOfLines;
  final TextStyle? textStyle;
  final bool autoFocus;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixWidget;

  AppTextField({
    this.label,
    this.validator,
    this.onTap,
    this.border,
    this.onSaved,
    this.focusNode,
    this.onChanged,
    this.textFieldWidth,
    this.noOfLines,
    this.textStyle,
    this.onEditingComplete,
    this.textFieldHeight,
    this.isPasswordField,
    this.enableSuggestions,
    this.autocorrect,
    this.backgroundColor,
    this.inputFormatters,
    this.margin,
    this.editable,
    this.controller,
    this.textInputType,
    this.textCapitalization = TextCapitalization.none,
    this.autoFocus = false,
    this.prefixWidget,
  });

  @override
  _AppTextFieldState createState() {
    return _AppTextFieldState();
  }
}

class _AppTextFieldState extends State<AppTextField> {
  ThemeData? _themeData;
  bool obscureTextFlag = true;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);

    InputBorder border = OutlineInputBorder(
        borderSide: BorderSide(
            color: _themeData!.disabledColor.withOpacity(0.7),
            width: 0.5,
            style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(5));

    return Container(
      margin: widget.margin,
      width: widget.textFieldWidth,
      height: widget.textFieldHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: IgnorePointer(
          ignoring: widget.onTap != null,
          child: TextFormField(
              focusNode: widget.focusNode ?? FocusNode(),
              autofocus: widget.autoFocus,
              onChanged: widget.onChanged,
              onEditingComplete: widget.onEditingComplete ?? () {},
              enabled: widget.editable,
              key: ValueKey(widget.label),
              validator: widget.validator,
              style: widget.textStyle,
              maxLines: widget.noOfLines ?? 1,
              enableSuggestions: widget.enableSuggestions ?? false,
              autocorrect: widget.autocorrect ?? false,
              inputFormatters: widget.inputFormatters,
              obscureText:
                  (widget.isPasswordField ?? false) ? obscureTextFlag : false,
              controller: widget.controller,
              decoration: InputDecoration(
                  prefixIcon: widget.prefixWidget,
                  enabledBorder: widget.border ?? border,
                  focusedBorder: widget.border ?? border,
                  border: widget.border ?? border,
                  errorBorder: null,
                  focusedErrorBorder: null,
                  disabledBorder: widget.border ?? border,
                  // suffixIcon: (widget.isPasswordField ?? false)
                  //     ? InkWell(
                  //         child: Icon(Icons.remove_red_eye,
                  //             color: !obscureTextFlag
                  //                 ? _themeData!.highlightColor
                  //                 : _themeData!.disabledColor),
                  //         onTap: () {
                  //           setState(() {
                  //             FocusScope.of(context).requestFocus(FocusNode());
                  //             obscureTextFlag = !obscureTextFlag;
                  //           });
                  //         },
                  //       )
                  //     : null,

                  contentPadding:
                      EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  hintText: widget.label,
                  hintStyle: widget.textStyle ??
                      _themeData!.textTheme.titleMedium!
                          .copyWith(color: _themeData!.disabledColor),
                  fillColor: widget.backgroundColor ?? Colors.white,
                  filled: true),
              keyboardType: widget.textInputType ?? TextInputType.text,
              textInputAction: TextInputAction.done,
              textCapitalization: widget.textCapitalization,
              onSaved: widget.onSaved),
        ),
      ),
    );
  }
}
