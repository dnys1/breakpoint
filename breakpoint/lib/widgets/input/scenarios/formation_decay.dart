import 'dart:io';

import 'package:breakpoint/widgets/platform/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/util.dart';
import 'scenarios.dart';

// The gray color used for text that appears in the title area.
// Extracted from https://developer.apple.com/design/resources/.
const Color _kContentTextColor = Color(0xFF8F8F8F);
const TextStyle _kActionSheetContentStyle = TextStyle(
  fontFamily: '.SF UI Text',
  inherit: false,
  fontSize: 13.0,
  fontWeight: FontWeight.w400,
  color: _kContentTextColor,
  textBaseline: TextBaseline.alphabetic,
);

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
        TitleWithInfo(
          title: 'Total Organic Carbon (TOC)',
          info: Text(
            'Select the known concentration of total organic carbon and the known/assumed fraction involved in fast and slow organic reactions.',
            textAlign: TextAlign.center,
          ),
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
        TitleWithInfo(
          title: 'Simulation Time Unit',
          info: Text(
            'Select the unit of time for the simulation.',
            textAlign: TextAlign.center,
          ),
        ),
        PlatformDropdown<TimeUnit>(
          selectedValue: Provider.of<Parameters>(context).timeUnit,
          title: 'Simulation Time Unit',
          message: Text('Select the unit of time for the simulation'),
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
          min: Provider.of<Parameters>(context).timeUnit.min,
          max: Provider.of<Parameters>(context).timeUnit.max,
          delta: 1,
          displayDigits: 0,
        ),
      ],
    );
  }

  Widget chemAdditionScenarioMessage(BuildContext context) {
    String scen1Title = 'Simultaneous Addition: ';
    String scen1Message =
        'Free chlorine and free ammonia are present simultaneously.\n\n';
    String scen2Title = 'Preformed Chloramines: ';
    String scen2Message =
        'Known concentrations of chloramines and free ammonia already exist.\n\n';
    String scen3Title = 'Booster Chlorination: ';
    String scen3Message =
        'Known concentrations of chloramines and free ammonia already exist and you wish to simulate adding free chlorine to recombine the free ammonia into chloramines.';

    TextStyle style = Platform.isAndroid
        ? DefaultTextStyle.of(context).style
        : _kActionSheetContentStyle;

    return RichText(
      text: TextSpan(style: style, children: [
        TextSpan(
            text: scen1Title,
            style: style.copyWith(fontWeight: FontWeight.w600)),
        TextSpan(text: scen1Message),
        TextSpan(
            text: scen2Title,
            style: style.copyWith(fontWeight: FontWeight.w600)),
        TextSpan(text: scen2Message),
        TextSpan(
            text: scen3Title,
            style: style.copyWith(fontWeight: FontWeight.w600)),
        TextSpan(text: scen3Message),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TitleWithInfo(
          title: 'Chemical Addition Scenario',
          info: chemAdditionScenarioMessage(context),
        ),
        PlatformDropdown<ChemAdditionScenario>(
          selectedValue: Provider.of<Scenario>(context).scenario,
          title: 'Chemical Addition Scenario',
          message: chemAdditionScenarioMessage(context),
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
