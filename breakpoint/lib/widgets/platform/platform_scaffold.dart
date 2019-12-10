import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformScaffold extends StatelessWidget {
  final Widget title;
  final Widget leading;
  final Widget trailing;
  final Widget body;

  PlatformScaffold({this.title, this.body, this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? Scaffold(
            appBar: AppBar(
              leading: leading,
              title: title,
              actions: trailing == null ? null : <Widget>[
                trailing,
              ],
            ),
            body: body,
          )
        : CupertinoPageScaffold(
            navigationBar: title != null
                ? CupertinoNavigationBar(
                    leading: leading,
                    middle: title,
                    trailing: trailing,
                  )
                : null,
            child: body,
          );
  }
}
