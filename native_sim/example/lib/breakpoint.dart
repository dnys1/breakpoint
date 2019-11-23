import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:csv/csv.dart';

typedef sim_func = ffi.Pointer<Utf8> Function(ffi.Double pH, ffi.Double T_C, ffi.Double Alk, ffi.Double TotNH_ini, ffi.Double TotCl_ini, ffi.Double Mono_ini, ffi.Double Di_ini, ffi.Double DOC1_ini, ffi.Double DOC2_ini, ffi.Double tf);
typedef SimFunc = ffi.Pointer<Utf8> Function(double pH, double T_C, double Alk, double TotNH_ini, double TotCl_ini, double Mono_ini, double Di_ini, double DOC1_ini, double DOC2_ini, double tf);

class BreakpointCalculator {
  double pH, T_C, Alk;
  YPtr y0;

  BreakpointCalculator({
    this.pH, 
    this.T_C,
    this.Alk,
    double TOC,
    double fast = 0.02,
    double slow = 0.65,
    double Q,
    double FreeNH_mgL,
    double TotCl_mgL,
  }) {
      //double TotCl_ini = TotCl_lbs_d/Q/8.34/71000;
      double TotCl_ini = TotCl_mgL/71000;
      double TotNH_ini = FreeNH_mgL/14000;
      double Mono_ini = 0;
      double Di_ini = 0;
      double DOC1_ini = TOC * fast / 12000;
      double DOC2_ini = TOC * slow / 12000;

      print("Initializing parameters...");
      y0 = YPtr.allocate(
        TotNH: TotNH_ini,
        TotCl: TotCl_ini,
        NH2Cl: Mono_ini,
        NHCl2: Di_ini,
        NCl3: 0,
        I: 0,
        DOC1: DOC1_ini,
        DOC2: DOC2_ini,
      );
  }

  Results runSimulation(SimFunc simulate, int tf, TimeScale scale) {
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

    final ffi.Pointer<Utf8> resultsPointer = simulate(
      pH, 
      T_C, 
      Alk, 
      y0.TotNH,
      y0.TotCl,
      y0.NH2Cl,
      y0.NHCl2,
      y0.DOC1,
      y0.DOC2,
      seconds.toDouble()
    );

    final String resultsCsv = Utf8.fromUtf8(resultsPointer);
    // print(resultsCsv);

    final Results results = Results(resultsCsv);
    return results;
  }
}

class SimResults extends ffi.Struct {
  ffi.Pointer<Utf8> csv;
}

class Results {
  List<double> t;
  List<double> TotNH;
  List<double> TotCl;
  List<double> NH2Cl;
  List<double> NHCl2;
  List<double> NCl3;

  Results(String csv) {
    t = [];
    TotNH = [];
    TotCl = [];
    NH2Cl = [];
    NHCl2 = [];
    NCl3 = [];
    List<List<dynamic>> rows = const CsvToListConverter().convert(csv);
    rows.forEach((List<dynamic> row) {
      double new_t = row[0];
      double new_TotNH = row[1] * 14000;
      double new_TotCl = row[2] * 71000;
      double new_NH2Cl = row[3] * 71000;
      double new_NHCl2 = row[4] * 71000 * 2;
      double new_NCl3  = row[5] * 71000 * 3;

      t.add(new_t);
      TotNH.add(new_TotNH);
      TotCl.add(new_TotCl);
      NH2Cl.add(new_NH2Cl);
      NHCl2.add(new_NHCl2);
      NCl3.add(new_NCl3);
    });
  }

  @override
  String toString() {
    String string = "";
    for (int i = 0; i < t.length; i++) {
      string += "${t[i]}\t${TotNH[i]}\t${TotCl[i]}\t${NH2Cl[i]}\t${NHCl2[i]}\t${NCl3[i]}\n";
    }
    return string;
  }
}

class Sequence {
  static List<int> list(int from, int to, int step) {
    List<int> seq = [];
    int numSteps = ((to - from) / step).truncate();
    for (int i = 0; i < numSteps; i++) {
      seq.add(from + i*step);
    }
    seq.add(to);
    return seq;
  }
}

enum TimeScale {
  seconds,
  minutes,
  hours,
  days
}

class Y {
  double TotNH;
  double TotCl;
  double NH2Cl;
  double NHCl2;
  double NCl3;

  Y({
    this.TotNH,
    this.TotCl,
    this.NH2Cl,
    this.NHCl2,
    this.NCl3
  });

  @override
  String toString() {
    return "$TotNH\t$TotCl\t$NH2Cl\t$NHCl2\t$NCl3";
  }
}

class YPtr extends ffi.Struct {
  @ffi.Double()
  double TotNH;

  @ffi.Double()
  double TotCl;

  @ffi.Double()
  double NH2Cl;

  @ffi.Double()
  double NHCl2;

  @ffi.Double()
  double NCl3;

  @ffi.Double()
  double I;

  @ffi.Double()
  double DOC1;

  @ffi.Double()
  double DOC2;

  factory YPtr.allocate({
    double TotNH,
    double TotCl,
    double NH2Cl,
    double NHCl2,
    double NCl3,
    double I,
    double DOC1,
    double DOC2,
  }) => allocate<YPtr>().ref
        ..TotNH = TotNH
        ..TotCl = TotCl
        ..NH2Cl = NH2Cl
        ..NHCl2 = NHCl2
        ..NCl3  = NCl3
        ..I     = I
        ..DOC1  = DOC1
        ..DOC2  = DOC2;
}