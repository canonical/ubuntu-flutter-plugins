import 'package:flutter_test/flutter_test.dart';
import 'package:xdg_icons/src/cache.dart';

void main() {
  test('yaru', () {
    final cache = XdgIconCache('/usr/share/icons/Yaru/icon-theme.cache');
    expect(cache.isValid, isTrue);
    expect(
        cache.lookup('computer'),
        equals([
          '48x48@2x/devices',
          '48x48/devices',
          '32x32@2x/devices',
          '32x32/devices',
          '256x256@2x/devices',
          '256x256/devices',
          '24x24@2x/devices',
          '24x24/devices',
          '16x16@2x/devices',
          '16x16/devices',
        ]));
  });
}
