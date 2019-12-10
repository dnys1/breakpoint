import 'package:breakpoint/widgets/platform/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/util.dart';
import 'scenarios.dart';

class FormationDecay extends StatelessWidget {
  Widget _getScenarioInputs(BuildContext context) {
    switch (Provider.of<Scenario>(context).scenario) {
      case ChemAdditionScenario.SimultaneousAddition:
        return SimultaneousAddition();
      case ChemAdditionScenario.PreformedChloramines:
        return PreformedChloramines();
      case ChemAdditionScenario.BoosterChlorination:
        return BoosterChlorination();
        break;
      default:
        throw 'Provided scenario is invalid: ${Provider.of<Scenario>(context).scenarioText}';
    }
  }

  Widget _getTOCInputs(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              DynamicText('Total Organic Carbon (TOC)', type: TextType.header),
        ),
        SliderOnly(
          title: 'TOC Concentration (mg C/L)',
          value: Provider.of<Parameters>(context).toc,
          onChanged: Provider.of<Parameters>(context).setTOC,
          min: 0,
          max: 10.0,
          delta: 0.1,
          displayDigits: 1,
        ),
        SliderOnly(
          title: 'TOC Fast Reactive Fraction',
          value: Provider.of<Parameters>(context).tocFastFrac,
          onChanged: Provider.of<Parameters>(context).setTOCFastFrac,
          min: 0,
          max: 0.1,
          delta: 0.01,
          displayDigits: 2,
        ),
        SliderOnly(
          title: 'TOC Slow Reactive Fraction',
          value: Provider.of<Parameters>(context).tocSlowFrac,
          onChanged: Provider.of<Parameters>(context).setTOCSlowFrac,
          min: 0,
          max: 0.9,
          delta: 0.05,
          displayDigits: 2,
        ),
      ],
    );
  }

  Widget _getTimeInputs(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DynamicText('Simulation Time Unit Selection',
              type: TextType.header),
        ),
        PlatformDropdown<TimeUnit>(
          selectedValue: Provider.of<Parameters>(context).timeUnit,
          title: 'Simulation Time Unit',
          message: 'Will add later',
          items: <String, TimeUnit>{
            'Minutes': TimeUnit.minutes,
            'Hours': TimeUnit.hours,
            'Days': TimeUnit.days,
          },
          onChanged: Provider.of<Parameters>(context).setTimeUnit,
        ),
        SizedBox(height: 15.0),
        SliderOnly(
          title:
              'Simulation Time (${Provider.of<Parameters>(context).timeUnitText.toLowerCase()})',
          value: Provider.of<Parameters>(context).time,
          onChanged: Provider.of<Parameters>(context).setTime,
          min: 1,
          max: 60,
          delta: 1,
          displayDigits: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              DynamicText('Chemical Addition Scenario', type: TextType.header),
        ),
        PlatformDropdown<ChemAdditionScenario>(
          selectedValue: Provider.of<Scenario>(context).scenario,
          title: 'Chemical Addition Scenario',
          message: 'Will add later',
          items: <String, ChemAdditionScenario>{
            'Simultaneous Addition': ChemAdditionScenario.SimultaneousAddition,
            'Preformed Chloramines': ChemAdditionScenario.PreformedChloramines,
            'Booster Chlorination': ChemAdditionScenario.BoosterChlorination,
          },
          onChanged: Provider.of<Scenario>(context).setScenario,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(),
        ),
        _getScenarioInputs(context),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(),
        ),
        getWaterQualityInputs(context),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(),
        ),
        _getTOCInputs(context),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(),
        ),
        _getTimeInputs(context),
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
