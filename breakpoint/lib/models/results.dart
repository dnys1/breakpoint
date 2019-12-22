import 'dart:math';

import 'package:breakpoint/models/parameters.dart';
import 'package:breakpoint/models/scenario.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

extension Log on num {
  num get log10 => log(this) / log(10);
}

extension Rounding on num {
  num roundToNearest(num rounder) {
    num dividend = this / rounder;
    num lowBound = dividend.floor();
    num uppBound = dividend.ceil();

    if ((this - (rounder * lowBound)).abs() <
        (this - (rounder * uppBound)).abs()) {
      return (lowBound * rounder).truncateToDigit(rounder.log10.floor());
    } else {
      return (uppBound * rounder).truncateToDigit(rounder.log10.floor());
    }
  }

  num roundUpToNearest(num rounder) {
    num dividend = this / rounder;
    num uppBound = dividend.ceil();

    return (uppBound * rounder).truncateToDigit(rounder.log10.floor());
  }

  num truncateToDigit(int digit) {
    return (this / pow(10, digit)).truncate() * pow(10, digit);
  }
}

class ResultObj {
  List<double> t = [];
  List<double> totNH = [];
  List<double> totCl = [];
  List<double> freeCl = [];
  List<double> nh2cl = [];
  List<double> nhcl2 = [];
  List<double> ncl3 = [];

  @override
  String toString() {
    String string = "";
    for (int i = 0; i < t.length; i++) {
      string +=
          "${t[i]}\t${totNH[i]}\t${totCl[i]}\t${nh2cl[i]}\t${nhcl2[i]}\t${ncl3[i]}\n";
    }
    return string;
  }
}

class FormationDecayResults extends Results {
  ResultObj _results;
  Map<num, int> _listX = {};
  num get roundFactor => _results.t.last / 20;

  @override
  Map<num, int> get listX => _listX;

  @override
  TimeUnit timeScale;

  @override
  List<ChartResult> get chartResults => _getChartResults();

  FormationDecayResults(this.timeScale) : super(timeScale);

  @override
  void addResult(String csv, {double ratio}) {
    ResultObj currResult = ResultObj();

    List<List<dynamic>> rows = const CsvToListConverter().convert(csv);
    rows.forEach((List<dynamic> row) {
      // Add rows to individual collectors, converting mol/L to mg-N/L for ammonia and mg-Cl2/L for chlorine species
      currResult.t.add(row[0]);
      currResult.totNH.add(row[1] * 14000);
      currResult.freeCl.add(row[2] * 71000);
      currResult.nh2cl.add(row[3] * 71000);
      currResult.nhcl2.add(row[4] * 71000 * 2);
      currResult.ncl3.add(row[5] * 71000 * 3);
      currResult.totCl.add(currResult.freeCl.last +
          currResult.nh2cl.last +
          currResult.nhcl2.last +
          currResult.ncl3.last);
    });

    _results = currResult;
    for (int i = 0; i < _results.t.length; i++) {
      double t = _results.t[i];
      _listX.putIfAbsent(t.roundToNearest(roundFactor), () => i);
    }
    _listX[_results.t.last.roundToNearest(roundFactor)] = _results.t.length - 1;
  }

  List<ChartResult> _getChartResults() {
    List<ChartResult> chartResults = [];

    for (int i = 0; i < _results.t.length; i++) {
      chartResults.add(ChartResult(
        t: _results.t[i],
        totNH: _results.totNH[i],
        totCl: _results.totCl[i],
        freeCl: _results.freeCl[i],
        nh2cl: _results.nh2cl[i],
        nhcl2: _results.nhcl2[i],
        ncl3: _results.ncl3[i],
        ratio: _results.freeCl[i] / _results.totNH[i],
      ));
    }

    return chartResults;
  }
}

class BreakpointCurveResults extends Results {
  Map<double, ResultObj> _results = {};
  Map<num, int> _listX = {};
  final num roundFactor = 0.5;

  int _startRatio;

  @override
  Map<num, int> get listX => _listX;

  @override
  TimeUnit timeScale;

  @override
  List<ChartResult> get chartResults => _getChartResults();

  BreakpointCurveResults(this.timeScale,
      {@required FixedConcentrationChem fixedConcentrationChem})
      : super(timeScale) {
    if (fixedConcentrationChem == FixedConcentrationChem.FreeAmmonia) {
      _startRatio = 0;
    } else {
      _startRatio = 1;
    }
  }

  @override
  void addResult(String csv, {@required double ratio}) {
    assert(ratio != null);

    ResultObj currResult = ResultObj();

    List<List<dynamic>> rows = const CsvToListConverter().convert(csv);
    rows.forEach((List<dynamic> row) {
      // Add rows to individual collectors, converting mol/L to mg-N/L for ammonia and mg-Cl2/L for chlorine species
      currResult.t.add(row[0]);
      currResult.totNH.add(row[1] * 14000);
      currResult.freeCl.add(row[2] * 71000);
      currResult.nh2cl.add(row[3] * 71000);
      currResult.nhcl2.add(row[4] * 71000 * 2);
      currResult.ncl3.add(row[5] * 71000 * 3);

      currResult.totCl.add(currResult.freeCl.last +
          currResult.nh2cl.last +
          currResult.nhcl2.last +
          currResult.ncl3.last);
    });

    _results.putIfAbsent(ratio, () => currResult);

    _listX[_startRatio] = 0;
    for (int i = 0; i < _results.keys.length; i++) {
      double ratio = _results.keys.elementAt(i);
      _listX.putIfAbsent(ratio.roundToNearest(roundFactor), () => i);
    }
    // Ensure the last element is the last item of the slider
    _listX[_results.keys.last.roundToNearest(roundFactor)] =
        _results.length - 1;

    // print(listX);
  }

  List<ChartResult> _getChartResults() {
    List<ChartResult> chartResults = [];

    _results.forEach((double ratio, ResultObj result) {
      chartResults.add(ChartResult(
        t: result.t.last,
        totNH: result.totNH.last,
        totCl: result.totCl.last,
        freeCl: result.freeCl.last,
        nh2cl: result.nh2cl.last,
        nhcl2: result.nhcl2.last,
        ncl3: result.ncl3.last,
        ratio: ratio,
      ));
    });

    return chartResults;
  }
}

abstract class Results with ChangeNotifier {
  TimeUnit timeScale;
  List<ChartResult> chartResults;
  Map<num, int> get listX;
  num roundFactor;

  Results(this.timeScale);

  void addResult(String csv, {double ratio});
}

class ChartResult {
  final double t;
  final double totNH;
  final double totCl;
  final double freeCl;
  final double nh2cl;
  final double nhcl2;
  final double ncl3;
  final double ratio;

  ChartResult({
    @required this.t,
    @required this.totNH,
    @required this.totCl,
    @required this.freeCl,
    @required this.nh2cl,
    @required this.nhcl2,
    @required this.ncl3,
    @required this.ratio,
  });
}
