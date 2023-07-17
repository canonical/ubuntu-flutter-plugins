class NetworkService {
  bool _connected = false;
  Future<bool> isConnected() {
    return Future.delayed(const Duration(milliseconds: 500))
        .then((_) => _connected);
  }

  void setConnectedForTesting(bool isOnline) => _connected = isOnline;
}
