import 'package:breakpoint/models/scenario.dart';
import 'package:equatable/equatable.dart';

import 'package:breakpoint/models/results.dart';

abstract class SimulationState extends Equatable {
  const SimulationState();

  @override
  List<Object> get props => [];
}

class Initial extends SimulationState {}

class SimulationRunning extends SimulationState {
  final ScenarioType scenarioType;

  const SimulationRunning(this.scenarioType);

  @override
  List<Object> get props => [scenarioType];

  @override
  String toString() => 'SimulationRunning { type: ${scenarioType.toString().split('.')[1]}';
}

class ResultsLoaded extends SimulationState {
  final Results results;

  const ResultsLoaded(this.results);

  @override
  List<Object> get props => [results];

  @override
  String toString() => 'ResultsLoaded { $results }';
}

class SimulationFailure extends SimulationState {
  final String error;

  const SimulationFailure(this.error);

  @override
  List<Object> get props => [error];
}