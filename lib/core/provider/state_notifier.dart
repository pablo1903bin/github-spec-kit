import 'package:flutter/material.dart';

abstract class StateNotifier<T> extends ChangeNotifier {
  
  T _state, _oldState;
  bool _mounted = true;

  T get state => _state;
  T get oldState => _oldState;
  bool get mounted => _mounted;

  StateNotifier(this._state) : _oldState = _state;

  void changeState(T state) {
    notifica(state, notificar: false);
  }

  void notifica(T state, {bool notificar = true, bool forzar = false}) {
    if (forzar == false && state == _state) {
      return;
    }

    _oldState = _state;
    _state = state;
    if (notificar) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
