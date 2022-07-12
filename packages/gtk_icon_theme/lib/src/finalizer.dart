import 'dart:ffi' as ffi;

import 'dylib.dart';
import 'gtk.g.dart' as ffi;

GtkFinalizer? _finalizer;

GtkFinalizer get finalizer => _finalizer ??= GtkFinalizer();

final _objects = <Object, ffi.NativeFinalizer>{};
final _finalizers = {
  ffi.GtkIconInfo: ffi.NativeFinalizer(dylib.lookup('g_object_unref')),
  ffi.GtkIconTheme: ffi.NativeFinalizer(dylib.lookup('g_object_unref')),
};

class GtkFinalizer {
  void attach<T extends ffi.NativeType>(
    ffi.Finalizable object,
    ffi.Pointer<T> ptr,
  ) {
    _objects[object] = _finalizers[T]!
      ..attach(object, ptr.cast(), detach: object);
  }

  void detach(ffi.Finalizable object) {
    _objects.remove(object)!.detach(object);
  }
}
