import 'dart:async';
import 'dart:ui';

export 'dart:ui' show Size;

/// Callback when the window is resized.
typedef OnWindowResized = FutureOr<void> Function(Size size);

/// Callback when the window is closing.
///
/// Return false to prevent the window from closing.
typedef OnWindowClosing = FutureOr<bool?> Function();
