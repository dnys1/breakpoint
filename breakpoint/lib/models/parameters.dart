import 'package:flutter/material.dart';

import 'models.dart';

class Parameters with ChangeNotifier {
  double _pH = 8.0;
  double _tC = 25;
  double _alk = 150;
  double _toc = 0;
  double _tocFastFrac = 0.02;
  double _tocSlowFrac = 0.65;
  TimeUnit _timeUnit = TimeUnit.hours;
  double _time = 2.0;

  double get pH => _pH;
  double get tC => _tC;
  double get alk => _alk;
  double get toc => _toc;
  double get tocFastFrac => _tocFastFrac;
  double get tocSlowFrac => _tocSlowFrac;
  double get time => _time;
  TimeUnit get timeUnit => _timeUnit;

  String get timeUnitText {
    switch (_timeUnit) {
      case TimeUnit.minutes:
        return 'Minutes';
      case TimeUnit.hours:
        return 'Hours';
      case TimeUnit.days:
        return 'Days';
      default:
        throw 'Invalid time unit: $_timeUnit';
    }
  }

  double get seconds {
    switch (_timeUnit) {
      case TimeUnit.minutes:
        return _time * 60;
      case TimeUnit.hours:
        return _time * 60 * 60;
      case TimeUnit.days:
        return _time * 60 * 60 * 24;
      default:
        throw 'Invalid time unit: $_timeUnit';
    }
  }

  void reset() {
    _pH = 8.0;
    _tC = 25;
    _alk = 150;
    _toc = 0;
    _tocFastFrac = 0.02;
    _tocSlowFrac = 0.65;
    _timeUnit = TimeUnit.hours;
    _time = 2.0;
  }

  void setpH(double pH) {
    _pH = pH;
    notifyListeners();
  }

  void setAlkalinity(double alk) {
    _alk = alk;
    notifyListeners();
  }

  void setTemperature(double tC) {
    _tC = tC;
    notifyListeners();
  }

  void setTOC(double toc) {
    _toc = toc;
    notifyListeners();
  }

  void setTOCFastFrac(double fastFrac) {
    _tocFastFrac = fastFrac;
    notifyListeners();
  }

  void setTOCSlowFrac(double slowFrac) {
    _tocSlowFrac = slowFrac;
    notifyListeners();
  }

  void setTimeUnit(TimeUnit timeUnit) {
    if (_time > timeUnit.max) {
      _time = timeUnit.max;
    }
    if (_time < timeUnit.min) {
      _time = timeUnit.min;
    }
    _timeUnit = timeUnit;
    notifyListeners();
  }

  void setTime(double time) {
    _time = time;
    notifyListeners();
  }

  @override
  String toString() {
    return """
    Parameters{
      pH =>\t$_pH
      tC =>\t$_tC
      alk =>\t$_alk
      toc =>\t$_toc
      tocFast =>\t$_tocFastFrac
      tocSlow =>\t$_tocSlowFrac
      seconds =>\t$seconds
    }""";
  }
}
