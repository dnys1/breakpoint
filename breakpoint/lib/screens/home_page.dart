import 'dart:io';

import 'package:breakpoint/blocs/simulation_bloc/bloc.dart';
import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/util.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/widgets/input/scenarios/scenarios.dart';
import 'package:breakpoint/widgets/platform/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'results_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  Future<void> _showError(BuildContext context, String error) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (Platform.isAndroid) {
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(child: Text(error)),
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(error),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Dismiss'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimulationBloc, SimulationState>(
      condition: (prevState, nextState) =>
          prevState is! SimulationRunning ||
          nextState is ResultsLoaded ||
          nextState is SimulationFailure,
      listener: (context, state) {
        if (state is SimulationRunning) {
          if (Platform.isAndroid) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => BlocBuilder<SimulationBloc, SimulationState>(
                condition: (_, state) => state is SimulationRunning,
                builder: (context, _state) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: isBreakpointCurve(context)
                          ? <Widget>[
                              CircularProgressIndicator(
                                  value: (_state as SimulationRunning)
                                      .percentComplete),
                              SizedBox(height: 20.0),
                              Text(
                                  'Loading results... ${((_state as SimulationRunning).percentComplete * 100).toStringAsFixed(0)}%'),
                            ]
                          : <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              Text('Loading results...'),
                            ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoPopupSurface(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(),
                    SizedBox(height: 20.0),
                    BlocBuilder<SimulationBloc, SimulationState>(
                      condition: (_, state) => state is SimulationRunning,
                      builder: (context, _state) => isBreakpointCurve(context)
                          ? Text(
                              'Loading results... ${((_state as SimulationRunning).percentComplete * 100).toStringAsFixed(0)}%')
                          : Text('Loading results...'),
                    ),
                  ],
                ),
              ),
            );
          }
        } else if (state is ResultsLoaded) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).push(
            Platform.isAndroid
                ? MaterialPageRoute(
                    builder: (context) => ResultsPage(),
                  )
                : CupertinoPageRoute(
                    builder: (context) => ResultsPage(),
                  ),
          );
        } else if (state is SimulationFailure) {
          _showError(context, state.error);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: PlatformScaffold(
          title: Text('Setup'),
          showTabBar: true,
          leading: PlatformButton(
            padding: const EdgeInsets.all(2.0),
            child: DynamicText('Reset', type: TextType.appBarButton),
            onPressed: () {
              Provider.of<Scenario>(context).resetAll();
              Provider.of<Parameters>(context).reset();
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Platform.isIOS
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: CupertinoSegmentedControl(
                            children: <ScenarioType, Widget>{
                              ScenarioType.FormationDecay: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Formation/Decay'),
                              ),
                              ScenarioType.BreakpointCurve: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Breakpoint Curve'),
                              ),
                            },
                            groupValue:
                                Provider.of<Scenario>(context).scenarioType,
                            onValueChanged:
                                Provider.of<Scenario>(context).setScenarioType,
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: Platform.isAndroid ? 20.0 : 10.0),
                    child: DynamicText(
                      isFormationDecay(context)
                          ? 'Simulate the formation and decay of chlorine species over time. Select initial parameters, then press "Run Simulation".'
                          : 'Simulate the breakpoint curve resulting from the initial chemistry of the water. Select initial parameters, then press "Run Simulation".',
                      type: TextType.subhead,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 10.0),
                    child: Divider(),
                  ),
                  isBreakpointCurve(context)
                      ? BreakpointCurve()
                      : FormationDecay()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
