import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';

class NativeSim {
  static final DynamicLibrary nativeSimLib = 
  Platform.isAndroid 
    ? DynamicLibrary.open('libnative_sim.so')
    : DynamicLibrary.open('native_sim.framework/native_sim');

  static const MethodChannel _channel =
      const MethodChannel('native_sim');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
