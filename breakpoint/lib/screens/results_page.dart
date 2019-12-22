import 'dart:io';

import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:breakpoint/widgets/platform/platform.dart';
import 'package:breakpoint/widgets/page_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart' hide Slider;
import 'package:flutter/material.dart' as material show Slider;
import 'package:charts_flutter/flutter.dart' hide Color;
import 'package:charts_common/common.dart' as charts;

import '../blocs/simulation_bloc/bloc.dart';
import '../util.dart';

final Map<_Measures, String> measureDisplayNames = {
  _Measures.TotalChlorine: 'Total Chlorine',
  _Measures.FreeAmmonia: 'Free Ammonia',
  _Measures.FreeChlorine: 'Free Chlorine',
  _Measures.Monochloramine: 'Monochloramine',
  _Measures.Dichloramine: 'Dichloramine',
  _Measures.Trichloramine: 'Trichloramine',
};

final Map<_Measures, Color> measureColors = {
  _Measures.TotalChlorine: Colors.blue,
  _Measures.FreeChlorine: Colors.green,
  _Measures.FreeAmmonia: Colors.grey,
  _Measures.Monochloramine: Colors.pink,
  _Measures.Dichloramine: Colors.purple,
  _Measures.Trichloramine: Colors.deepOrange,
};

final Map<_Measures, charts.Color> measureChartColors = {
  _Measures.TotalChlorine: MaterialPalette.blue.shadeDefault,
  _Measures.FreeChlorine: MaterialPalette.green.shadeDefault,
  _Measures.FreeAmmonia: MaterialPalette.gray.shadeDefault,
  _Measures.Monochloramine: MaterialPalette.pink.shadeDefault,
  _Measures.Dichloramine: MaterialPalette.purple.shadeDefault,
  _Measures.Trichloramine: MaterialPalette.deepOrange.shadeDefault,
};

