import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/util.dart';
import 'package:breakpoint/widgets/input/scenarios/preformed_chloramines.dart';

class BoosterChlorination extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PreformedChloramines(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DynamicText(
            'Booster Free Chlorine Addition',
            type: TextType.header,
          ),
        ),
        SliderOnly(
          title: 'Added Free Chlorine Concentration (mg ${ScriptSet.cl2}/L)',
          value: Provider.of<Scenario>(context).freeChlorineConc,
          onChanged: Provider.of<Scenario>(context).setFreeChlorineConc,
          min: 0.0,
          max: 10.0,
        ),
      ],
    );
  }
}
