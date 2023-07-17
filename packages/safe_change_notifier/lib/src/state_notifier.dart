import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';

/// A safe drop-in replacement for Riverpod's `StateNotifier` that makes
/// state changes no-op, rather than an error, after its disposal.
///
/// ![safe_change_notifier](https://github.com/ubuntu-flutter-community/safe_change_notifier/raw/main/images/safe_change_notifier.png)
class SafeStateNotifier<T> extends StateNotifier<T> {
  SafeStateNotifier(super.value);

  late T _disposedState;
  var _isDisposed = false;

  /// Whether the notifier has been disposed.
  bool get isDisposed => _isDisposed;

  @override
  @protected
  T get state => _isDisposed ? _disposedState : super.state;

  @override
  @protected
  set state(T value) {
    if (!_isDisposed) super.state = value;
  }

  @override
  bool get hasListeners => !_isDisposed && super.hasListeners;

  @override
  RemoveListener addListener(
    Listener<T> listener, {
    bool fireImmediately = true,
  }) {
    if (_isDisposed) return () {};
    return super.addListener(listener, fireImmediately: fireImmediately);
  }

  @override
  void dispose() {
    _disposedState = state;
    _isDisposed = true;
    super.dispose();
  }
}
