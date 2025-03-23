import 'package:flutter/foundation.dart';
import '../models/ordonnance.dart';

class AppState extends ChangeNotifier {
  Ordonnance? _currentOrdonnance;
  final List<Ordonnance> _ordonnances = [];
  bool _isLoading = false;
  String? _error;

  Ordonnance? get currentOrdonnance => _currentOrdonnance;
  List<Ordonnance> get ordonnances => _ordonnances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCurrentOrdonnance(Ordonnance ordonnance) {
    _currentOrdonnance = ordonnance;
    notifyListeners();
  }

  void addOrdonnance(Ordonnance ordonnance) {
    _ordonnances.add(ordonnance);
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
