import 'dart:io';
import 'dart:typed_data';

import 'mmap.dart';

/// https://github.com/GNOME/gtk/blob/master/docs/iconcache.txt
class XdgIconCache {
  XdgIconCache(String path) : _data = _mmap(path);

  final Uint8List _data;

  bool get isValid =>
      majorVersion == 1 && !_iconList.isEmpty && !_directoryList.isEmpty;

  // Header:
  // 2  CARD16  MAJOR_VERSION	1
  // 2  CARD16  MINOR_VERSION	0
  // 4  CARD32  HASH_OFFSET
  // 4  CARD32  DIRECTORY_LIST_OFFSET
  int get majorVersion => _data.getUint16(0);
  int get minorVersion => _data.getUint16(2);
  _IconList get _iconList => _IconList(_data.getUint32(4), _data);
  _DirectoryList get _directoryList =>
      _DirectoryList(_data.getUint32(8), _data);

  List<String> lookup(String name) {
    final ret = <String>[];
    if (!isValid) return ret;

    var icon = _iconList[name.iconHash % _iconList.length];
    while (icon.offset != 0) {
      if (icon.name == name) {
        final dirs = _directoryList;
        final images = icon.imageList;
        for (var i = 0; i < images.length; ++i) {
          ret.add(dirs[images[i]]);
        }
        return ret;
      }
      icon = icon.next;
    }
    return ret;
  }
}

Uint8List _mmap(String path) {
  final file = File(path);
  if (!file.existsSync() || file.isOlderThan(file.parent)) {
    return Uint8List(0);
  }
  return file.map();
}

extension _IconNameHash on String {
  int get iconHash => codeUnits
      .fold(0, (int hash, int char) => (hash << 5) - hash + char)
      .toUnsigned(32);
}

extension _OlderFileSystemEntity on FileSystemEntity {
  bool isOlderThan(FileSystemEntity other) {
    return statSync().modified.isBefore(other.statSync().modified);
  }
}

extension _Uint8String on Uint8List {
  String stringAt(int offset, [int? length]) {
    if (length != null) {
      return String.fromCharCodes(this, offset, offset + length);
    }
    return String.fromCharCodes(skip(offset).takeWhile((char) => char != 0));
  }
}

extension _CacheData on Uint8List {
  ByteData get _byteData => buffer.asByteData();
  bool _checkValid(int offset, int size) =>
      offset >= 0 && offset + size < length;
  int getUint16(int offset) =>
      _checkValid(offset, 2) ? _byteData.getUint16(offset, Endian.big) : 0;
  int getUint32(int offset) =>
      _checkValid(offset, 4) ? _byteData.getUint32(offset, Endian.big) : 0;
}

// DirectoryList:
// 4                CARD32  N_DIRECTORIES
// 4*N_DIRECTORIES  CARD32  DIRECTORY_OFFSET
class _DirectoryList {
  const _DirectoryList(this.offset, this.data);
  final int offset;
  final Uint8List data;
  bool get isEmpty => length == 0;
  int get length => data.getUint32(offset);
  String operator [](int index) =>
      data.stringAt(data.getUint32(offset + 4 + index * 4));
}

// Hash:
// 4            CARD32  N_BUCKETS
// 4*N_BUCKETS  CARD32  ICON_OFFSET
class _IconList {
  const _IconList(this.offset, this.data);
  final int offset;
  final Uint8List data;
  bool get isEmpty => length == 0;
  int get length => data.getUint32(offset);
  _Icon operator [](int index) =>
      _Icon(data.getUint32(offset + 4 + index * 4), data);
}

// Icon:
// 4  CARD32  CHAIN_OFFSET
// 4  CARD32  NAME_OFFSET
// 4  CARD32  IMAGE_LIST_OFFSET
class _Icon {
  const _Icon(this.offset, this.data);
  final int offset;
  final Uint8List data;
  _Icon get next => _Icon(data.getUint32(offset), data);
  String get name => data.stringAt(data.getUint32(offset + 4));
  _ImageList get imageList => _ImageList(data.getUint32(offset + 8), data);
}

// ImageList:
// 4           CARD32  N_IMAGES
// 8*N_IMAGES  Image   IMAGES
class _ImageList {
  const _ImageList(this.offset, this.data);
  final int offset;
  final Uint8List data;
  int get length => data.getUint32(offset);
  int operator [](int index) => data.getUint16(offset + 4 + index * 8);
}
