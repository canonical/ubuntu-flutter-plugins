import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xdg_icons/src/cache.dart';

void main() {
  test('invalid', () {
    final cache = XdgIconCache('foo/bar/icon-theme.cache');
    expect(cache.isValid, isFalse);
    expect(cache.lookup('computer'), isEmpty);
  });

  test('outdated', () {
    final file = File('test/data/icon-theme.cache');
    final modified = file.parent.statSync().modified;
    file.setLastModifiedSync(modified.subtract(const Duration(hours: 1)));
    final cache = XdgIconCache('test/data/icon-theme.cache');
    expect(cache.isValid, isFalse);
    expect(cache.lookup('computer'), isEmpty);
  });

  test('valid', () {
    File('test/data/icon-theme.cache').setLastModifiedSync(DateTime.now());
    final cache = XdgIconCache('test/data/icon-theme.cache');
    expect(cache.isValid, isTrue);

    expect(
      cache.lookup('computer'),
      equals([
        'scalable/devices',
        '48x48/devices',
        '32x32/devices',
        '256x256/devices',
        '24x24/devices',
        '22x22/devices',
        '16x16/devices',
      ]),
    );
    expect(
      cache.lookup('folder'),
      equals([
        'scalable/places',
        '48x48/places',
        '32x32/places',
        '256x256/places',
        '24x24/places',
        '22x22/places',
        '16x16/places',
      ]),
    );
    expect(
      cache.lookup('web-browser'),
      equals([
        '48x48/apps',
        '32x32/apps',
        '256x256/apps',
        '24x24/apps',
        '22x22/apps',
        '16x16/apps',
      ]),
    );
  });
}
