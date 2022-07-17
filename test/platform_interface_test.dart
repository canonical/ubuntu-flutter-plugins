import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:xdg_icons/src/data.dart';
import 'package:xdg_icons/src/platform_interface.dart';
import 'package:xdg_icons/src/method_channel.dart';

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
    with MockPlatformInterfaceMixin
    implements XdgIconsPlatform {
  @override
  Future<XdgIconData?> lookupIcon({
    required String name,
    required int size,
    int? scale,
    String? theme,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream get onDefaultThemeChanged => throw UnimplementedError();
}

class FakeXdgIconsPlatform extends XdgIconsPlatform {}
