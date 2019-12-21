import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:io';

enum TextType { header, subhead, button, appBarButton, small }

class DynamicText extends StatelessWidget {
  final String text;
  final TextType type;
  final TextAlign textAlign;

  DynamicText(
    this.text, {
    Key key,
    @required this.type,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (type) {
      case TextType.header:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.body2
            : CupertinoTheme.of(context).textTheme.textStyle;
        break;
      case TextType.subhead:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.body1
            : CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(fontSize: 15.0);
        break;
      case TextType.button:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.button
            : CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(color: Colors.white);
        break;
      case TextType.appBarButton:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.button
            : CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color:
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark
                        ? Colors.white
                        : CupertinoColors.activeBlue);
        break;
      case TextType.small:
        style = Platform.isAndroid
            ? Theme.of(context).textTheme.caption
            : CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 10,
                );
    }
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}
