import 'dart:ffi' as ffi;

import 'gtk.g.dart' as ffi;

// libgtk-3.so.0
final dylib = ffi.DynamicLibrary.process();

final lib = ffi.LibGtk(dylib);
