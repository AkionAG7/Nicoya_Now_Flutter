import 'package:flutter/material.dart';

class DeliveryState extends ChangeNotifier {
  int _currentStep = 1;
  int get currentStep => _currentStep;

  void avanzarPaso() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void reiniciar() {
    _currentStep = 1;
    notifyListeners();
  }
}
