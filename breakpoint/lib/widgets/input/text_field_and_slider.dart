import 'dart:io';

import 'package:breakpoint/widgets/input/dynamic_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import 'input.dart';

class TextFieldAndSlider extends StatelessWidget {
  final String sliderTitle;
  final String textFieldTitle;
  final double width;
  final int maxLength;
  final double placeholder;
  final double sliderValue;
  final double sliderMin;
  final double sliderMax;
  final int sliderDivisions;
  final Function(double) onSliderChanged;
  final Function(double) onTextChanged;

  const TextFieldAndSlider({
    Key key,
    @required this.sliderTitle,
    @required this.textFieldTitle,
    @required this.maxLength,
    @required this.placeholder,
    @required this.sliderValue,
    @required this.sliderMin,
    @required this.sliderMax,
    @required this.onSliderChanged,
    @required this.onTextChanged,
    this.width = 100,
    this.sliderDivisions = 100,
  }) : super(key: key);

  void recordVal(String val) {
    if (val != null) {
      double conc = double.tryParse(val);
      if (conc != null) {
        onTextChanged(conc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DynamicText(
          textFieldTitle,
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
                  key: Key(textFieldTitle),
                  maxLength: maxLength,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: placeholder.toStringAsFixed(1),
                  ),
                  onChanged: recordVal,
                )
              : CupertinoTextField(
                  key: Key(textFieldTitle),
                  maxLength: maxLength,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  placeholder: placeholder.toStringAsFixed(1),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DynamicText(
            sliderTitle,
            type: TextType.subhead,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: CupertinoSlider(
                  value: sliderValue,
                  onChanged: onSliderChanged,
                  min: sliderMin,
                  max: sliderMax,
                  divisions: sliderDivisions,
                ),
              ),
              Text(sliderValue.toStringAsFixed(1)),
            ],
          ),
        ),
      ],
    );
  }
}
