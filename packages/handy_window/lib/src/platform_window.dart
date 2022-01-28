import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'types.dart';
import 'method_channel.dart';

// ignore_for_file: public_member_api_docs

class PlatformWindow extends PlatformInterface {
  PlatformWindow() : super(token: _token);

  static final Object _token = Object();

  static PlatformWindow _instance = MethodChannelWindow();

  static PlatformWindow get instance => _instance;

  static set instance(PlatformWindow instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getWindowTitle() => _instance.getWindowTitle();
  Future<void> setWindowTitle(String title) {
    return _instance.setWindowTitle(title);
  }

  Future<bool> isWindowClosable() => _instance.isWindowClosable();
  Future<void> setWindowClosable(bool closable) {
    return _instance.setWindowClosable(closable);
  }

  Future<bool> isWindowVisible() => _instance.isWindowVisible();
  Future<void> setWindowVisible(bool visible) {
    return _instance.setWindowVisible(visible);
  }

  Future<bool> isWindowMinimized() => _instance.isWindowMinimized();
  Future<void> minimizeWindow(bool minimize) {
    return _instance.minimizeWindow(minimize);
  }

  Future<bool> isWindowMaximized() => _instance.isWindowMaximized();
  Future<void> maximizeWindow(bool maximize) {
    return _instance.maximizeWindow(maximize);
  }

  Future<bool> isWindowFullscreen() => _instance.isWindowFullscreen();
  Future<void> setWindowFullscreen(bool fullscreen) {
    return _instance.setWindowFullscreen(fullscreen);
  }

  Future<Size> getWindowSize() => _instance.getWindowSize();
  Future<void> resizeWindow(Size size) => _instance.resizeWindow(size);
  Future<void> onWindowResized(OnWindowResized callback) {
    return _instance.onWindowResized(callback);
  }

  Future<void> closeWindow() => _instance.closeWindow();
  Future<void> onWindowClosing(OnWindowClosing callback) {
    return _instance.onWindowClosing(callback);
  }
}
