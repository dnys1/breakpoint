import 'dart:io';

import 'package:breakpoint/blocs/bloc_delegate.dart';
import 'package:breakpoint/blocs/simulation_bloc/bloc.dart';
import 'package:breakpoint/models/theme.dart';
import 'package:breakpoint/screens/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';

import 'package:breakpoint/models/scenario.dart';
import 'package:breakpoint/models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Scenario()),
        ChangeNotifierProvider(create: (_) => Parameters()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SimulationBloc>(
            create: (_) => SimulationBloc(),
          ),
        ],
        child: BreakpointApp(),
      ),
    ),
  );
}

class BreakpointApp extends StatefulWidget {
  @override
  _BreakpointAppState createState() => _BreakpointAppState();
}

class _BreakpointAppState extends State<BreakpointApp>
    with WidgetsBindingObserver {
  final String title = "Breakpoint";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.window.platformBrightness;
    Provider.of<ThemeProvider>(context)
        .setDarkMode(brightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          textTheme: ThemeData.light().textTheme.copyWith(
                button: ThemeData.light().textTheme.button.copyWith(
                      color: Colors.white,
                    ),
              ),
        ),
        darkTheme: ThemeData.dark(),
        themeMode: Provider.of<ThemeProvider>(context).isDark
            ? ThemeMode.dark
            : ThemeMode.light,
        home: HomePage(title: 'Breakpoint Calculator'),
      );
    } else {
      return CupertinoApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          brightness: Provider.of<ThemeProvider>(context).isDark
              ? Brightness.dark
              : Brightness.light,
        ),
        home: HomePage(title: 'Breakpoint Calculator'),
      );
    }
  }
}