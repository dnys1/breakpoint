import 'package:flutter/material.dart';

class FocusNodeProvider with ChangeNotifier {
  FocusNode _currentFocusNode;

  FocusNode get currentFocusNode => _currentFocusNode;

  setCurrentFocusNode(FocusNode newNode) {
    _currentFocusNode = newNode;
    notifyListeners();
  }
}