import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:csv/csv.dart';

import 'package:native_sim/native_sim.dart';

typedef sim_func = Pointer<Utf8> Function(Double pH, Double tC, Double alk, Double totNH0, Double totCl0, Double mono0, Double di0, Double doc10, Double doc20, Double tf);
typedef SimFunc = Pointer<Utf8> Function(double pH, double tC, double alk, double totNH0, double totCl0, double mono0, double di0, double doc10, double doc20, double tf);

enum TimeScale {
  seconds,
  minutes,
  hours,
  days
}

class Y extends Struct {
  @Double()
  double totNH;

  @Double()
  double totCl;

  @Double()
  double nh2cl;

  @Double()
  double nhcl2;

  @Double()
  double ncl3;

  @Double()
  double I;

  @Double()
  double doc1;

  @Double()
  double doc2;

  factory Y.allocate({
    double totNH,
    double totCl,
    double nh2cl,
    double nhcl2,
    double ncl3,
    double I,
    double doc1,
    double doc2,
  }) => allocate<Y>().ref
        ..totNH = totNH
        ..totCl = totCl
        ..nh2cl = nh2cl
        ..nhcl2 = nhcl2
        ..ncl3  = ncl3
        ..I     = I
        ..doc1  = doc1
        ..doc2  = doc2;
}

class BreakpointCalculator {
  double pH, tC, alk;
  Y y0;

  final SimFunc simulate = 
    NativeSim.nativeSimLib
      .lookup<NativeFunction<sim_func>>('simulate')
      .asFunction<SimFunc>();

  BreakpointCalculator({
    this.pH, 
    this.tC,
    this.alk,
    double toc,
    double fast = 0.02,
    double slow = 0.65,
    double q,
    double freeNHmgL,
    double totClmgL,
  }) {
      double totCl0 = totClmgL/71000;
      double totNH0 = freeNHmgL/14000;
      double mono0 = 0;
      double di0 = 0;
      double doc10 = toc * fast / 12000;
      double doc20 = toc * slow / 12000;

      print("Initializing parameters...");
      y0 = Y.allocate(
        totNH: totNH0,
        totCl: totCl0,
        nh2cl: mono0,
        nhcl2: di0,
        ncl3: 0,
        I: 0,
        doc1: doc10,
        doc2: doc20,
      );
  }

  Results runSimulation(int tf, TimeScale scale) {
    int seconds;
    switch (scale) {
      case TimeScale.days:
        seconds = tf * 60 * 60 * 24;
        break;
      case TimeScale.hours:
        seconds = tf * 60 * 60;
        break;
      case TimeScale.minutes:
        seconds = tf * 60;
        break;
      case TimeScale.seconds:
        seconds = tf;
        break;
    }

    print("Running simulation...");

    final Pointer<Utf8> resultsPointer = simulate(
      pH, 
      tC, 
      alk, 
      y0.totNH,
      y0.totCl,
      y0.nh2cl,
      y0.nhcl2,
      y0.doc1,
      y0.doc2,
      seconds.toDouble()
    );

    final String resultsCsv = Utf8.fromUtf8(resultsPointer);
    // print(resultsCsv);

    final Results results = Results(resultsCsv);
    return results;
  }
}

class Results {
  List<double> t;
  List<double> totNH;
  List<double> totCl;
  List<double> nh2cl;
  List<double> nhcl2;
  List<double> ncl3;

  Results(String csv) {
    t = [];
    totNH = [];
    totCl = [];
    nh2cl = [];
    nhcl2 = [];
    ncl3 = [];
    List<List<dynamic>> rows = const CsvToListConverter().convert(csv);
    rows.forEach((List<dynamic> row) {
      // Add rows to individual collectors, converting mol/L to mg-N/L for ammonia and mg-Cl2/L for chlorine species
      t.add(row[0]);
      totNH.add(row[1] * 14000);
      totCl.add(row[2] * 71000);
      nh2cl.add(row[3] * 71000);
      nhcl2.add(row[4] * 71000 * 2);
      ncl3.add(row[5] * 71000 * 3);
    });
  }

  @override
  String toString() {
    String string = "";
    for (int i = 0; i < t.length; i++) {
      string += "${t[i]}\t${totNH[i]}\t${totCl[i]}\t${nh2cl[i]}\t${nhcl2[i]}\t${ncl3[i]}\n";
    }
    return string;
  }
}

