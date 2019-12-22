import 'package:breakpoint/models/models.dart';
import 'package:breakpoint/widgets/input/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

extension Capitalize on String {
  String capitalize() {
    List<String> parts = this.split(' ');
    parts.forEach((p) => p = p[0].toUpperCase() + p.substring(1).toLowerCase());
    return parts.join(' ');
  }
}

bool isBreakpointCurve(BuildContext context) =>
    Provider.of<Scenario>(context).scenarioType == ScenarioType.BreakpointCurve;

bool isFormationDecay(BuildContext context) =>
    Provider.of<Scenario>(context).scenarioType == ScenarioType.FormationDecay;

Future<dynamic> getActionSheetResult(BuildContext context, String title,
    String message, Map<String, dynamic> options) async {
  List<Widget> actions = [];
  for (String key in options.keys) {
    actions.add(CupertinoActionSheetAction(
      child: Text(key),
      onPressed: () => Navigator.of(context).pop(options[key]),
    ));
  }
  return await showCupertinoModalPopup(
    context: context,
    builder: (_) => CupertinoActionSheet(
      title: Text(title),
      message: Text(message),
      actions: actions,
    ),
    useRootNavigator: false,
  );
}

Widget getWaterQualityInputs(BuildContext context) {
  return Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: DynamicText('Water Quality', type: TextType.header),
      ),
      SliderOnly(
        title: 'pH',
        value: Provider.of<Parameters>(context).pH,
        onChanged: Provider.of<Parameters>(context).setpH,
        min: 6,
        max: 9,
        delta: 0.05,
        displayDigits: 2,
      ),
      SliderOnly(
        title: 'Total Alkalinity (mg/L as ${ScriptSet.caco3})',
        value: Provider.of<Parameters>(context).alk,
        onChanged: Provider.of<Parameters>(context).setAlkalinity,
        min: 0,
        max: 500,
        delta: 5,
        displayDigits: 0,
      ),
      SliderOnly(
        title: 'Water Temperature (${ScriptSet.deg}C)',
        value: Provider.of<Parameters>(context).tC,
        onChanged: Provider.of<Parameters>(context).setTemperature,
        min: 5,
        max: 35,
        delta: 0.5,
        displayDigits: 1,
      ),
    ],
  );
}

class ScriptSet {
  String subscript;
  String superscript;

  ScriptSet(this.superscript, this.subscript);

  static final String cl2 = 'Cl${scriptMap['2'].subscript}';
  static final String nh3 = 'NH${scriptMap['3'].subscript}';
  static final String caco3 = 'CaCO${scriptMap['3'].subscript}';
  static final String deg = scriptMap['o'].superscript;
}

Map<String, ScriptSet> scriptMap = {
  '0': ScriptSet('\u2070', '\u2080'),
  '1': ScriptSet('\u00B9', '\u2081'),
  '2': ScriptSet('\u00B2', '\u2082'),
  '3': ScriptSet('\u00B3', '\u2083'),
  '4': ScriptSet('\u2074', '\u2084'),
  '5': ScriptSet('\u2075', '\u2085'),
  '6': ScriptSet('\u2076', '\u2086'),
  '7': ScriptSet('\u2077', '\u2087'),
  '8': ScriptSet('\u2078', '\u2088'),
  '9': ScriptSet('\u2079', '\u2089'),
  'a': ScriptSet('\u1d43', '\u2090'),
  'b': ScriptSet('\u1d47', '?'),
  'c': ScriptSet('\u1d9c', '?'),
  'd': ScriptSet('\u1d48', '?'),
  'e': ScriptSet('\u1d49', '\u2091'),
  'f': ScriptSet('\u1da0', '?'),
  'g': ScriptSet('\u1d4d', '?'),
  'h': ScriptSet('\u02b0', '\u2095'),
  'i': ScriptSet('\u2071', '\u1d62'),
  'j': ScriptSet('\u02b2', '\u2c7c'),
  'k': ScriptSet('\u1d4f', '\u2096'),
  'l': ScriptSet('\u02e1', '\u2097'),
  'm': ScriptSet('\u1d50', '\u2098'),
  'n': ScriptSet('\u207f', '\u2099'),
  'o': ScriptSet('\u1d52', '\u2092'),
  'p': ScriptSet('\u1d56', '\u209a'),
  'q': ScriptSet('?', '?'),
  'r': ScriptSet('\u02b3', '\u1d63'),
  's': ScriptSet('\u02e2', '\u209b'),
  't': ScriptSet('\u1d57', '\u209c'),
  'u': ScriptSet('\u1d58', '\u1d64'),
  'v': ScriptSet('\u1d5b', '\u1d65'),
  'w': ScriptSet('\u02b7', '?'),
  'x': ScriptSet('\u02e3', '\u2093'),
  'y': ScriptSet('\u02b8', '?'),
  'z': ScriptSet('?', '?'),
  'A': ScriptSet('\u1d2c', '?'),
  'B': ScriptSet('\u1d2e', '?'),
  'C': ScriptSet('?', '?'),
  'D': ScriptSet('\u1d30', '?'),
  'E': ScriptSet('\u1d31', '?'),
  'F': ScriptSet('?', '?'),
  'G': ScriptSet('\u1d33', '?'),
  'H': ScriptSet('\u1d34', '?'),
  'I': ScriptSet('\u1d35', '?'),
  'J': ScriptSet('\u1d36', '?'),
  'K': ScriptSet('\u1d37', '?'),
  'L': ScriptSet('\u1d38', '?'),
  'M': ScriptSet('\u1d39', '?'),
  'N': ScriptSet('\u1d3a', '?'),
  'O': ScriptSet('\u1d3c', '?'),
  'P': ScriptSet('\u1d3e', '?'),
  'Q': ScriptSet('?', '?'),
  'R': ScriptSet('\u1d3f', '?'),
  'S': ScriptSet('?', '?'),
  'T': ScriptSet('\u1d40', '?'),
  'U': ScriptSet('\u1d41', '?'),
  'V': ScriptSet('\u2c7d', '?'),
  'W': ScriptSet('\u1d42', '?'),
  'X': ScriptSet('?', '?'),
  'Y': ScriptSet('?', '?'),
  'Z': ScriptSet('?', '?'),
  '+': ScriptSet('\u207A', '\u208A'),
  '-': ScriptSet('\u207B', '\u208B'),
  '=': ScriptSet('\u207C', '\u208C'),
  '(': ScriptSet('\u207D', '\u208D'),
  ')': ScriptSet('\u207E', '\u208E'),
  ':alpha': ScriptSet('\u1d45', '?'),
  ':beta': ScriptSet('\u1d5d', '\u1d66'),
  ':gamma': ScriptSet('\u1d5e', '\u1d67'),
  ':delta': ScriptSet('\u1d5f', '?'),
  ':epsilon': ScriptSet('\u1d4b', '?'),
  ':theta': ScriptSet('\u1dbf', '?'),
  ':iota': ScriptSet('\u1da5', '?'),
  ':pho': ScriptSet('?', '\u1d68'),
  ':phi': ScriptSet('\u1db2', '?'),
  ':psi': ScriptSet('\u1d60', '\u1d69'),
  ':chi': ScriptSet('\u1d61', '\u1d6a'),
  ':coffee': ScriptSet('\u2615', '\u2615')
};
