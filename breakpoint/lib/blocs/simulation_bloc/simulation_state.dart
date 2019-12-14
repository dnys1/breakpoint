import 'package:equatable/equatable.dart';

import 'package:breakpoint/models/results.dart';

abstract class SimulationState extends Equatable {
  const SimulationState();

  @override
  List<Object> get props => [];
}

class Initial extends SimulationState {}

class SimulationRunning extends SimulationState {
  final double percentComplete;

  const SimulationRunning(this.percentComplete);

  @override
  List<Object> get props => [percentComplete];

  @override
  String toString() => 'SimulationRunning { percentComplete: ${(percentComplete*100).toStringAsFixed(1)}% }';
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