import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

// ignore_for_file: constant_identifier_names
const O_RDONLY = 0;
const PROT_READ = 0x1;
const MAP_PRIVATE = 0x02;

extension MemoryMapFile on File {
  Uint8List map() {
    final cpath = path.toNativeUtf8();
    final fd = _open(cpath.cast(), O_RDONLY);
    final size = File(path).statSync().size;
    final ptr = _mmap(nullptr, size, PROT_READ, MAP_PRIVATE, fd, 0);
    _close(fd);
    malloc.free(cpath);
    return ptr.cast<Uint8>().asTypedList(size);
  }
}

final _proc = DynamicLibrary.process();
final _open = _proc.lookupFunction<OpenC, OpenDart>('open');
final _mmap = _proc.lookupFunction<MMapC, MMapDart>('mmap');
final _close = _proc.lookupFunction<CloseC, CloseDart>('close');

// int open(const char *pathname, int flags)
typedef OpenC = Int32 Function(Pointer<Uint8> path, Int32 flags);
typedef OpenDart = int Function(Pointer<Uint8> path, int flags);

// int close(int fd)
typedef CloseC = Int32 Function(Int32 fd);
typedef CloseDart = int Function(int fd);

// void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset)
typedef MMapC = Pointer Function(
  Pointer address,
  IntPtr length,
  Int32 prot,
  Int32 flags,
  Int32 fd,
  IntPtr offset,
);
typedef MMapDart = Pointer Function(
  Pointer address,
  int len,
  int prot,
  int flags,
  int fd,
  int offset,
);
