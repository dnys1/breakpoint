import 'dart:io';

import 'package:breakpoint/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlatformScaffold extends StatelessWidget {
  final Widget title;
  final Widget leading;
  final Widget trailing;
  final Widget body;
  final bool showTabBar;

  PlatformScaffold({this.title, this.body, this.leading, this.trailing, this.showTabBar = false});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Scaffold(
              appBar: AppBar(
                leading: leading,
                title: title,
                actions: trailing == null
                    ? null
                    : <Widget>[
                        trailing,
                      ],
                bottom: showTabBar ? TabBar(
                  tabs: ScenarioType.values.reversed
                      .map((ScenarioType scenarioType) {
                    switch (scenarioType) {
                      case ScenarioType.BreakpointCurve:
                        return Tab(
                          text: 'Breakpoint Curve',
                        );
                      case ScenarioType.FormationDecay:
                        return Tab(
                          text: 'Formation/Decay',
                        );
                      default:
                        throw '$scenarioType is not a valid scenario';
                    }
                  }).toList(),
                  onTap: (int selected) {
                    Provider.of<Scenario>(context).setScenarioType(
                        ScenarioType.values.reversed.elementAt(selected));
                  },
                ) : null,
              ),
              body: body,
            ),
          )
        : CupertinoPageScaffold(
            navigationBar: title != null
                ? CupertinoNavigationBar(
                    leading: leading,
                    middle: title,
                    trailing: trailing,
                  )
                : null,
            child: body,
          );
  }
}
