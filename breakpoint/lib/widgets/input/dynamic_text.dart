import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:io';

enum TextType { header, subhead, button, appBarButton, small }

class DynamicText extends StatelessWidget {
  final String text;
  final TextType type;
  final TextAlign textAlign;
  final double fontSize;

  DynamicText(
    this.text, {
    Key key,
    @required this.type,
    this.textAlign = TextAlign.start,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (type) {
      case TextType.header:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.body2.copyWith(
                  fontSize: fontSize ?? 15.0,
                )
            : CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: fontSize,
                );
        break;
      case TextType.subhead:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.body1.copyWith(
                  fontSize: fontSize,
                )
            : CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(fontSize: fontSize ?? 15.0);
        break;
      case TextType.button:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.button.copyWith(fontSize: fontSize)
            : CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(color: Colors.white, fontSize: fontSize);
        break;
      case TextType.appBarButton:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.button.copyWith(fontSize: fontSize)
            : CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark
                      ? Colors.white
                      : CupertinoColors.activeBlue,
                  fontSize: fontSize,
                );
        break;
      case TextType.small:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.caption.copyWith(fontSize: fontSize)
            : CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: fontSize ?? 10,
                );
    }
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}
