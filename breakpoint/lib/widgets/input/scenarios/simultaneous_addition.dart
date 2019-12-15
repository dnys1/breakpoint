import 'dart:io';

import 'package:breakpoint/defaults.dart';
import 'package:breakpoint/widgets/platform/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/util.dart';

class SimultaneousAddition extends StatelessWidget {
  Widget _getFreeChlorineInput(BuildContext context) {
    FreeChlorineAdditionMthd method =
        Provider.of<Scenario>(context).freeChlorineAdditionMthd;
    switch (method) {
      case FreeChlorineAdditionMthd.KnownConcentration:
        return SliderOnly(
          title: 'Free Chlorine Concentration (mg ${ScriptSet.cl2}/L)',
          value: Provider.of<Scenario>(context).freeChlorineConc,
          onChanged: Provider.of<Scenario>(context).setFreeChlorineConc,
          min: 0.0,
          max: 10.0,
          delta: 0.05,
          displayDigits: 2,
        );
      case FreeChlorineAdditionMthd.GasFeed:
        return TextFieldOnly(
          title: 'Chlorine Gas Feed (lbs/d)',
          maxLength: 4,
          defaultVal: Defaults.freeChlorineGasFeed,
          placeholder: Provider.of<Scenario>(context).freeChlorineConc,
          onChanged: Provider.of<Scenario>(context).setFreeChlorineConc,
        );
      case FreeChlorineAdditionMthd.LiquidFeed:
        return TextFieldAndSlider(
          textFieldTitle: 'Chlorine Liquid Feed (lbs/d)',
          maxLength: 4,
          defaultTextVal: Defaults.freeChlorineLiquidFeed,
          placeholder: Provider.of<Scenario>(context).freeChlorineConc,
          onTextChanged: Provider.of<Scenario>(context).setFreeChlorineConc,
          sliderTitle:
              'Liquid Chlorine Strength (% available ${ScriptSet.cl2})',
          sliderValue: Provider.of<Scenario>(context).liquidChlorineStrength,
          sliderMin: 0.0,
          sliderMax: 100,
          sliderDivisions: 100,
          onSliderChanged:
              Provider.of<Scenario>(context).setLiquidChlorineStrength,
        );
      default:
        throw 'Unknown free chlorine method: $method';
    }
  }

  Widget _getFreeAmmoniaInput(BuildContext context) {
    FreeAmmoniaAdditionMthd method =
        Provider.of<Scenario>(context).freeAmmoniaAdditionMthd;
    switch (method) {
      case FreeAmmoniaAdditionMthd.KnownConcentration:
        return SliderOnly(
          title: 'Free Ammonia Concentration (mg ${ScriptSet.nh3}-N/L)',
          value: Provider.of<Scenario>(context).freeAmmoniaConc,
          onChanged: Provider.of<Scenario>(context).setFreeAmmoniaConc,
          min: 0.0,
          max: 5.0,
          delta: 0.05,
          displayDigits: 2,
        );
      case FreeAmmoniaAdditionMthd.ChlorineToNitrogenRatio:
        return SliderOnly(
          title: 'Mass Ratio (${ScriptSet.cl2}:N)',
          value: Provider.of<Scenario>(context).freeAmmoniaConc,
          onChanged: Provider.of<Scenario>(context).setFreeAmmoniaConc,
          min: 0.1,
          max: 15.0,
        );
      case FreeAmmoniaAdditionMthd.GasFeed:
        return TextFieldOnly(
          title: 'Ammonia Gas Feed (lbs/d)',
          maxLength: 4,
          defaultVal: Defaults.ammoniaGasFeed,
          placeholder: Provider.of<Scenario>(context).freeAmmoniaConc,
          onChanged: Provider.of<Scenario>(context).setFreeAmmoniaConc,
        );
      case FreeAmmoniaAdditionMthd.LiquidFeed:
        return TextFieldAndSlider(
          textFieldTitle: 'Ammonia Liquid Feed (lbs/d)',
          maxLength: 4,
          defaultTextVal: Defaults.ammoniaLiquidFeed,
          placeholder: Provider.of<Scenario>(context).freeAmmoniaConc,
          onTextChanged: Provider.of<Scenario>(context).setFreeAmmoniaConc,
          sliderTitle: 'Liquid Ammonia Strength (% available NH3)',
          sliderValue: Provider.of<Scenario>(context).liquidAmmoniaStrength,
          sliderMin: 0.0,
          sliderMax: 100.0,
          onSliderChanged:
              Provider.of<Scenario>(context).setLiquidAmmoniaStrength,
        );
      default:
        throw 'Unknown free ammonia method: $method';
    }
  }

  Widget _getPlantFlowInput(BuildContext context) {
    if (Provider.of<Scenario>(context).shouldShowPlantFlowInput) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Divider(),
          ),
          TextFieldOnly(
            title: 'Plant Flow (mgd)',
            maxLength: 3,
            defaultVal: Defaults.plantFlowMGD,
            placeholder: Provider.of<Scenario>(context).plantFlowMGD,
            onChanged: Provider.of<Scenario>(context).setPlantFlow,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TitleWithInfo(
          title: 'Free Chlorine Addition Method',
          info: Text(
            'Select the method for which chlorine is present in the system.',
            textAlign: TextAlign.center,
          ),
        ),
        PlatformDropdown<FreeChlorineAdditionMthd>(
          title: 'Free Chlorine Addition Method',
          message: Text(
              'Select the method for which chlorine is present in the system'),
          items: <String, FreeChlorineAdditionMthd>{
            'Known Concentration': FreeChlorineAdditionMthd.KnownConcentration,
            'Gas Feed': FreeChlorineAdditionMthd.GasFeed,
            'Liquid Feed': FreeChlorineAdditionMthd.LiquidFeed,
          },
          selectedValue:
              Provider.of<Scenario>(context).freeChlorineAdditionMthd,
          onChanged:
              Provider.of<Scenario>(context).setFreeChlorineAdditionMethod,
        ),
        SizedBox(height: 15.0),
        _getFreeChlorineInput(context),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Divider(),
        ),
        TitleWithInfo(
          title: 'Free Ammonia Addition Method',
          info: Text(
            'Select the method for which ammonia is present in the system.',
            textAlign: TextAlign.center,
          ),
        ),
        PlatformDropdown<FreeAmmoniaAdditionMthd>(
          selectedValue: Provider.of<Scenario>(context).freeAmmoniaAdditionMthd,
          items: <String, FreeAmmoniaAdditionMthd>{
            'Known Concentration': FreeAmmoniaAdditionMthd.KnownConcentration,
            'Chlorine to Nitrogen Ratio':
                FreeAmmoniaAdditionMthd.ChlorineToNitrogenRatio,
            'Gas Feed': FreeAmmoniaAdditionMthd.GasFeed,
            'Liquid Feed': FreeAmmoniaAdditionMthd.LiquidFeed,
          },
          title: 'Free Ammonia Addition Method',
          message: Text(
              'Select the method for which ammonia is present in the system'),
          onChanged:
              Provider.of<Scenario>(context).setFreeAmmoniaAdditionMethod,
        ),
        SizedBox(height: 15.0),
        _getFreeAmmoniaInput(context),
        _getPlantFlowInput(context),
      ],
    );
  }
}
