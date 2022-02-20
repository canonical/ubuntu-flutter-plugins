import 'dart:ffi' as ffi;

import 'gtk.g.dart' as ffi;

// libgtk-3.so.0
final lib = ffi.LibGtk(ffi.DynamicLibrary.process());
