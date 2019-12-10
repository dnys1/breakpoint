import 'package:flutter/material.dart';

enum ScenarioType {
  BreakpointCurve,
  FormationDecay,
}

enum ChemAdditionScenario {
  SimultaneousAddition,
  PreformedChloramines,
  BoosterChlorination,
}

enum FreeChlorineAdditionMthd {
  KnownConcentration,
  GasFeed,
  LiquidFeed,
}

enum FreeAmmoniaAdditionMthd {
  KnownConcentration,
  ChlorineToNitrogenRatio,
  GasFeed,
  LiquidFeed,
}

enum FixedConcentrationChem {
  FreeChlorine,
  FreeAmmonia,
}

class Scenario with ChangeNotifier {
  ScenarioType _scenarioType = ScenarioType.FormationDecay;
  ChemAdditionScenario _scenario = ChemAdditionScenario.SimultaneousAddition;
  FreeChlorineAdditionMthd _freeChlorineAdditionMthd =
      FreeChlorineAdditionMthd.KnownConcentration;
  FreeAmmoniaAdditionMthd _freeAmmoniaAdditionMthd =
      FreeAmmoniaAdditionMthd.KnownConcentration;
  FixedConcentrationChem _fixedConcentrationChem =
      FixedConcentrationChem.FreeAmmonia;

  double _freeChlorineConc = 4.0;
  double _freeAmmoniaConc = 1.0;
  double _monochloramineConc = 4.0;
  double _dichloramineConc = 0.0;
  double _liquidChlorineStrength = 50.0;
  double _liquidAmmoniaStrength = 50.0;
  double _plantFlowMGD = 2.0;

  ScenarioType get scenarioType => _scenarioType;
  ChemAdditionScenario get scenario => _scenario;
  FreeChlorineAdditionMthd get freeChlorineAdditionMthd =>
      _freeChlorineAdditionMthd;
  FreeAmmoniaAdditionMthd get freeAmmoniaAdditionMthd =>
      _freeAmmoniaAdditionMthd;
  FixedConcentrationChem get fixedConcentrationChem => _fixedConcentrationChem;
  double get freeChlorineConc => _freeChlorineConc;
  double get freeAmmoniaConc => _freeAmmoniaConc;
  double get monochloramineConc => _monochloramineConc;
  double get dichloramineConc => _dichloramineConc;
  double get liquidChlorineStrength => _liquidChlorineStrength;
  double get liquidAmmoniaStrength => _liquidAmmoniaStrength;
  double get plantFlowMGD => _plantFlowMGD;

  bool get shouldShowPlantFlowInput =>
      _freeAmmoniaAdditionMthd == FreeAmmoniaAdditionMthd.LiquidFeed ||
      _freeAmmoniaAdditionMthd == FreeAmmoniaAdditionMthd.GasFeed ||
      _freeChlorineAdditionMthd == FreeChlorineAdditionMthd.GasFeed ||
      _freeChlorineAdditionMthd == FreeChlorineAdditionMthd.LiquidFeed;

  String get scenarioTypeText {
    switch (_scenarioType) {
      case ScenarioType.BreakpointCurve:
        return 'Breakpoint Curve';
      case ScenarioType.FormationDecay:
        return 'Formation/Decay';
    }

    return null;
  }

  String get scenarioText {
    switch (_scenario) {
      case ChemAdditionScenario.SimultaneousAddition:
        return 'Simultaneous Addition';
      case ChemAdditionScenario.PreformedChloramines:
        return 'Preformed Chloramines';
      case ChemAdditionScenario.BoosterChlorination:
        return 'Booster Chlorination';
    }

    return null;
  }

  String get freeChlorineAdditionMthdText {
    switch (_freeChlorineAdditionMthd) {
      case FreeChlorineAdditionMthd.KnownConcentration:
        return 'Known Concentration';
      case FreeChlorineAdditionMthd.GasFeed:
        return 'Gas Feed';
      case FreeChlorineAdditionMthd.LiquidFeed:
        return 'Liquid Feed';
      default:
        throw 'Free Chlorine Addition Method cannot be null';
    }
  }

  String get freeAmmoniaAdditionMthdText {
    switch (_freeAmmoniaAdditionMthd) {
      case FreeAmmoniaAdditionMthd.KnownConcentration:
        return 'Known Concentration';
      case FreeAmmoniaAdditionMthd.GasFeed:
        return 'Gas Feed';
      case FreeAmmoniaAdditionMthd.LiquidFeed:
        return 'Liquid Feed';
      case FreeAmmoniaAdditionMthd.ChlorineToNitrogenRatio:
        return 'Chlorine To Nitrogen Ratio';
      default:
        throw 'Free Ammonia Addition Method cannot be null';
    }
  }

