import 'package:breakpoint/widgets/input/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:meta/meta.dart';

class SliderOnly extends StatelessWidget {
  final String title;
  final double value;
  final Function(double) onChanged;
  final double min;
  final double max;
  final double delta;
  final int divisions;
  final int displayDigits;

  const SliderOnly({
    Key key,
    @required this.title,
    @required this.value,
    @required this.onChanged,
    @required this.min,
    @required this.max,
    this.delta,
    this.divisions,
    this.displayDigits = 1,
  }) : super(key: key);

  int getDivisions() {
    if (divisions == null) {
      if (delta != null) {
        return ((max - min) / delta).floor();
      } else {
        return null;
      }
    } else {
      return divisions;
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Platform.isAndroid
                  ? Slider(
                      value: value,
                      onChanged: onChanged,
                      min: min,
                      max: max,
                      divisions: getDivisions(),
                    )
                  : CupertinoSlider(
                      value: value,
                      onChanged: onChanged,
                      min: min,
                      max: max,
                      divisions: getDivisions(),
                    ),
              ),
              Text(value.toStringAsFixed(displayDigits)),
            ],
          ),
        ),
      ],
    );
  }
}
