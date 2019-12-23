import 'package:breakpoint/util.dart';

enum TimeUnit {
  ratio,
  minutes,
  hours,
  days,
}

extension ScaleFactor on TimeUnit {
  int get scaleFactor {
    switch (this) {
      case TimeUnit.ratio:
        return 1;
      case TimeUnit.minutes:
        return 60;
      case TimeUnit.hours:
        return 60 * 60;
      case TimeUnit.days:
        return 60 * 60 * 24;
      default:
        throw ArgumentError('Time unit not recognized: $this');
    }
  }

  String get string => this.toString().split('.')[1];

  String get xAxisTitle {
    if (this == TimeUnit.days ||
        this == TimeUnit.hours ||
        this == TimeUnit.minutes) {
      return 'Time (${this.string})';
    } else {
      return 'Initial ${ScriptSet.cl2}:N Mass Ratio (mg ${ScriptSet.cl2} : mg N)';
    }
  }

  double get min => 1;

  double get max {
    switch (this) {
      case TimeUnit.minutes:
        return 60;
      case TimeUnit.hours:
        return 24;
      case TimeUnit.days:
        return 4;
      case TimeUnit.ratio:
        return 15;
      default:
        throw StateError("$this should not happen");
    }
  }
}