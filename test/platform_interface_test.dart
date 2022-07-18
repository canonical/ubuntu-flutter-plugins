import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:xdg_icons/src/method_channel.dart';
import 'package:xdg_icons/src/platform_interface.dart';

void main() {
  test('default instance', () {
    expect(XdgIconsPlatform.instance, isA<XdgIconsMethodChannel>());
  });

  test('set instance', () {
    XdgIconsPlatform.instance = MockXdgIconsPlatform();
    expect(XdgIconsPlatform.instance, isA<MockXdgIconsPlatform>());
  });

  test('unimplemented', () async {
    XdgIconsPlatform.instance = FakeXdgIconsPlatform();
    await expectLater(
      () => XdgIconsPlatform.instance.lookupIcon(name: 'test', size: 24),
      throwsA(isA<UnimplementedError>()),
    );
    await expectLater(
      () => XdgIconsPlatform.instance.onDefaultThemeChanged,
      throwsA(isA<UnimplementedError>()),
    );
  });
}

class MockXdgIconsPlatform
    with Mock, MockPlatformInterfaceMixin
    implements XdgIconsPlatform {}

class FakeXdgIconsPlatform extends XdgIconsPlatform {}
