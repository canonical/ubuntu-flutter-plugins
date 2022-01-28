/// Manages the top-level application window.
library handy_window;

import 'src/types.dart';
import 'src/platform_window.dart';

export 'src/types.dart';

/// Returns the window title.
Future<String> getWindowTitle() {
  return PlatformWindow.instance.getWindowTitle();
}

/// Sets the window title.
Future<void> setWindowTitle(String title) {
  return PlatformWindow.instance.setWindowTitle(title);
}

/// Returns whether the window can be closed.
Future<bool> isWindowClosable() {
  return PlatformWindow.instance.isWindowClosable();
}

/// Sets whether the window can be closed.
Future<void> setWindowClosable(bool closable) {
  return PlatformWindow.instance.setWindowClosable(closable);
}

/// Returns whether the window is visible.
Future<bool> isWindowVisible() {
  return PlatformWindow.instance.isWindowVisible();
}

/// Requests that the window is shown or hidden.
Future<void> setWindowVisible(bool visible) {
  return PlatformWindow.instance.setWindowVisible(visible);
}

/// Requests that the window is shown. Same as [setWindowVisible(true)].
Future<void> showWindow() {
  return setWindowVisible(true);
}

/// Requests that the window is hidden. Same as [setWindowVisible(false)].
Future<void> hideWindow() {
  return setWindowVisible(false);
}

/// Returns whether the window is minimized.
Future<bool> isWindowMinimized() {
  return PlatformWindow.instance.isWindowMinimized();
}

/// Requests that the window is minimized.
Future<void> minimizeWindow([bool minimize = true]) {
  return PlatformWindow.instance.minimizeWindow(minimize);
}

/// Returns whether the window is maximized.
Future<bool> isWindowMaximized() {
  return PlatformWindow.instance.isWindowMaximized();
}

/// Requests that the window is maximized.
Future<void> maximizeWindow([bool maximize = true]) {
  return PlatformWindow.instance.maximizeWindow(maximize);
}

/// Returns whether the window is fullscreen.
Future<bool> isWindowFullscreen() {
  return PlatformWindow.instance.isWindowFullscreen();
}

/// Requests that the window is fullscreened.
Future<void> setWindowFullscreen([bool fullscreen = true]) {
  return PlatformWindow.instance.setWindowFullscreen(fullscreen);
}

/// Returns the window size.
Future<Size> getWindowSize() {
  return PlatformWindow.instance.getWindowSize();
}

/// Requests that the window is resized.
Future<void> resizeWindow(Size size) {
  return PlatformWindow.instance.resizeWindow(size);
}

/// Calls back when the window is resizes.
Future<void> onWindowResized(OnWindowResized callback) {
  return PlatformWindow.instance.onWindowResized(callback);
}

/// Requests that the window is closed.
Future<void> closeWindow() {
  return PlatformWindow.instance.closeWindow();
}

/// Calls back when the window is closing.
///
/// Return false to prevent the window from closing.
Future<void> onWindowClosing(OnWindowClosing callback) {
  return PlatformWindow.instance.onWindowClosing(callback);
}
