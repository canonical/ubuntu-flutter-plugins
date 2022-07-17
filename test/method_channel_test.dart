import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xdg_icons/src/data.dart';
import 'package:xdg_icons/src/method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('name and size', () async {
    final instance = XdgIconsMethodChannel();

    const testIcon = XdgIconData(
      baseScale: 1,
      baseSize: 24,
      fileName: '/path/to/icon.png',
      isSymbolic: false,
    );

    instance.methodChannel.setMockMethodCallHandler((call) async {
      expect(call.method, 'lookupIcon');
      expect(call.arguments, {'name': 'foo', 'size': 42});
      return testIcon.toJson();
    });

    expect(await instance.lookupIcon(name: 'foo', size: 42), testIcon);
  });

  test('scale and theme', () async {
    final instance = XdgIconsMethodChannel();

    const testIcon = XdgIconData(
      baseScale: 2,
      baseSize: 48,
      fileName: '/path/to/icon.svg',
      isSymbolic: false,
    );

    instance.methodChannel.setMockMethodCallHandler((call) async {
      expect(call.method, 'lookupIcon');
      expect(call.arguments, {
        'name': 'bar',
        'size': 42,
        'scale': 2,
        'theme': 'qux',
      });
      return testIcon.toJson();
    });

    expect(
      await instance.lookupIcon(name: 'bar', size: 42, scale: 2, theme: 'qux'),
      testIcon,
    );
  });

  test('broadcast events', () async {
    final instance = XdgIconsMethodChannel();

    const codec = StandardMethodCodec();
    final channel = instance.eventChannel.name;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger;

    Future<void> emitEvent(Object? event) {
      return messenger.handlePlatformMessage(
        channel,
        codec.encodeSuccessEnvelope(event),
        (_) {},
      );
    }

    messenger.setMockMessageHandler(channel, (message) async {
      expect(
        codec.decodeMethodCall(message),
        anyOf([
          isMethodCall('listen', arguments: null),
          isMethodCall('cancel', arguments: null),
        ]),
      );
      return codec.encodeSuccessEnvelope(null);
    });

    instance.onDefaultThemeChanged.listen(expectAsync1(
      (event) => expect(event, isNull),
    ));
    instance.onDefaultThemeChanged.listen(expectAsync1(
      (event) => expect(event, isNull),
    ));

    await emitEvent(null);
  });
}
