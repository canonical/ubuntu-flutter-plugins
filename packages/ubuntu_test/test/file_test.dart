import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

void main() {
  test('matches text file', () async {
    await IOOverrides.runZoned(
      () async {
        await expectLater('match.txt', matchesTextFile('golden.txt'));
        await expectLater('mismatch.txt', isNot(matchesTextFile('golden.txt')));
      },
      createFile: (path) {
        switch (path) {
          case 'match.txt':
            return FakeFile(data: 'test');
          case 'mismatch.txt':
            return FakeFile(data: 'mismatch');
          case 'golden.txt':
            return FakeFile(data: 'test\n');
          default:
            throw UnsupportedError(path);
        }
      },
    );
  });

  test('exists later', () async {
    await IOOverrides.runZoned(
      () async {
        await expectLater('1.txt', existsLater);
        await expectLater(FakeFile(existsLater: 3), existsLater);
        await expectLater(
          () => expectLater(123, existsLater),
          throwsArgumentError,
        );
      },
      createFile: (path) {
        switch (path) {
          case '1.txt':
            return FakeFile(existsLater: 1);
          default:
            throw UnsupportedError(path);
        }
      },
    );
  });
}

class FakeFile extends Fake implements File {
  FakeFile({String? data, int? existsLater})
      : _data = data,
        _existsLater = existsLater ?? 0;

  final String? _data;
  int _existsLater;

  @override
  bool existsSync() => --_existsLater <= 0;

  @override
  FileStat statSync() => FakeFileStat(size: _existsLater <= 0 ? 1 : 0);

  @override
  String readAsStringSync({Encoding encoding = utf8}) => _data!;
}

class FakeFileStat extends Fake implements FileStat {
  FakeFileStat({required this.size});

  @override
  final int size;
}
