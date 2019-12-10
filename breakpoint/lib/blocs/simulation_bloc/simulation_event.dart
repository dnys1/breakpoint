import 'package:breakpoint/models/models.dart';
import 'package:equatable/equatable.dart';

abstract class SimulationEvent extends Equatable {
  const SimulationEvent();

  @override
  List<Object> get props => [];
}

class RunSimulation extends SimulationEvent {
  final Scenario scenario;
  final Parameters params;

  const RunSimulation(this.scenario, this.params);

  @override
  List<Object> get props => [scenario, params];
}