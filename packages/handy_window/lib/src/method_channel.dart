import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

import 'types.dart';
import 'platform_window.dart';

// ignore_for_file: public_member_api_docs

@visibleForTesting
class MethodChannelWindow extends PlatformWindow {
  @visibleForTesting
  static const methodChannel = MethodChannel('handy_window');

  @visibleForTesting
  static const eventChannel = MethodChannel('handy_window/events');

  @override
  Future<String> getWindowTitle() {
    return _callMethod('getWindowTitle').then((value) => value);
  }

  @override
  Future<void> setWindowTitle(String title) {
    return _callMethod('setWindowTitle', title);
  }

  @override
  Future<bool> isWindowClosable() {
    return _callMethod('isWindowClosable').then((value) => value);
  }

  @override
  Future<void> setWindowClosable(bool closable) {
    return _callMethod('setWindowClosable', closable);
  }

  @override
  Future<bool> isWindowVisible() {
    return _callMethod('isWindowVisible').then((value) => value);
  }

  @override
  Future<void> setWindowVisible(bool visible) {
    return _callMethod('setWindowVisible', visible);
  }

  @override
  Future<bool> isWindowMinimized() {
    return _callMethod('isWindowMinimized').then((value) => value);
  }

  @override
  Future<void> minimizeWindow(bool minimize) {
    return _callMethod('minimizeWindow', minimize);
  }

  @override
  Future<bool> isWindowMaximized() {
    return _callMethod('isWindowMaximized').then((value) => value);
  }

  @override
  Future<void> maximizeWindow(bool maximize) {
    return _callMethod('maximizeWindow', maximize);
  }

  @override
  Future<bool> isWindowFullscreen() {
    return _callMethod('isWindowFullscreen').then((value) => value);
  }

  @override
  Future<void> setWindowFullscreen(bool fullscreen) {
    return _callMethod('setWindowFullscreen', fullscreen);
  }

  @override
  Future<Size> getWindowSize() {
    return _callMapMethod('getWindowSize').then((size) {
      final width = size?['width'] ?? 0.0;
      final height = size?['height'] ?? 0.0;
      return Size(width.toDouble(), height.toDouble());
    });
  }

  @override
  Future<void> resizeWindow(Size size) {
    final args = {'width': size.width.round(), 'height': size.height.round()};
    return _callMethod('resizeWindow', args);
  }

  @override
  Future<void> onWindowResized(OnWindowResized callback) {
    _listenEvent('onWindowResized', (event) {
      final size = event.arguments as Map;
      final width = size['width'] ?? 0.0;
      final height = size['height'] ?? 0.0;
      callback(Size(width.toDouble(), height.toDouble()));
    });
    return _callMethod('onWindowResized');
  }

  @override
  Future<void> closeWindow() => _callMethod('closeWindow');

  @override
  Future<void> onWindowClosing(OnWindowClosing callback) {
    _listenEvent('onWindowClosing', (event) {
      return callback();
    });
    return _callMethod('onWindowClosing');
  }

  Future<T?> _callMethod<T>(String method, [dynamic arguments]) {
    return methodChannel.invokeMethod(method, arguments);
  }

  Future<Map<K, V>?> _callMapMethod<K, V>(String method, [dynamic arguments]) {
    return methodChannel.invokeMapMethod(method, arguments);
  }

  final _eventCallbacks = <String, dynamic Function(MethodCall)>{};

  void _listenEvent(String event, dynamic Function(MethodCall) callback) {
    _eventCallbacks[event] = callback;
    eventChannel.setMethodCallHandler(_handleEvent);
  }

  Future<dynamic> _handleEvent(MethodCall event) async {
    final callback = _eventCallbacks[event.method];
    return callback?.call(event);
  }
}
