import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeProvider() {
    _isDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  }

  void setDarkMode(bool isDark) {
    _isDark = isDark;
    notifyListeners();
  }
}