import 'dart:io';

import 'package:breakpoint/blocs/simulation_bloc/bloc.dart';
import 'package:breakpoint/models/models.dart';
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
    if (Platform.isAndroid) {
    } else if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(error),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Dismiss'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimulationBloc, SimulationState>(
      listener: (context, state) {
        if (state is SimulationRunning &&
            state.scenarioType == ScenarioType.BreakpointCurve) {
          if (Platform.isAndroid) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('Loading results...')
                    ],
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
                    Text('Loading results...')
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
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 20.0),
                  //   child: Text(
                  //     'Select initial parameters, then press "Run Simulation"',
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  Padding(
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
                      groupValue: Provider.of<Scenario>(context).scenarioType,
                      onValueChanged:
                          Provider.of<Scenario>(context).setScenarioType,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Divider(),
                  ),
                  Provider.of<Scenario>(context).scenarioType ==
                          ScenarioType.BreakpointCurve
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
