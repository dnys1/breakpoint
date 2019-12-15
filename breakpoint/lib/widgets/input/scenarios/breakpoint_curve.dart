import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/util.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/widgets/platform/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class BreakpointCurve extends StatelessWidget {
  Widget _getSlider(BuildContext context) {
    switch (Provider.of<Scenario>(context).fixedConcentrationChem) {
      case FixedConcentrationChem.FreeChlorine:
        return SliderOnly(
          title: 'Free Chlorine Concentration (mg ${ScriptSet.cl2}/L)',
          value: Provider.of<Scenario>(context).freeChlorineConc,
          onChanged: Provider.of<Scenario>(context).setFreeChlorineConc,
          min: 0.0,
          max: 10.0,
          delta: 0.05,
          displayDigits: 2,
        );
      case FixedConcentrationChem.FreeAmmonia:
        return SliderOnly(
          title: 'Free Ammonia Concentration (mg ${ScriptSet.nh3}-N/L)',
          value: Provider.of<Scenario>(context).freeAmmoniaConc,
          onChanged: Provider.of<Scenario>(context).setFreeAmmoniaConc,
          min: 0.0,
          max: 10.0,
          delta: 0.05,
          displayDigits: 2,
        );
      default:
        throw 'Unknown fixed concentration state.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DynamicText(
            'Chemical with Fixed Concentration',
            type: TextType.header,
          ),
        ),
        PlatformDropdown<FixedConcentrationChem>(
          selectedValue: Provider.of<Scenario>(context).fixedConcentrationChem,
          title: 'Fixed Chemical Concentration',
          message: Text(''),
          items: <String, FixedConcentrationChem>{
            'Free Chlorine': FixedConcentrationChem.FreeChlorine,
            'Free Ammonia': FixedConcentrationChem.FreeAmmonia,
          },
          onChanged: Provider.of<Scenario>(context).setFixedConcentrationChem,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _getSlider(context),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(),
        ),
        getWaterQualityInputs(context),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RunSimulationButton(),
        ),
      ],
    );
  }
}
