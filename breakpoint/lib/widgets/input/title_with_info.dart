import 'dart:io';

import 'package:breakpoint/widgets/input/input.dart';
import 'package:flutter/material.dart';

class TitleWithInfo extends StatelessWidget {
  final String title;
  final Widget info;

  TitleWithInfo({
    Key key,
    @required this.title,
    @required this.info,
  }) : super(key: key);

  Future<void> _buildDialog({
    @required BuildContext context,
    @required Widget message,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Platform.isAndroid ? EdgeInsets.zero : const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DynamicText(
            title,
            type: TextType.header,
          ),
          Platform.isAndroid
              ? IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.info_outline),
                  onPressed: () => _buildDialog(
                    context: context,
                    message: info,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
