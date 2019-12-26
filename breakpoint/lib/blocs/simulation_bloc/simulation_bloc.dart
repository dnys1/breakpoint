import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:breakpoint/models/models.dart';
import './bloc.dart';

class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  @override
  SimulationState get initialState => Initial();

  @override
  Stream<SimulationState> mapEventToState(
    SimulationEvent event,
  ) async* {
    if (event is RunSimulation) {
      try {
        yield* _mapRunSimulationToState(event.scenario, event.params);
      } on Exception catch (e) {
        yield SimulationFailure(e.toString());
      }
    }
  }

  Stream<SimulationState> _mapRunSimulationToState(
      Scenario scenario, Parameters params) async* {
    yield SimulationRunning(0.0);

    assert(params?.pH != null);
    assert(params?.tC != null);
    assert(params?.alk != null);
    assert(params?.toc != null);
    assert(params?.tocFastFrac != null);
    assert(params?.tocSlowFrac != null);

    Results results;

    SimulationWorker worker = SimulationWorker();
    await worker.isReady;

    bool success = true;

    switch (scenario.scenarioType) {
      case ScenarioType.BreakpointCurve:
        results = BreakpointCurveResults(
          TimeUnit.ratio,
          fixedConcentrationChem: scenario.fixedConcentrationChem,
        );

        // Simulate for Cl2:N ratios between 0 and 15
        double minutes = 240;
        double ratioStep = 0.2;
        double ratioMin = 0;
        double ratioMax = 15;

        List<double> ratios = [];
        List<double> _totCl = [];
        List<double> _totNH = [];
        switch (scenario.fixedConcentrationChem) {
          case FixedConcentrationChem.FreeChlorine:
            for (double i = 1; i <= ratioMax; i += ratioStep) {
              ratios.add(i);
              _totNH.add(scenario.freeChlorineConc / i / 14000);
            }
            _totCl =
                List.filled(ratios.length, scenario.freeChlorineConc / 71000);
            break;
          case FixedConcentrationChem.FreeAmmonia:
            for (double i = ratioMin; i <= ratioMax; i += ratioStep) {
              ratios.add(i);
              _totCl.add(i * scenario.freeAmmoniaConc / 71000);
            }
            _totNH =
                List.filled(ratios.length, scenario.freeAmmoniaConc / 14000);
            break;
        }

        for (int i = 0; i < ratios.length; i++) {
          try {
            final String csv = await worker.simulate([
              params.pH,
              params.tC,
              params.alk,
              _totNH[i],
              _totCl[i],
              0,
              0,
              0,
              0,
              minutes * 60,
            ]);

            results.addResult(csv, ratio: ratios[i]);
          } on Exception catch (e) {
            yield SimulationFailure(e.toString());
            success = false;
          }

          yield SimulationRunning(i / ratios.length);
        }
        
        break;
      case ScenarioType.FormationDecay:
        results = FormationDecayResults(params.timeUnit);

        double _totNH;
        double _totCl;
        double _nh2cl = 0.0;
        double _nhcl2 = 0.0;
        double _doc1 = 0.0;
        double _doc2 = 0.0;

        switch (scenario.scenario) {
          case ChemAdditionScenario.SimultaneousAddition:
            switch (scenario.freeAmmoniaAdditionMthd) {
              case FreeAmmoniaAdditionMthd.KnownConcentration:
                _totNH = scenario.freeAmmoniaConc;
                break;
              case FreeAmmoniaAdditionMthd.ChlorineToNitrogenRatio:
                double massRatio = scenario.freeAmmoniaConc;
                _totNH = scenario.freeChlorineConc / massRatio;
                break;
              case FreeAmmoniaAdditionMthd.GasFeed:
                _totNH = scenario.freeAmmoniaConc /
                    (scenario.plantFlowMGD * 8.34) *
                    (14 / 17);
                break;
              case FreeAmmoniaAdditionMthd.LiquidFeed:
                _totNH = scenario.freeAmmoniaConc *
                    (scenario.liquidAmmoniaStrength / 100) /
                    (scenario.plantFlowMGD * 8.34) *
                    (14 / 17);
                break;
            }
            switch (scenario.freeChlorineAdditionMthd) {
              case FreeChlorineAdditionMthd.KnownConcentration:
                _totCl = scenario.freeChlorineConc;
                break;
              case FreeChlorineAdditionMthd.GasFeed:
                _totCl =
                    scenario.freeChlorineConc / (scenario.plantFlowMGD * 8.34);
                break;
              case FreeChlorineAdditionMthd.LiquidFeed:
                _totCl = scenario.freeChlorineConc *
                    (scenario.liquidChlorineStrength / 100) /
                    (scenario.plantFlowMGD * 8.34);
                break;
            }
            break;
          case ChemAdditionScenario.PreformedChloramines:
            _totNH = scenario.freeAmmoniaConc;
            _totCl = 0;
            _nh2cl = scenario.monochloramineConc;
            _nhcl2 = scenario.dichloramineConc;
            break;
          case ChemAdditionScenario.BoosterChlorination:
            _totCl = scenario.freeChlorineConc;
            _totNH = scenario.freeAmmoniaConc;
            _nh2cl = scenario.monochloramineConc;
            _nhcl2 = scenario.dichloramineConc;
            break;
        }

        // Convert mg/L to mol/L
        _totNH /= 14000;
        _totCl /= 71000;
        _nh2cl /= 71000;
        _nhcl2 /= 71000 * 2;

        // Calculate DOC1 & DOC2 by fast/slow fractions
        // Convert mg/L to mol/L
        _doc1 = params.toc * params.tocFastFrac / 12000;
        _doc2 = params.toc * params.tocSlowFrac / 12000;

        try {
          String csv = await worker.simulate([
            params.pH,
            params.tC,
            params.alk,
            _totNH,
            _totCl,
            _nh2cl,
            _nhcl2,
            _doc1,
            _doc2,
            params.seconds,
          ]);

          results.addResult(csv);
        } on Exception catch (e) {
          yield SimulationFailure(e.toString());
          success = false;
        }

        break;
    }

    worker.dispose();

    if (success) {
      yield ResultsLoaded(results);
    }
  }
}
