import 'package:breakpoint/models/models.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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

  @override
  TimeUnit timeScale;

  @override
  List<ChartResult> get chartResults => _getChartResults();

  BreakpointCurveResults(this.timeScale) : super(timeScale);

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
