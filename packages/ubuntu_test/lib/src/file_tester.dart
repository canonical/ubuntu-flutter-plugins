import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/src/expect/async_matcher.dart'; // ignore: implementation_imports

/// Matches a text file.
Matcher matchesTextFile(String path) => _TextFileMatcher(path);

/// Matches a file that exists later.
final AsyncMatcher existsLater = _FileExistsLaterMatcher();

/// File tester extensions.
extension UbuntuFileTester on File {
  /// Waits until the specified file has been written on the disk, as in, it
  /// exists and is not empty.
  Future<bool> existsLater({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (existsSync()) return true;

    assert(timeout.inMilliseconds >= 250);
    const delay = Duration(milliseconds: 250);

    await Future.doWhile(() {
      return Future.delayed(delay).then((_) {
        return !existsSync() || statSync().size <= 0;
      });
    }).timeout(
      timeout,
      onTimeout: () => debugPrint(
          '\nWARNING: A call to waitForFile() with file "$path" did not complete within the specified time limit $timeout.\n${StackTrace.current}'),
    );
    return existsSync() && statSync().size > 0;
  }
}

class _TextFileMatcher extends CustomMatcher {
  _TextFileMatcher(String path)
      : super('Text file matches', 'path',
            equals(File(path).readAsStringSync().trim()));

  @override
  Object featureValueOf(covariant String path) {
    return File(path).readAsStringSync().trim();
  }
}

class _FileExistsLaterMatcher extends AsyncMatcher {
  @override
  Future<String?> matchAsync(dynamic item) async {
    late File file;
    if (item is File) {
      file = item;
    } else if (item is String) {
      file = File(item);
    } else {
      throw ArgumentError.value(item, 'item', 'Must be File or String.');
    }
    return await file.existsLater() ? null : 'did not exist';
  }

  @override
  Description describe(Description description) {
    return description.add('file exists');
  }
}
