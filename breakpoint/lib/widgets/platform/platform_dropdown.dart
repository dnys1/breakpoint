import 'dart:io';

import 'package:breakpoint/widgets/input/input.dart';
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformDropdown<T> extends StatelessWidget {
  final Map<String, T> items;
  final T selectedValue;
  final String title;
  final String message;
  final void Function(T) onChanged;

  PlatformDropdown(
      {Key key,
      @required this.items,
      @required this.onChanged,
      @required this.selectedValue,
      this.title,
      this.message,})
      : super(key: key);

  Future<T> _getActionSheetResult(BuildContext context, String title,
      String message, Map<String, T> options) async {
    List<Widget> actions = [];
    for (String key in options.keys) {
      actions.add(CupertinoActionSheetAction(
        child: Text(key),
        onPressed: () => Navigator.of(context).pop(options[key]),
      ));
    }
    return showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(title),
        message: Text(message),
        actions: actions,
      ),
      useRootNavigator: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? DropdownButton<T>(
            items: items.keys
                .map(
                  (String key) => DropdownMenuItem(
                    child: Text(key),
                    value: items[key],
                  ),
                )
                .toList(),
            value: selectedValue,
            onChanged: onChanged,
          )
        : CupertinoButton.filled(
            child: DynamicText(
              items.keys.firstWhere((key) => items[key] == selectedValue),
              type: TextType.button,
            ),
            onPressed: () async {
              final res =
                  await _getActionSheetResult(context, title, message, items);

              if (res != null) {
                onChanged(res);
              }
            },
          );
  }
}
