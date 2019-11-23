import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:flutter/services.dart';
import 'package:native_sim/native_sim.dart';
import 'breakpoint.dart';

typedef sim_func = Pointer<Utf8> Function(Double pH, Double T_C, Double Alk, Double TotNH_ini, Double TotCl_ini, Double Mono_ini, Double Di_ini, Double DOC1_ini, Double DOC2_ini, Double tf);
typedef SimFunc = Pointer<Utf8> Function(double pH, double T_C, double Alk, double TotNH_ini, double TotCl_ini, double Mono_ini, double Di_ini, double DOC1_ini, double DOC2_ini, double tf);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  final SimFunc simulate = 
    NativeSim.nativeSimLib
      .lookup<NativeFunction<sim_func>>('simulate')
      .asFunction<SimFunc>();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await NativeSim.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(child: Text('Version:$_platformVersion'),
          onPressed: () {
            BreakpointCalculator calculator = BreakpointCalculator(
              pH: 8,
              T_C: 25,
              Alk: 150,
              TotCl_mgL: 6.0,
              FreeNH_mgL: 1,
              TOC: 0,
            );
            Results results = calculator.runSimulation(simulate, 60, TimeScale.minutes);
            print(results);
          },)
        ),
      ),
    );
  }
}
