import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:path/path.dart' as path;

import 'dylib.dart';
import 'finalizer.dart';
import 'gtk.g.dart' as ffi;
import 'gtk.g.dart';

// ignore_for_file: non_constant_identifier_names

class GtkIconInfo implements ffi.Finalizable {
  GtkIconInfo._(this._icon_info) {
    final ptr = lib.g_object_ref(_icon_info.cast());
    finalizer.attach(this, ptr.cast<ffi.GtkIconInfo>());
  }

  static GtkIconInfo? fromPointer(ffi.Pointer<ffi.GtkIconInfo> ptr) {
    return ptr != ffi.nullptr ? GtkIconInfo._(ptr) : null;
  }

  final ffi.Pointer<ffi.GtkIconInfo> _icon_info;

  int get baseScale => lib.gtk_icon_info_get_base_scale(_icon_info);

  int get baseSize => lib.gtk_icon_info_get_base_size(_icon_info);

  String get displayName {
    return lib
        .gtk_icon_info_get_display_name(_icon_info)
        .cast<ffi.Utf8>()
        .toDartString();
  }

  String get fileName {
    return lib
        .gtk_icon_info_get_filename(_icon_info)
        .cast<ffi.Utf8>()
        .toDartString();
  }

  bool get isSymbolic => lib.gtk_icon_info_is_symbolic(_icon_info) != 0;
  bool get isScalable => path.extension(fileName).toLowerCase() == '.svg';

  Uint8List load() {
    return ffi.using((arena) {
      final path = lib.gtk_icon_info_get_filename(_icon_info);
      final bytes = lib.g_resources_lookup_data(path, 0, ffi.nullptr);
      final size = arena<gsize>();
      final array = lib.g_bytes_get_data(bytes, size).cast<ffi.Uint8>();
      final data = Uint8List.fromList(array.asTypedList(size.value));
      lib.g_bytes_unref(bytes);
      return data;
    });
  }
}
