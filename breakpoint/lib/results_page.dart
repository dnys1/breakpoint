import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/widgets/platform/platform.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'blocs/simulation_bloc/bloc.dart';
import 'util.dart';

class ResultsPage extends StatelessWidget {
  ResultsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      title: Text('Results'),
      body: SafeArea(
        child: BlocBuilder<SimulationBloc, SimulationState>(
          builder: (_, state) {
            if (state is ResultsLoaded) {
              return ChangeNotifierProvider<Results>.value(
                value: state.results,
                child: ResultsChart(),
              );
            } else {
              return Center(
                child: Text('Something went wrong. Please try again.'),
              );
            }
          },
        ),
      ),
    );
  }
}

class ResultsChart extends StatefulWidget {
  const ResultsChart({
    Key key,
  }) : super(key: key);

  @override
  _ResultsChartState createState() => _ResultsChartState();
}

enum _Measures {
  FreeChlorine,
  TotalChlorine,
  FreeAmmonia,
  Monochloramine,
  Dichloramine,
  Trichloramine
}

class _ResultsChartState extends State<ResultsChart> {
  Results results;

  double _selectedRatio;
  Map<_Measures, bool> _showMeasure = Map<_Measures, bool>.fromIterable(
    _Measures.values,
    key: (m) => m,
    value: (_) => true,
  );

  final Map<_Measures, String> measureDisplayNames = {
    _Measures.TotalChlorine: 'Total Chlorine',
    _Measures.FreeAmmonia: 'Free Ammonia',
    _Measures.FreeChlorine: 'Free Chlorine',
    _Measures.Monochloramine: 'Monochloramine',
    _Measures.Dichloramine: 'Dichloramine',
    _Measures.Trichloramine: 'Trichloramine',
  };