  String get fixedConcentrationChemText {
    switch (_fixedConcentrationChem) {
      case FixedConcentrationChem.FreeChlorine:
        return 'Free Chlorine';
      case FixedConcentrationChem.FreeAmmonia:
        return 'Free Ammonia';
      default:
        throw 'Fixed concentration chemical cannot be null';
    }
  }

  void setInitialValues() {
    switch (_scenarioType) {
      case ScenarioType.BreakpointCurve:
        _freeAmmoniaConc = 1.0;
        _freeChlorineConc = 1.0;
        break;
      case ScenarioType.FormationDecay:
        switch (scenario) {
          case ChemAdditionScenario.SimultaneousAddition:
            _freeAmmoniaConc = 1.0;
            _freeChlorineConc = 4.0;
            _liquidChlorineStrength = 50.0;
            _liquidAmmoniaStrength = 50.0;
            _plantFlowMGD = 2.0;
            break;
          case ChemAdditionScenario.PreformedChloramines:
            _freeAmmoniaConc = 0.1;
            _monochloramineConc = 4.0;
            _dichloramineConc = 0.0;
            break;
          case ChemAdditionScenario.BoosterChlorination:
            _freeChlorineConc = 2.0;
            _freeAmmoniaConc = 0.5;
            _monochloramineConc = 2.0;
            _dichloramineConc = 0.0;
            break;
        }
        break;
    }
    notifyListeners();
  }

  void resetAll() {
    _scenario = ChemAdditionScenario.SimultaneousAddition;
    _freeAmmoniaAdditionMthd = FreeAmmoniaAdditionMthd.KnownConcentration;
    _freeChlorineAdditionMthd = FreeChlorineAdditionMthd.KnownConcentration;
    setInitialValues();
  }

  void setScenarioType(ScenarioType scenarioType) {
    _scenarioType = scenarioType;
    setInitialValues();
    notifyListeners();
  }

  void setScenario(ChemAdditionScenario scenario) {
    _scenario = scenario;
    setInitialValues();
    notifyListeners();
  }

  void setFreeAmmoniaAdditionMethod(FreeAmmoniaAdditionMthd method) {
    _freeAmmoniaAdditionMthd = method;
    switch (method) {
      case FreeAmmoniaAdditionMthd.KnownConcentration:
        _freeAmmoniaConc = 1.0;
        break;
      case FreeAmmoniaAdditionMthd.ChlorineToNitrogenRatio:
        _freeAmmoniaConc = 4;
        break;
      case FreeAmmoniaAdditionMthd.GasFeed:
        _freeAmmoniaConc = 15;
        break;
      case FreeAmmoniaAdditionMthd.LiquidFeed:
        _freeAmmoniaConc = 15;
        break;
    }
    notifyListeners();
  }

  void setFreeChlorineAdditionMethod(FreeChlorineAdditionMthd method) {
    _freeChlorineAdditionMthd = method;
    switch (method) {
      case FreeChlorineAdditionMthd.KnownConcentration:
        _freeChlorineConc = 4.0;
        break;
      case FreeChlorineAdditionMthd.GasFeed:
        _freeChlorineConc = 100;
        break;
      case FreeChlorineAdditionMthd.LiquidFeed:
        _freeChlorineConc = 100;
        break;
    }
    notifyListeners();
  }

  void setFixedConcentrationChem(FixedConcentrationChem fcc) {
    _fixedConcentrationChem = fcc;
    switch (_fixedConcentrationChem) {
      case FixedConcentrationChem.FreeChlorine:
        _freeChlorineConc = _freeAmmoniaConc;
        break;
      case FixedConcentrationChem.FreeAmmonia:
        _freeAmmoniaConc = _freeChlorineConc;
        break;
    }
    notifyListeners();
  }

  void setFreeChlorineConc(double conc) {
    _freeChlorineConc = conc;
    notifyListeners();
  }

  void setFreeAmmoniaConc(double conc) {
    _freeAmmoniaConc = conc;
    notifyListeners();
  }

  void setMonochloramineConc(double conc) {
    _monochloramineConc = conc;
    notifyListeners();
  }

  void setDichloramineConc(double conc) {
    _dichloramineConc = conc;
    notifyListeners();
  }

  void setLiquidChlorineStrength(double strength) {
    if (strength >= 0 && strength <= 100) {
      _liquidChlorineStrength = strength;
      notifyListeners();
    }
  }

  void setLiquidAmmoniaStrength(double strength) {
    if (strength >= 0 && strength <= 100) {
      _liquidAmmoniaStrength = strength;
      notifyListeners();
    }
  }

  void setPlantFlow(double flowMGD) {
    if (flowMGD >= 0) {
      _plantFlowMGD = flowMGD;
      notifyListeners();
    }
  }
}
