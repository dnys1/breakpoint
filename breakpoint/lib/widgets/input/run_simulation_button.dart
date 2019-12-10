import 'dart:io';

import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breakpoint/blocs/simulation_bloc/bloc.dart';
import 'package:provider/provider.dart';

class RunSimulationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: BlocBuilder(
          bloc: BlocProvider.of<SimulationBloc>(context),
          builder: (_, bloc) => Platform.isAndroid
              ? FlatButton(
                  child: DynamicText('Run Simulation', type: TextType.button),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => BlocProvider.of<SimulationBloc>(context).add(
                    RunSimulation(
                      Provider.of<Scenario>(context),
                      Provider.of<Parameters>(context),
                    ),
                  ),
                )
              : CupertinoButton.filled(
                  child: DynamicText(
                    'Run Simulation',
                    type: TextType.button,
                  ),
                  onPressed: () => BlocProvider.of<SimulationBloc>(context).add(
                    RunSimulation(
                      Provider.of<Scenario>(context),
                      Provider.of<Parameters>(context),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
