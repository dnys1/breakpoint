import 'dart:async';
import 'dart:isolate';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:native_sim/native_sim.dart';

typedef sim_func = Pointer<Utf8> Function(
  Double pH,
  Double tC,
  Double alk,
  Double totNH0,
  Double totCl0,
  Double mono0,
  Double di0,
  Double doc10,
  Double doc20,
  Double tf,
);
typedef SimFunc = Pointer<Utf8> Function(
  double pH,
  double tC,
  double alk,
  double totNH0,
  double totCl0,
  double mono0,
  double di0,
  double doc10,
  double doc20,
  double tf,
);

class SimulationWorker {
  SendPort _sendPort;

  Isolate _isolate;

  Completer<String> _results;

  final _isolateReady = Completer<void>();

  SimulationWorker() {
    init();
  }

  Future<void> get isReady => _isolateReady.future;

  void dispose() {
    _isolate.kill();
  }

  Future<void> init() async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    errorPort.listen(print);

    receivePort.listen(_handleMessage);
    _isolate = await Isolate.spawn(
      _isolateEntry,
      receivePort.sendPort,
      onError: errorPort.sendPort,
    );
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
      return;
    }

    if (message is String) {
      _results?.complete(message);
      _results = null;
      return;
    }
  }

  static void _isolateEntry(dynamic message) {
    SendPort sendPort;
    final receivePort = ReceivePort();

    final SimFunc simulate = NativeSim.nativeSimLib
        .lookup<NativeFunction<sim_func>>('simulate')
        .asFunction<SimFunc>();

    receivePort.listen((dynamic msg) {
      if (msg is List<double>) {
        assert (msg.length == 10);

        final Pointer<Utf8> csvPointer = simulate(
          msg[0],
          msg[1],
          msg[2],
          msg[3],
          msg[4],
          msg[5],
          msg[6],
          msg[7],
          msg[8],
          msg[9],
        );

        final String csv = Utf8.fromUtf8(csvPointer);

        sendPort.send(csv);
      }
    });

    if (message is SendPort) {
      sendPort = message;
      sendPort.send(receivePort.sendPort);
      return;
    }
  }

  Future<String> simulate(List<double> params) {
    _sendPort.send(params);

    _results = Completer<String>();
    return _results.future;
  }
}