class ResultsPage extends StatefulWidget {
  ResultsPage({Key key}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  ScrollController _controller = PageController(keepPage: false);
  int _page = 0;

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
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewInsets.bottom -
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 140
                              : Platform.isAndroid ? 130 : 85),
                      child: PageView(
                        controller: _controller,
                        children: <Widget>[ResultsChart(), ResultsTable()],
                        onPageChanged: (page) => setState(() => _page = page),
                      ),
                    ),
                    Positioned(
                      bottom: Platform.isAndroid ? 20 : 0,
                      left: 0,
                      right: 0,
                      child: PageIndicator(
                        page: _page.toDouble(),
                        itemCount: 2,
                        color: CupertinoColors.inactiveGray,
                        onPageSelected: (_) {},
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text('Something went wrong. Please try again.'),
              );
            }
          },
        ),
      ),
      trailing: PlatformButton(
        padding: const EdgeInsets.all(2.0),
        child: Icon(
          Platform.isAndroid ? Icons.info_outline : CupertinoIcons.info,
          color: Platform.isAndroid ? Colors.white : null,
        ),
        onPressed: () {
          String helpText =
              'Click on the chart to select points.\n\nClick on items in the legend to turn on/off certain series.\n\nSwipe right to see a table of values.';
          Platform.isAndroid
              ? showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: DynamicText(
                          helpText,
                          type: TextType.subhead,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                )
              : showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        )
                      ],
                      content: Center(
                        child: DynamicText(
                          helpText,
                          type: TextType.subhead,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                );
        },
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

  double _selectedDomain;
  Map<_Measures, bool> _showMeasure = Map<_Measures, bool>.fromIterable(
    _Measures.values,
    key: (m) => m,
    value: (_) => true,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    results = Provider.of<Results>(context);
  }

  Widget get bottomLabel {
    TextStyle style = Platform.isAndroid
        ? DefaultTextStyle.of(context).style
        : CupertinoTheme.of(context)
            .textTheme
            .textStyle
            .copyWith(fontSize: 15.0);

    String label, val;
    if (results is BreakpointCurveResults) {
      label = 'Selected Ratio: ';
      val = _selectedDomain.toStringAsFixed(1);
    } else {
      label = 'Selected Time: ';
      val = _selectedDomain
              .toStringAsFixed(results.timeScale == TimeUnit.hours ? 1 : 0) +
          ' ${results.timeScale.string.toLowerCase()}';
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: label),
          TextSpan(
            text: val,
            style: style.copyWith(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  TextStyleSpec get darkStyleSpec =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TextStyleSpec(
              color: MaterialPalette.white,
            )
          : null;

  TextStyleSpec get darkStyleSpecSmall =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TextStyleSpec(
              color: MaterialPalette.white,
              fontSize: 16,
            )
          : TextStyleSpec(
              fontSize: 16,
            );

  String get xAxisTitle => results.timeScale.xAxisTitle;

  String get yAxisTitle => 'Parameter (mg/L)';

  List<Series<ChartResult, double>> get chartSeries {
    List<Series<ChartResult, double>> series = [];
    if (_showMeasure[_Measures.TotalChlorine]) {
      series.add(Series<ChartResult, double>(
        id: 'Total Chlorine',
        colorFn: (_, __) => measureChartColors[_Measures.TotalChlorine],
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / results.timeScale.scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.totCl,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.FreeChlorine]) {
      series.add(Series<ChartResult, double>(
        id: 'Free Chlorine',
        colorFn: (_, __) => measureChartColors[_Measures.FreeChlorine],
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / results.timeScale.scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.freeCl,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.FreeAmmonia]) {
      series.add(Series<ChartResult, double>(
        id: 'Free Ammonia',
        colorFn: (_, __) => measureChartColors[_Measures.FreeAmmonia],
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / results.timeScale.scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.totNH,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.Monochloramine]) {
      series.add(Series<ChartResult, double>(
        id: 'Monochloramine',
        colorFn: (_, __) => measureChartColors[_Measures.Monochloramine],
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / results.timeScale.scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.nh2cl,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.Dichloramine]) {
      series.add(Series<ChartResult, double>(
        id: 'Dichloramine',
        colorFn: (_, __) => measureChartColors[_Measures.Dichloramine],
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / results.timeScale.scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.nhcl2,
        data: results.chartResults,
      ));
    }
    if (_showMeasure[_Measures.Trichloramine]) {
      series.add(Series<ChartResult, double>(
        id: 'Trichloramine',
        colorFn: (_, __) => measureChartColors[_Measures.Trichloramine],
        domainFn: (ChartResult thisResult, _) =>
            results is FormationDecayResults
                ? thisResult.t / results.timeScale.scaleFactor
                : thisResult.ratio,
        measureFn: (ChartResult thisResult, _) => thisResult.ncl3,
        data: results.chartResults,
      ));
    }
    return series;
  }

  bool get freeChlorineOverride =>
      results is BreakpointCurveResults &&
      Provider.of<Scenario>(context).fixedConcentrationChem ==
          FixedConcentrationChem.FreeChlorine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: LineChart(
        chartSeries,
        animate: true,
        primaryMeasureAxis: NumericAxisSpec(
          renderSpec: GridlineRendererSpec(
            labelStyle: darkStyleSpec,
            lineStyle:
                MediaQuery.platformBrightnessOf(context) == Brightness.dark
                    ? LineStyleSpec(
                        color: MaterialPalette.white,
                      )
                    : null,
          ),
          tickFormatterSpec: BasicNumericTickFormatterSpec(
            (number) => freeChlorineOverride && number == 0
                ? ''
                : number.toStringAsFixed(0),
          ),
        ),
        domainAxis: NumericAxisSpec(
          viewport: results is BreakpointCurveResults
              ? NumericExtents(
                  Provider.of<Scenario>(context).fixedConcentrationChem ==
                          FixedConcentrationChem.FreeAmmonia
                      ? 0.0
                      : 1.0,
                  15.0)
              : null,
          renderSpec: GridlineRendererSpec(
            labelStyle: darkStyleSpec,
          ),
        ),
        behaviors: [
          ChartTitle(
            xAxisTitle,
            behaviorPosition: BehaviorPosition.bottom,
            titleStyleSpec: darkStyleSpecSmall,
          ),
          ChartTitle(
            yAxisTitle,
            behaviorPosition: BehaviorPosition.start,
            outerPadding:
                Provider.of<Scenario>(context).fixedConcentrationChem ==
                        FixedConcentrationChem.FreeChlorine
                    ? 25
                    : null,
            titleOutsideJustification: OutsideJustification.middleDrawArea,
            titleStyleSpec: darkStyleSpecSmall,
          ),
          SeriesLegend(
            desiredMaxColumns:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? 2
                    : 3,
            entryTextStyle: darkStyleSpec,
            position: BehaviorPosition.bottom,
          ),
        ],
        // selectionModels: [
        //   SelectionModelConfig(
        //     type: SelectionModelType.action,
        //     changedListener: _onSelectionChanged,
        //   ),
        // ],
      ),
    );
  }
}

class _ResultsSlider extends StatelessWidget {
  final Results results;
  final Function(double) onChanged;
  final double value;

  _ResultsSlider({
    Key key,
    @required this.results,
    @required this.onChanged,
    @required this.value,
  }) : super(key: key);

  double min(BuildContext context) {
    Scenario scenario = Provider.of<Scenario>(context);
    if (scenario.scenarioType == ScenarioType.BreakpointCurve &&
        scenario.fixedConcentrationChem ==
            FixedConcentrationChem.FreeChlorine) {
      return 1;
    }
    return 0;
  }

  double max(BuildContext context) {
    if (isBreakpointCurve(context)) {
      return results.chartResults.last.ratio;
    } else {
      // print('Max t: ${results.chartResults.last.t}');
      return results.chartResults.last.t;
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(value);
    int numDigits = isBreakpointCurve(context) ? 1 : 2;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: DynamicText(
            '${results.timeScale.xAxisTitle}: ${(value / results.timeScale.scaleFactor).toStringAsFixed(numDigits)}',
            type: TextType.header,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Platform.isAndroid
              ? material.Slider(
                  value: value,
                  onChanged: onChanged,
                  min: min(context),
                  max: max(context),
                  divisions: 20,
                )
              : CupertinoSlider(
                  value: value,
                  onChanged: onChanged,
                  min: min(context),
                  max: max(context),
                  divisions: 20,
                ),
        ),
      ],
    );
  }
}

class ResultsTable extends StatefulWidget {
  ResultsTable({Key key}) : super(key: key);

  @override
  _ResultsTableState createState() => _ResultsTableState();
}

class _ResultsTableState extends State<ResultsTable> {
  Results results;
  int _selectedIndex = 0;
  double _selectedDomain;

  final _resultsSliderKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    results = Provider.of<Results>(context);
    if (isBreakpointCurve(context)) {
      _selectedDomain = results.chartResults.first.ratio;
    } else {
      _selectedDomain = results.chartResults.first.t;
    }
  }

  Widget _buildDataTable() {
    return Material(
      color: Colors.transparent,
      child: DataTable(
        columnSpacing: 20.0,
        columns: [
          DataColumn(
              label: DynamicText('Parameter', type: TextType.subhead),
              numeric: false),
          DataColumn(
              label: DynamicText('Value', type: TextType.subhead),
              numeric: true),
          DataColumn(
              label: DynamicText('Unit', type: TextType.subhead),
              numeric: false),
        ],
        rows: _Measures.values.map<DataRow>((_Measures measure) {
          final ChartResult selectedResult =
              results.chartResults[_selectedIndex];
          String unit = 'mg/L';
          double val;

          switch (measure) {
            case _Measures.FreeChlorine:
              unit = 'mg ${ScriptSet.cl2}/L';
              val = selectedResult.freeCl;
              break;
            case _Measures.TotalChlorine:
              unit = 'mg ${ScriptSet.cl2}/L';
              val = selectedResult.totCl;
              break;
            case _Measures.FreeAmmonia:
              unit = 'mg ${ScriptSet.nh3}-N/L';
              val = selectedResult.totNH;
              break;
            case _Measures.Monochloramine:
              unit = 'mg ${ScriptSet.cl2}/L';
              val = selectedResult.nh2cl;
              break;
            case _Measures.Dichloramine:
              unit = 'mg ${ScriptSet.cl2}/L';
              val = selectedResult.nhcl2;
              break;
            case _Measures.Trichloramine:
              unit = 'mg ${ScriptSet.cl2}/L';
              val = selectedResult.ncl3;
              break;
          }

          return DataRow(
            cells: [
              DataCell(Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 30.0,
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Divider(
                      color: measureColors[measure],
                      thickness: 2.0,
                    ),
                  ),
                  DynamicText(
                    measureDisplayNames[measure],
                    type: TextType.subhead,
                  ),
                ],
              )),
              DataCell(DynamicText(
                val.abs().toStringAsFixed(2),
                type: TextType.subhead,
              )),
              DataCell(DynamicText(
                unit,
                type: TextType.subhead,
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slider = _ResultsSlider(
      key: _resultsSliderKey,
      results: results,
      value: _selectedDomain,
      onChanged: (double val) {
        // print('New val: $val');
        setState(() {
          // print('New val: $val');
          _selectedIndex = results.listX.entries
              .singleWhere((MapEntry<num, int> entry) =>
                  (entry.key - val.roundToNearest(results.roundFactor)).abs() <
                  1e-5)
              .value;
          // print('New index: $_selectedIndex');
          if (isBreakpointCurve(context)) {
            _selectedDomain = results.chartResults[_selectedIndex].ratio;
          } else {
            _selectedDomain = results.chartResults[_selectedIndex].t;
          }
          // print('New domain: $_selectedDomain');
        });
      },
    );
    final table = SingleChildScrollView(
      child: _buildDataTable(),
    );
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: slider,
          ),
          table,
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: slider,
          ),
          table,
        ],
      );
    }
  }
}
