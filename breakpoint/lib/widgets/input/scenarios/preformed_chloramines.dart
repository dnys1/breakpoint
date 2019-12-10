import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:breakpoint/models/scenario.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/util.dart';

class PreformedChloramines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DynamicText(
            'Known Chemical Concentrations',
            type: TextType.header,
          ),
        ),
        SliderOnly(
          title: 'Monochloramine Concentration (mg Cl${scriptMap['2'].subscript}/L)',
          value: Provider.of<Scenario>(context).monochloramineConc,
          onChanged: Provider.of<Scenario>(context).setMonochloramineConc,
          min: 0.0,
          max: 10.0,
        ),
        SliderOnly(
          title: 'Dichloramine Concentration (mg Cl${scriptMap['2'].subscript}/L)',
          value: Provider.of<Scenario>(context).dichloramineConc,
          onChanged: Provider.of<Scenario>(context).setDichloramineConc,
          min: 0.0,
          max: 10.0,
        ),
        SliderOnly(
          title: 'Free Ammonia Concentration (mg NH${scriptMap['3'].subscript}-N/L)',
          value: Provider.of<Scenario>(context).freeAmmoniaConc,
          onChanged: Provider.of<Scenario>(context).setFreeAmmoniaConc,
          min: 0.0,
          max: 5.0,
        ),
      ],
    );
  }
}
