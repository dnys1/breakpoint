import 'package:breakpoint/widgets/input/input.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

class TextFieldOnly extends StatelessWidget {
  final String title;
  final double defaultVal;
  final double placeholder;
  final Function(double) onChanged;
  final int maxLength;
  final double width;

  const TextFieldOnly({
    Key key,
    @required this.title,
    @required this.defaultVal,
    @required this.placeholder,
    @required this.onChanged,
    @required this.maxLength,
    this.width = 100,
  })  : assert(width > 0),
        super(key: key);

  void recordVal(String val) {
    if (val != null) {
      double conc = double.tryParse(val);
      if (conc != null) {
        onChanged(conc);
      } else {
        onChanged(defaultVal);
      }
    } else {
      onChanged(defaultVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DynamicText(
          title,
          type: TextType.subhead,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            // Set to be 100 pixels wide (cannot wrap in Container and set width)
            horizontal: (MediaQuery.of(context).size.width - width) / 2,
          ),
          child: Platform.isAndroid
              ? TextField(
                  key: Key(title),
                  maxLength: maxLength,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: recordVal,
                  decoration: InputDecoration(
                    hintText: placeholder.toStringAsFixed(1),
                  ),
                )
              : CupertinoTextField(
                  key: Key(title),
                  maxLength: maxLength,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  placeholder: placeholder.toStringAsFixed(0),
                  onChanged: recordVal,
                  placeholderStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.placeholderText,
                      darkColor: CupertinoColors.white,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
