import 'package:flutter/foundation.dart';

import 'services.dart';

class NetworkModel extends ChangeNotifier {
  NetworkModel(this._service);

  final NetworkService _service;

  Future<void> init() => _service.isConnected().then(_updateConnected);

  bool _connected = false;
  bool get isConnected => _connected;
  void setConnected(bool value) {
    _service.setConnectedForTesting(value);
    _updateConnected(value);
  }

  void _updateConnected(bool value) {
    if (_connected == value) return;
    _connected = value;
    notifyListeners();
  }
}
