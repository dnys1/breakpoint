# Breakpoint Simulator

<div align="center">
<img src="https://github.com/dnys1/breakpoint/blob/master/breakpoint/assets/icon.png?raw=true" height="256" width="256" />
<br />
<a href='https://play.google.com/store/apps/details?id=com.humbleme.breakpoint&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' width="200" src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'/></a>
<br />
<a href ="https://apps.apple.com/us/app/breakpoint-simulator/id1491638603?mt=8">
<img src="https://linkmaker.itunes.apple.com/en-us/badge-lrg.svg?releaseDate=2019-12-26&kind=iossoftware&bubble=ios_apps" width="175">
</a>
</div>

## Overview

Breakpoint Simulator is a program for simulating the formation and decay of chloramines in water as well as the breakpoint curve resulting from the interaction of chlorine and ammonia.

Developed based on the EPA tools [Batch (Plug Flow) Reactor Simulation of Drinking Water Chloramine Formation and Decay](https://shiny.epa.gov/cfd/) and [Chlorine Breakpoint Curve Simulator](https://shiny.epa.gov/cbcs/), Breakpoint Simulator will take a range of parameters including temperature, pH, alkalinity, total organic carbon (TOC), and chlorine and ammonia concentrations (or feed rates) to simulate the interaction and resultant speciation of chloramines. Results include values for free chlorine, total chlorine, mono-, di-, and trichloramine, as well as free ammonia over a specified time interval or over a fixed interval of Cl2:N mass ratios to develop a breakpoint curve.

## Flutter

Breakpoint Simulator is built using Flutter and uses the [`dart:ffi`](https://dart.dev/guides/libraries/c-interop) library to run the simulation using an external C++ library (boost). The code for the simulation is contained in the `native_sim` package, specifically the file [`native_sim/ios/Classes/native_sim.cpp`](https://github.com/dnys1/breakpoint/blob/master/native_sim/ios/Classes/native_sim.cpp) (see [this Flutter page](https://flutter.dev/docs/development/platform-integration/c-interop) for an overview of how to incorporate `dart:ffi` libs into Flutter apps).

The simulate function is declared in C\+\+.

```cpp
extern "C" __attribute__((visibility("default"))) __attribute__((used))
char* simulate
(
    double pH,
    double T_C,
    double Alk,
    double TotNH_ini,
    double TotCl_ini,
    double Mono_ini,
    double Di_ini,
    double DOC1_ini,
    double DOC2_ini,
    double tf
)
{
    ...
}
```

It's then loaded using the `dart:ffi` package.

```dart
import 'dart:ffi' as ffi;
import 'package:native_sim/native_sim.dart';

typedef sim_func = ffi.Pointer<Utf8> Function(
  ffi.Double pH,
  ffi.Double tC,
  ffi.Double alk,
  ffi.Double totNH0,
  ffi.Double totCl0,
  ffi.Double mono0,
  ffi.Double di0,
  ffi.Double doc10,
  ffi.Double doc20,
  ffi.Double tf,
);
typedef SimFunc = ffi.Pointer<Utf8> Function(
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
final SimFunc simulate = NativeSim.nativeSimLib
        .lookup<ffi.NativeFunction<sim_func>>('simulate')
        .asFunction<SimFunc>();
```

And can be run like a normal function would be.

```dart
final Pointer<Utf8> pointer = simulate(
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
```

## Getting Started

To get started, run the app using the following command:
```bash
cd breakpoint && flutter run
```

## Issues/Feedback

Please open an issue here if you notice anything I may have missed along the way, or shoot me an email at [humbleme@protonmail.com](mailto:humbleme@protonmail.com). Thank you!