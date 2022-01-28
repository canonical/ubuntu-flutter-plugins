# Handy Window

This package provides:
- Dart API for managing the Flutter window on desktop, and
- some minor visual enhancements on Linux and Windows.

## Linux

On Linux, this package provides an easy way to use [Handy](https://gitlab.gnome.org/GNOME/libhandy)
windows with modern looking rounded bottom corners.

| Before | After |
|---|---|
| <image src="https://raw.githubusercontent.com/canonical/ubuntu-flutter-plugins/main/packages/handy_window/images/ubuntu-before.png" width="400"/> | <image src="https://raw.githubusercontent.com/canonical/ubuntu-flutter-plugins/main/packages/handy_window/images/ubuntu-after.png" width="430"/> |

See <a href="#using-libhandy-on-linux">Using libhandy on Linux</a> for
instructions on how to change the default GTK+ window to a Handy window.

## Windows

On Windows, this package sets a dark title bar when the system theme is dark.
Vanilla Flutter applications have always a light title bar.

| Before | After |
|---|---|
| <image src="https://raw.githubusercontent.com/canonical/ubuntu-flutter-plugins/main/packages/handy_window/images/windows-before.png" width="400"/> | <image src="https://raw.githubusercontent.com/canonical/ubuntu-flutter-plugins/main/packages/handy_window/images/windows-after.png" width="400"/> |

## macOS

On macOS, there are no visual changes but all the functionality is supported.

| Before & After |
|---|
| <image src="https://raw.githubusercontent.com/canonical/ubuntu-flutter-plugins/main/packages/handy_window/images/macos.png" width="400"/> |


# Usage

Add the dependency to `pubspec.yaml`:
```yaml
dependencies:
  handy_window:
```

Available Dart API:

```dart
/// Returns the window title.
Future<String> getWindowTitle()

/// Sets the window title.
Future<void> setWindowTitle(String title)

/// Returns whether the window can be closed.
Future<bool> isWindowClosable()

/// Sets whether the window can be closed.
Future<void> setWindowClosable(bool closable)

/// Returns whether the window is visible.
Future<bool> isWindowVisible()

/// Requests that the window is shown or hidden.
Future<void> setWindowVisible(bool visible)

/// Requests that the window is shown. Same as [setWindowVisible(true)].
Future<void> showWindow()

/// Requests that the window is hidden. Same as [setWindowVisible(false)].
Future<void> hideWindow()

/// Returns whether the window is minimized.
Future<bool> isWindowMinimized()

/// Requests that the window is minimized.
Future<void> minimizeWindow([bool minimize = true])

/// Returns whether the window is maximized.
Future<bool> isWindowMaximized()

/// Requests that the window is maximized.
Future<void> maximizeWindow([bool maximize = true])

/// Returns whether the window is fullscreen.
Future<bool> isWindowFullscreen()

/// Requests that the window is fullscreened.
Future<void> setWindowFullscreen([bool fullscreen = true])

/// Returns the window size.
Future<Size> getWindowSize()

/// Requests that the window is resized.
Future<void> resizeWindow(Size size)

/// Calls back when the window is resizes.
Future<void> onWindowResized(OnWindowResized callback)

/// Requests that the window is closed.
Future<void> closeWindow()

/// Calls back when the window is closing.
///
/// Return false to prevent the window from closing.
Future<void> onWindowClosing(OnWindowClosing callback)
```


## Using libhandy on Linux

Install the libhandy development package:
```bash
$ apt install libhandy-1-dev
```

Use `handy_window_xxx` in `linux/my_application.cc`:
```cpp
// include the header
#include <handy_window/handy_window.h>

// modify my_application_activate()
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  // replace gtk_application_window_new() with handy_window_new()
  GtkWindow* window = handy_window_new(GTK_APPLICATION(application));
  // replace gtk_header_bar_xxx() with handy_window_xxx()
  handy_window_set_title(window, "Handy Window");

  // ...

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  // replace gtk_container_add() with handy_window_set_view()
  handy_window_set_view(window, GTK_WIDGET(view));

  // ...
}
```

The C++ API for Linux abstracts away the difference between vanilla GTK+ windows
& header bars, and Handy windows & header bars. The full API is available in
[`handy_window.h`](https://github.com/canonical/ubuntu-flutter-plugins/blob/main/packages/handy_window/linux/include/handy_window/handy_window.h).
