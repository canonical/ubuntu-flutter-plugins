import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;

import 'gtk.g.dart' as ffi;
import 'dylib.dart';

extension StringList on List<String> {
  ffi.Pointer<ffi.Pointer<ffi.Char>> toArray({
    ffi.Allocator allocator = ffi.malloc,
  }) {
    final array = ffi.calloc<ffi.Pointer<ffi.Char>>(length);
    for (int i = 0; i < length; ++i) {
      array[i] = this[i].toNativeUtf8(allocator: allocator).cast();
    }
    return array;
  }
}

extension StringPointerArray on ffi.Pointer<ffi.Pointer<ffi.Char>> {
  List<String> toStringList(int length) {
    final list = <String>[];
    for (int i = 0; i < length; ++i) {
      list.add(this[i].cast<ffi.Utf8>().toDartString());
    }
    return list;
  }
}

extension StringListArray on ffi.Pointer<ffi.GList> {
  List<String> takeStringList() {
    final list = <String>[];
    var iter = this;
    while (iter != ffi.nullptr) {
      final cstr = iter.ref.data.cast<ffi.Utf8>();
      list.add(cstr.toDartString());
      lib.g_free(iter.ref.data);
      iter = iter.ref.next.cast();
    }
    lib.g_list_free(this);
    return list;
  }
}

extension IntPointerArray on ffi.Pointer<ffi.Int> {
  List<int> toIntList() {
    final list = <int>[];
    if (this != ffi.nullptr) {
      for (var i = 0; this[i] != 0; ++i) {
        list.add(this[i]);
      }
    }
    return list;
  }
}
