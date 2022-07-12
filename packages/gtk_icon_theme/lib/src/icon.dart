import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:path/path.dart' as path;

import 'gtk.g.dart' as ffi;
import 'lib.dart';

// ignore_for_file: non_constant_identifier_names

class GtkIconInfo {
  GtkIconInfo._(this._icon_info);

  static GtkIconInfo? fromPointer(ffi.Pointer<ffi.GtkIconInfo> ptr) {
    return ptr != ffi.nullptr ? GtkIconInfo._(ptr) : null;
  }

  final ffi.Pointer<ffi.GtkIconInfo> _icon_info;

  void dispose() => lib.g_object_unref(_icon_info.cast());

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
}
