import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef VoidFunction = void Function();

class PlatformButton extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;
  final VoidFunction onPressed;

  PlatformButton({Key key, this.child, this.onPressed, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? FlatButton(
            padding: padding,
            child: child,
            onPressed: onPressed,
          )
        : CupertinoButton(
            padding: padding,
            child: child,
            onPressed: onPressed,
          );
  }
}
