import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;

import 'dylib.dart';
import 'ext.dart';
import 'finalizer.dart';
import 'flags.dart';
import 'gtk.g.dart' as ffi;
import 'icon.dart';

// ignore_for_file: non_constant_identifier_names

class GtkIconTheme implements ffi.Finalizable {
  factory GtkIconTheme() => GtkIconTheme._(lib.gtk_icon_theme_get_default());

  factory GtkIconTheme.custom(String name) {
    return ffi.using((arena) {
      final icon_theme = lib.gtk_icon_theme_new();
      final cstr = name.toNativeUtf8(allocator: arena);
      lib.gtk_icon_theme_set_custom_theme(icon_theme, cstr.cast());
      final theme = GtkIconTheme._(icon_theme);
      lib.g_object_unref(icon_theme.cast());
      return theme;
    });
  }

  GtkIconTheme._(this._icon_theme) {
    final ptr = lib.g_object_ref(_icon_theme.cast());
    finalizer.attach(this, ptr.cast<ffi.GtkIconTheme>());
  }

  final ffi.Pointer<ffi.GtkIconTheme> _icon_theme;

  void addResourcePath(String path) {
    ffi.using((arena) {
      final cstr = path.toNativeUtf8(allocator: arena);
      lib.gtk_icon_theme_add_resource_path(_icon_theme, cstr.cast());
    });
  }

  void appendSearchPath(String path) {
    ffi.using((arena) {
      final cstr = path.toNativeUtf8(allocator: arena);
      lib.gtk_icon_theme_append_search_path(_icon_theme, cstr.cast());
    });
  }

  GtkIconInfo? chooseIcon(
    String name, {
    required int size,
    Set<GtkIconLookupFlag> flags = const <GtkIconLookupFlag>{},
  }) {
    return ffi.using((arena) {
      final icon_info = lib.gtk_icon_theme_choose_icon(
        _icon_theme,
        name.toNativeUtf8(allocator: arena).cast(),
        size,
        flags.toInt(),
      );
      return GtkIconInfo.fromPointer(icon_info);
    });
  }

  GtkIconInfo? chooseIconForScale(
    List<String> names, {
    required int size,
    required int scale,
    Set<GtkIconLookupFlag> flags = const <GtkIconLookupFlag>{},
  }) {
    return ffi.using((arena) {
      final icon_info = lib.gtk_icon_theme_choose_icon_for_scale(
        _icon_theme,
        names.toArray(allocator: arena),
        size,
        scale,
        flags.toInt(),
      );
      return GtkIconInfo.fromPointer(icon_info);
    });
  }

  String getExampleIconName() {
    final cstr = lib.gtk_icon_theme_get_example_icon_name(_icon_theme);
    return cstr.cast<ffi.Utf8>().toDartString();
  }

  List<int> getIconSizes(String name) {
    return ffi.using((arena) {
      final cstr = name.toNativeUtf8(allocator: arena);
      final array = lib.gtk_icon_theme_get_icon_sizes(_icon_theme, cstr.cast());

      final sizes = <int>[];
      sizes.addAll(array.toIntList());
      lib.g_free(array.cast());
      return sizes;
    });
  }

  List<String> getSearchPath() {
    return ffi.using((arena) {
      final length = arena.allocate<ffi.Int>(1);
      final array = arena.allocate<ffi.Pointer<ffi.Pointer<ffi.Char>>>(1);
      lib.gtk_icon_theme_get_search_path(_icon_theme, array, length);

      final paths = <String>[];
      paths.addAll(array.value.toStringList(length.value));
      lib.g_strfreev(array.value);
      return paths;
    });
  }

  bool hasIcon(String name) {
    return ffi.using((arena) {
      final cstr = name.toNativeUtf8(allocator: arena);
      return lib.gtk_icon_theme_has_icon(_icon_theme, cstr.cast()) != 0;
    });
  }

  List<String> listContexts() {
    final list = lib.gtk_icon_theme_list_contexts(_icon_theme);
    return list.takeStringList();
  }

  List<String> listIcons(String context) {
    return ffi.using((arena) {
      final cstr = context.toNativeUtf8(allocator: arena);
      final list = lib.gtk_icon_theme_list_icons(_icon_theme, cstr.cast());
      return list.takeStringList();
    });
  }

  GtkIconInfo? lookupIcon(
    String name, {
    required int size,
    int? scale,
    Set<GtkIconLookupFlag> flags = const <GtkIconLookupFlag>{},
  }) {
    return ffi.using((arena) {
      final cstr = name.toNativeUtf8(allocator: arena);
      late final ffi.Pointer<ffi.GtkIconInfo> icon_info;
      if (scale != null) {
        icon_info = lib.gtk_icon_theme_lookup_icon_for_scale(
          _icon_theme,
          cstr.cast(),
          size,
          scale,
          flags.toInt(),
        );
      } else {
        icon_info = lib.gtk_icon_theme_lookup_icon(
          _icon_theme,
          cstr.cast(),
          size,
          flags.toInt(),
        );
      }
      return GtkIconInfo.fromPointer(icon_info);
    });
  }

  void prependSearchPath(String path) {
    ffi.using((arena) {
      final cstr = path.toNativeUtf8(allocator: arena);
      lib.gtk_icon_theme_prepend_search_path(_icon_theme, cstr.cast());
    });
  }

  void setSearchPath(List<String> searchPath) {
    ffi.using((arena) {
      lib.gtk_icon_theme_set_search_path(
        _icon_theme,
        searchPath.toArray(allocator: arena),
        searchPath.length,
      );
    });
  }
}