  void _onSelectionChanged(SelectionModel<num> model) {
    final selectedDatum = model.selectedDatum;

    double ratio;
    if (selectedDatum.isNotEmpty) {
      if (results is BreakpointCurveResults) {
        ratio = (selectedDatum.first.datum as ChartResult).ratio;
      } else {
        ratio = (selectedDatum.first.datum as ChartResult).t;
      }
    }

    setState(() {
      _selectedRatio = ratio;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    results = Provider.of<Results>(context);
  }

  Widget get bottomLabel {
    if (results is BreakpointCurveResults) {
      return DynamicText(
        'Selected Mass Ratio: ' + _selectedRatio.toStringAsFixed(1),
        type: TextType.subhead,
      );
    } else {
      return DynamicText(
        'Selected Time: ' +
            (_selectedRatio / _scaleFactor)
                .toStringAsFixed(results.timeScale == TimeUnit.hours ? 1 : 0) +
            ' ${getTimeUnit(results.timeScale).toLowerCase()}',
        type: TextType.subhead,
      );
    }
  }

  TextStyleSpec get darkStyleSpec =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TextStyleSpec(
              color: MaterialPalette.white,
            )
          : null;

  String getTimeUnit(TimeUnit unit) => unit.toString().split('.')[1];

  String get xAxisTitle {
    if (results.timeScale == TimeUnit.days ||
        results.timeScale == TimeUnit.hours ||
        results.timeScale == TimeUnit.minutes) {
      return 'Time (${getTimeUnit(results.timeScale)})';
    } else {
      return 'Initial Cl${scriptMap['2'].subscript}:N Mass Ratio (mg Cl${scriptMap['2'].subscript} : mg N)';
    }
  }

  int get _scaleFactor {
    switch (results.timeScale) {
      case TimeUnit.ratio:
        return 1;
      case TimeUnit.minutes:
        return 60;
      case TimeUnit.hours:
        return 60 * 60;
      case TimeUnit.days:
        return 60 * 60 * 24;
      default:
        throw ArgumentError('Time unit not recognized: ${results.timeScale}');
    }
  }

  List<Series<ChartResult, double>> get chartSeries {
    List<Series<ChartResult, double>> series = [];
    if (_showMeasure[_Measures.TotalChlorine]) {
      series.add(Series<ChartResult, double>(
        id: 'Total Chlorine',
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / _scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.totCl,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.FreeChlorine]) {
      series.add(Series<ChartResult, double>(
        id: 'Free Chlorine',
        colorFn: (_, __) => MaterialPalette.green.shadeDefault,
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / _scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.freeCl,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.FreeAmmonia]) {
      series.add(Series<ChartResult, double>(
        id: 'Free Ammonia',
        colorFn: (_, __) => MaterialPalette.gray.shadeDefault,
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / _scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.totNH,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.Monochloramine]) {
      series.add(Series<ChartResult, double>(
        id: 'Monochloramine',
        colorFn: (_, __) => MaterialPalette.pink.shadeDefault,
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / _scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.nh2cl,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.Dichloramine]) {
      series.add(Series<ChartResult, double>(
        id: 'Dichloramine',
        colorFn: (_, __) => MaterialPalette.purple.shadeDefault,
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / _scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.nhcl2,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.Trichloramine]) {
      series.add(Series<ChartResult, double>(
        id: 'Trichloramine',
        colorFn: (_, __) => MaterialPalette.deepOrange.shadeDefault,
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / _scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.ncl3,
        data: results.chartResults,
      ));
    }
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 10.0),
            height: MediaQuery.of(context).size.height / 2,
            child: LineChart(
              chartSeries,
              animate: true,
              primaryMeasureAxis: NumericAxisSpec(
                renderSpec: GridlineRendererSpec(
                  labelStyle: darkStyleSpec,
                  lineStyle: MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark
                      ? LineStyleSpec(
                          color: MaterialPalette.white,
                        )
                      : null,
                ),
              ),
              domainAxis: NumericAxisSpec(
                renderSpec: GridlineRendererSpec(
                  labelStyle: darkStyleSpec,
                ),
              ),
              behaviors: [
                ChartTitle(
                  xAxisTitle,
                  behaviorPosition: BehaviorPosition.bottom,
                  titleStyleSpec: darkStyleSpec,
                ),
                SeriesLegend(
                  desiredMaxColumns: 2,
                  entryTextStyle: darkStyleSpec,
                ),
              ],
              selectionModels: [
                SelectionModelConfig(
                  type: SelectionModelType.info,
                  changedListener: _onSelectionChanged,
                ),
              ],
            ),
          ),
          _selectedRatio == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: bottomLabel,
                ),
          _selectedRatio == null
              ? Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(
                    child: Text('Click the chart to select a point.'),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: DataTable(
                    columnSpacing: 30.0,
                    columns: [
                      DataColumn(label: DynamicText('Parameter', type: TextType.subhead), numeric: false),
                      DataColumn(label: DynamicText('Value', type: TextType.subhead), numeric: true),
                      DataColumn(label: DynamicText('Unit', type: TextType.subhead), numeric: false),
                      DataColumn(label: DynamicText('Show', type: TextType.subhead), numeric: false),
                    ],
                    rows: _Measures.values.map<DataRow>((_Measures measure) {
                      final ChartResult selectedResult =
                          results.chartResults.firstWhere((ChartResult res) {
                        if (results is BreakpointCurveResults) {
                          return res.ratio == _selectedRatio;
                        } else {
                          return res.t == _selectedRatio;
                        }
                      });
                      String unit = 'mg/L';
                      double val;

                      switch (measure) {
                        case _Measures.FreeChlorine:
                          unit = 'mg Cl${scriptMap['2'].subscript}/L';
                          val = selectedResult.freeCl;
                          break;
                        case _Measures.TotalChlorine:
                          unit = 'mg Cl${scriptMap['2'].subscript}/L';
                          val = selectedResult.totCl;
                          break;
                        case _Measures.FreeAmmonia:
                          unit = 'mg NH${scriptMap['3'].subscript}-N/L';
                          val = selectedResult.totNH;
                          break;
                        case _Measures.Monochloramine:
                          unit = 'mg Cl${scriptMap['2'].subscript}/L';
                          val = selectedResult.nh2cl;
                          break;
                        case _Measures.Dichloramine:
                          unit = 'mg Cl${scriptMap['2'].subscript}/L';
                          val = selectedResult.nhcl2;
                          break;
                        case _Measures.Trichloramine:
                          unit = 'mg Cl${scriptMap['2'].subscript}/L';
                          val = selectedResult.ncl3;
                          break;
                      }

                      return DataRow(
                        cells: [
                          DataCell(DynamicText(measureDisplayNames[measure], type: TextType.subhead)),
                          DataCell(DynamicText(val.abs().toStringAsFixed(2), type: TextType.subhead)),
                          DataCell(DynamicText(unit, type: TextType.subhead)),
                          DataCell(Checkbox(
                            value: _showMeasure[measure] ?? true,
                            autofocus: false,
                            tristate: false,
                            onChanged: (bool val) {
                              setState(() {
                                _showMeasure[measure] = val;
                              });
                            },
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
